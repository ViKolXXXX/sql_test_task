--Задание 1. Выведите уникальные названия городов из таблицы городов.
SELECT DISTINCT city FROM city;
/*Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.*/
SELECT DISTINCT city FROM city WHERE city LIKE 'L%a' AND city NOT LIKE '% %';
/*Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.*/
SELECT payment_id, customer_id, staff_id, rental_id, amount, payment_date FROM payment WHERE payment_date BETWEEN '2005-06-17' AND '2005-06-19' AND amount > 1.00 ORDER BY payment_date;
/*Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.*/
SELECT payment_id, customer_id, staff_id, rental_id, amount, payment_date FROM payment ORDER BY payment_date DESC LIMIT 10;
/*Задание 5. Выведите следующую информацию по покупателям:
    • Фамилия и имя (в одной колонке через пробел)
    • Электронная почта
    • Длину значения поля email
    • Дату последнего обновления записи о покупателе (без времени)
 Каждой колонке задайте наименование на русском языке.*/
SELECT
	concat(last_name,
	' ',
	first_name) AS Фамилия_Имя,
	email AS Почта,
	CHAR_LENGTH (email) AS Длина_почты,
	last_update::date AS Дата_записи
FROM
	customer;
/*Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.*/
SELECT customer_id, store_id, lower(first_name), lower(last_name), email, address_id, activebool, create_date, last_update, active FROM customer c WHERE activebool = true AND (first_name ='KELLY'OR first_name = 'WILLIE');
/*Задание 7. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.*/
SELECT * FROM film WHERE (rating = 'R' AND rental_rate BETWEEN 0.00 AND 3.00) OR (rating = 'PG-13' AND rental_rate >= 4.00);
/*Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма.*/
SELECT * FROM film ORDER BY char_length(description) DESC LIMIT 3;
/*Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
    • в первой колонке должно быть значение, указанное до @,
    • во второй колонке должно быть значение, указанное после @.*/
SELECT split_part(email, '@', 1) AS login,
		split_part(email, '@', 2) AS domen
FROM customer
/*Задание 10. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква должна быть заглавной, остальные строчными.*/
SELECT
	upper(left(split_part(email, '@', 1), 1)) || 
	lower(right(split_part(email, '@', 1), char_length(split_part(email, '@', 1)) - 1)) AS login,	
	upper(left(split_part(email, '@', 2), 1)) || 
	lower(right(split_part(email, '@', 2), char_length(split_part(email, '@', 2)) - 1)) AS domen
FROM
	customer



