-- Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features) равным “Behind the Scenes”.
SELECT * FROM film WHERE 'Behind the Scenes' = ANY(special_features);
/*Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции или операторы языка SQL
для поиска значения в массиве.*/
SELECT * FROM film WHERE '{Behind the Scenes}' && special_features;
SELECT * FROM film WHERE special_features @> '{Behind the Scenes}';

/*Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.*/
WITH films_special_features AS (
	SELECT * 
	FROM film 
	WHERE 'Behind the Scenes' = ANY(special_features)	
)
SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS count_rental_special_features
	FROM customer c
	INNER JOIN rental r USING (customer_id) 
	INNER JOIN inventory i USING (inventory_id) 
	INNER JOIN films_special_features fsf ON i.film_id = fsf.film_id 
GROUP BY c.first_name, c.last_name
ORDER BY c.first_name;

/*Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в подзапрос, который необходимо использовать для решения задания.*/

SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS count_rental_special_features
	FROM customer c
	INNER JOIN rental r USING (customer_id) 
	INNER JOIN inventory i USING (inventory_id) 
	INNER JOIN (SELECT * 
				FROM film 
				WHERE 'Behind the Scenes' = ANY(special_features))	AS fsf ON i.film_id = fsf.film_id 
GROUP BY c.first_name, c.last_name
ORDER BY c.first_name;

/*Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите запрос для обновления материализованного представления.*/

CREATE MATERIALIZED VIEW customer_rents_behind_the_scenes AS --2 secs 264 msec.
SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS count_rental_special_features
	FROM customer c
	INNER JOIN rental r USING (customer_id) 
	INNER JOIN inventory i USING (inventory_id) 
	INNER JOIN (SELECT * 
				FROM film 
				WHERE 'Behind the Scenes' = ANY(special_features))	AS fsf ON i.film_id = fsf.film_id 
GROUP BY c.first_name, c.last_name
ORDER BY c.first_name;
SELECT * FROM customer_rents_behind_the_scenes; --77 msec.

/*Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее;*/


explain analyze --0.5 мс
	SELECT * FROM film WHERE 'Behind the Scenes' = ANY(special_features);
explain analyze	--0.3 мс
	SELECT * FROM film WHERE '{Behind the Scenes}' && special_features;
explain analyze --0.4 мс
	SELECT * FROM film WHERE special_features @> '{Behind the Scenes}';

--ВЫВОД: С текущими данными оператор && показал наилучшее время выполнения.

-- Вывод: PostgreSQL 14. Разницы почти нет.
/*какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.*/

 explain analyze --13.2 мс
	 WITH films_special_features AS (
	SELECT * 
	FROM film 
	WHERE 'Behind the Scenes' = ANY(special_features)	
	)
	SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS count_rental_special_features
		FROM customer c
		INNER JOIN rental r USING (customer_id) 
		INNER JOIN inventory i USING (inventory_id) 
		INNER JOIN films_special_features fsf ON i.film_id = fsf.film_id 
	GROUP BY c.first_name, c.last_name;

explain analyze --12.2, 
	SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS count_rental_special_features
		FROM customer c
		INNER JOIN rental r USING (customer_id) 
		INNER JOIN inventory i USING (inventory_id) 
		INNER JOIN (SELECT * 
					FROM film 
					WHERE 'Behind the Scenes' = ANY(special_features))	AS fsf ON i.film_id = fsf.film_id 
	GROUP BY c.first_name, c.last_name;

-- Вывод: PostgreSQL 14. В текущем состоянии вариант с использованием подзапроса работает быстрее.

-- Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
 
SELECT last_name, first_name, payment_date 
FROM (
	SELECT s.last_name, s.first_name, p.payment_date,
		 ROW_NUMBER () OVER (PARTITION BY s.staff_id ORDER BY payment_date) AS first_date_pay
	 FROM staff s INNER JOIN payment p USING(staff_id)
		) AS subquery
WHERE first_date_pay = 1;

/*Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
    • день, в который арендовали больше всего фильмов (в формате год-месяц-день);
    • количество фильмов, взятых в аренду в этот день;
    • день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
    • сумму продажи в этот день.*/

WITH store_aggregat AS (
		SELECT 	s.store_id,		
				r.rental_date::date AS rental_date_day,
				COUNT(i.film_id) AS count_film,
				SUM(p.amount) AS sum_amount		
		FROM store s 
				INNER JOIN inventory i USING(store_id) 
				INNER JOIN rental r USING(inventory_id)
				INNER JOIN payment p ON r.rental_id = p.rental_id
		GROUP BY s.store_id, r.rental_date::date
	), 
	stat_film AS (	
		SELECT *, 
			DENSE_RANK() OVER (PARTITION BY store_id ORDER BY count_film DESC) AS rank_film
		FROM store_aggregat
	),
	stat_payment AS (
		SELECT *,
			DENSE_RANK() OVER (PARTITION BY store_id ORDER BY sum_amount) AS rank_sum_amount
		FROM store_aggregat
	)
	
SELECT store_id,
	MAX(CASE WHEN sf.rank_film = 1 THEN sf.rental_date_day END) AS day_max_film_rented, --день, в который арендовали больше всего фильмов
	MAX(CASE WHEN sf.rank_film = 1 THEN sf.count_film END) AS count_film,--количество фильмов, взятых в аренду в этот день
	MAX(CASE WHEN sp.rank_sum_amount = 1 THEN sp.rental_date_day END) AS day_amount_film_min_sum,--день, в который продали фильмов на наименьшую сумму
	MAX(CASE WHEN sp.rank_sum_amount = 1 THEN sp.sum_amount END) AS sum_amount --сумму продажи в этот день
FROM stat_film sf 
INNER JOIN stat_payment sp USING (store_id)
GROUP BY store_id;
