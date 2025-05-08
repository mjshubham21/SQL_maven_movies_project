-- 5-5-25, Monday 
USE mavenmovies;

SELECT COUNT(*)
FROM rental;

SELECT *
FROM payment
WHERE amount = 0;

SELECT AVG(amount)
FROM payment;
-- WHERE AMOUNT != 0;

-- Q1. Top 10 Customers

SELECT customer_id, SUM(amount) AS Revenue
FROM payment
GROUP BY customer_id
ORDER BY Revenue DESC
LIMIT 10;

-- Q.2 FROM Q1 GET THE EMAILS OF TOP 10 CUSTOMERS

SELECT X.customer_id
FROM (SELECT customer_id, SUM(amount) AS Revenue
FROM payment
GROUP BY customer_id
ORDER BY Revenue DESC
LIMIT 10) AS X;

SELECT customer_id, email
FROM customer
WHERE customer_id IN (
	SELECT X.customer_id
	FROM (
		SELECT customer_id, SUM(amount) AS Revenue
		FROM payment
		GROUP BY customer_id
		ORDER BY Revenue DESC
		LIMIT 10
        ) AS X
);

SELECT *
FROM film;

-- 6-5-2025, Tuesday;

SELECT rating, COUNT(*) AS total_count
FROM film
GROUP BY  rating
ORDER BY total_count DESC;

SELECT COUNT(*)
FROM (
	SELECT film_id
	FROM inventory
	GROUP BY film_id) AS X; -- AS is not compulsory but good for improving readablity.

SELECT *
FROM payment;

SELECT F.film_id, F.title , SUM(P.amount) AS gross_revenue
FROM payment AS P LEFT JOIN rental AS R
ON P.rental_id = R.rental_id LEFT JOIN inventory AS I
ON R.inventory_id = I.inventory_id LEFT JOIN film AS F
ON I.film_id = F.film_id
GROUP BY F.film_id
ORDER BY gross_revenue DESC
LIMIT 10;

SELECT *
FROM inventory;

