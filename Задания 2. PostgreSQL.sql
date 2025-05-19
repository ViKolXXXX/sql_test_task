--Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	a.address,
	ci.city,
	co.country
FROM
	customer c
INNER JOIN address a
		USING (address_id)
INNER JOIN city ci
		USING(city_id)
INNER JOIN country co
		USING(country_id);
	
--Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
SELECT
	s.store_id,
	COUNT(customer_id) AS customer_count
FROM
	store s
INNER JOIN customer c
		USING(store_id)
GROUP BY
	(s.store_id);

    /*• Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. */
    SELECT
	s.store_id,
	COUNT(customer_id) AS customer_count
FROM
	store s
INNER JOIN customer c
		USING(store_id)
GROUP BY
	(s.store_id)
HAVING
	COUNT(customer_id) > 300;

    /*• Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём. */
SELECT
	s.store_id,
	COUNT(customer_id) AS customer_count,
	ci.city,
	st.first_name,
	st.last_name
FROM store s
INNER JOIN customer c USING(store_id)
INNER JOIN address a  ON s.address_id = a.address_id
INNER JOIN city ci USING(city_id)
INNER JOIN staff st ON s.manager_staff_id = st.staff_id
GROUP BY s.store_id, ci.city, st.first_name, st.last_name;
    
--Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.
SELECT
	COUNT(r.rental_id) AS count_rental,
	c.customer_id,
	c.first_name,
	c.last_name
FROM
	rental r
INNER JOIN customer c
		USING(customer_id)
GROUP BY
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY
	count_rental DESC
LIMIT 5;

/*Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
    • количество взятых в аренду фильмов;
    • общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
    • минимальное значение платежа за аренду фильма;
    • максимальное значение платежа за аренду фильма.*/
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS count_rental, 
		ROUND(SUM(p.amount)) AS sum_amount, MIN(p.amount) AS min_amount, MAX(p.amount) AS max_amount
FROM customer c
INNER JOIN rental r USING(customer_id)
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.first_name, c.last_name;

/*Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.*/
SELECT c1.city AS city_1, c2.city AS city_2 FROM city c1 CROSS JOIN city c2 WHERE c1.city <> c2.city;

/*Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.*/
SELECT c.customer_id, c.first_name, c.last_name, ROUND(avg((r.return_date::DATE - r.rental_date::DATE))) AS avg_day FROM customer c INNER JOIN rental r USING(customer_id) GROUP BY c.customer_id, c.first_name, c.last_name;

/*Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.*/
SELECT
	f.film_id,
	f.title,
	COUNT(DISTINCT r.rental_id) AS count_rental,
	COALESCE (SUM(p.amount), 0) AS sum_amount
FROM film f
LEFT JOIN inventory i	USING(film_id)
LEFT JOIN rental r USING (inventory_id)
LEFT JOIN payment p USING(rental_id)
GROUP BY f.film_id, f.title;

--Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.
SELECT
	f.film_id,
	f.title,
	COUNT(r.rental_id) AS count_rental,
	COALESCE (SUM(p.amount), 0) AS sum_amount
FROM film f
LEFT JOIN inventory i	USING(film_id)
LEFT JOIN rental r USING (inventory_id)
LEFT JOIN payment p USING(rental_id)
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) = 0;

/*Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».*/

SELECT
	s.staff_id,
	s.first_name,
	s.last_name,
	COUNT(payment_id) AS count_payment,
	CASE
		WHEN COUNT(payment_id) > 7300 THEN 'Да'		
		ELSE 'Нет'
	END AS Премия
FROM staff s
INNER JOIN payment p USING(staff_id)
GROUP BY s.staff_id, s.first_name, s.last_name;




