/*Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
    • Пронумеруйте все платежи от 1 до N по дате*/
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY payment_date::date ORDER BY payment_id) AS pay_num
	FROM payment;
  --• Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS customer_num
	FROM payment;
  /*  • Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей*/
	SELECT *, 
		SUM(amount) OVER (PARTITION BY customer_id ORDER BY payment_date, amount) AS customer_num
	FROM payment;
   /*• Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
	Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.*/
	SELECT *, 
		RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) AS customer_runk
	FROM payment;

/*Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате*/.
SELECT customer_id, payment_date, amount,
	LAG (amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) AS offset_amount	
FROM payment;

-- Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
SELECT customer_id, payment_date, amount,
	LEAD(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) - amount AS next_payment
FROM payment;

--Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
SELECT customer_id, payment_date, amount,
	 FIRST_VALUE(amount) OVER (PARTITION BY customer_id ORDER BY payment_date DESC) AS final_pay
FROM payment;

/*Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по 
каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.*/

SELECT staff_id, payment_date::date AS pay_date, amount,
     SUM(amount) OVER (
         PARTITION BY staff_id, payment_date::date
         ORDER BY payment_date::date
         ROWS UNBOUNDED PRECEDING
     ) AS sum_pay
FROM payment
WHERE payment_date BETWEEN '2005-08-01' AND '2005-08-31';

/*Задание 6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на 
следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.*/

WITH numbered_payment AS (
	SELECT *, 
		ROW_NUMBER() OVER (ORDER BY payment_id) AS num
	FROM
		payment
	WHERE payment_date::date = '2005-08-20'
)
SELECT customer_id FROM numbered_payment WHERE num % 100 = 0;

/*Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
    • покупатель, арендовавший наибольшее количество фильмов;
    • покупатель, арендовавший фильмов на самую большую сумму;
    • покупатель, который последним арендовал фильм.*/
WITH country_stats AS (
		SELECT c.country,
				cu.first_name,
				cu.last_name,	
				COUNT(r.rental_id) AS count_rental,
				SUM(p.amount) AS sum_amount,
				MAX(r.rental_date) AS last_date		
		FROM country c
		        INNER JOIN city ci ON c.country_id = ci.country_id
		        INNER JOIN address a ON ci.city_id = a.city_id
		        INNER JOIN customer cu ON a.address_id = cu.address_id
		        INNER JOIN rental r ON cu.customer_id = r.customer_id
		        INNER JOIN payment p ON r.rental_id = p.rental_id
		GROUP BY c.country, cu.first_name, cu.last_name
		ORDER BY c.country
),
	country_max AS (
		SELECT
			country,
			MAX(count_rental) AS max_rental,
			MAX(sum_amount) AS max_amount,
			MAX(last_date) AS max_date
		FROM country_stats
		GROUP BY country 	
	),
	customers_rank AS (
	    SELECT
	        cs.*,
	        DENSE_RANK() OVER (PARTITION BY cs.country ORDER BY cs.count_rental DESC) AS rank_rental,
	        DENSE_RANK() OVER (PARTITION BY cs.country ORDER BY cs.sum_amount DESC) AS rank_amount,
	        DENSE_RANK() OVER (PARTITION BY cs.country ORDER BY cs.last_date DESC) AS rank_date
	    FROM country_stats cs
)
SELECT
    cr.country,
    MAX(CASE WHEN cr.rank_rental = 1 THEN CONCAT (cr.first_name, ' ', cr.last_name) END) AS max_customer_films,
	MAX(CASE WHEN cr.rank_amount = 1 THEN CONCAT (cr.first_name, ' ', cr.last_name) END) AS max_cusomer_amount,
	MAX(CASE WHEN cr.rank_date = 1 THEN CONCAT (cr.first_name, ' ', cr.last_name) END) AS last_customer_date
FROM customers_rank cr
GROUP BY cr.country;





		