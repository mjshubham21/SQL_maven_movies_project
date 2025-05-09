-- 6-5-2025, TUESDAY;
USE MAVENMOVIES;

-- You need to provide customer firstname, lastname and email id to the marketing team --

SELECT first_name, last_name, email
FROM customer;

-- How many movies are with rental rate of $0.99? --

SELECT COUNT(*) AS "rental_0.99"
FROM film
WHERE rental_rate = 0.99;

-- We want to see rental rate and how many movies are in each rental category --
-- rental and movie category are different

SELECT rental_rate, COUNT(*) AS NO_OF_MOVIES
FROM film
GROUP BY rental_rate;

-- Which rating has the most films? --

SELECT rating, COUNT(*) AS movies_raingWise
FROM film
GROUP BY  rating
ORDER BY movies_raingWise DESC;


-- Which rating is most prevalant in each store? --

SELECT I.store_id, F.rating, COUNT(F.rating) AS total_films
FROM inventory AS I LEFT JOIN film AS F
ON I.film_id = F.film_id
GROUP BY I.store_id, F.rating
ORDER BY total_films DESC;

-- List of films by Film Name, Category, Language --

SELECT F.title AS film_name, C.name AS category, L.name AS language
FROM film_category AS FC LEFT JOIN category AS C
ON FC.category_id = C.category_id LEFT JOIN film AS F
ON FC.film_id = F.film_id LEFT JOIN language AS L
ON F.language_id = L.language_id;

-- 7-5-2025, Wednesday;

-- How many times each movie has been rented out?

SELECT I.film_id, F.title, COUNT(*) AS popularity
FROM rental AS R LEFT JOIN inventory I
ON R.inventory_id = I.inventory_id LEFT JOIN film AS F
ON I.film_id = F.film_id
GROUP BY I.film_id
ORDER BY popularity DESC;

-- REVENUE PER FILM (TOP 10 GROSSERS)

SELECT F.film_id , F.title, SUM(P.amount) AS revenue
FROM payment AS P LEFT JOIN rental AS R
ON P.rental_id = R.rental_id LEFT JOIN inventory AS I
ON R.inventory_id = I.inventory_id LEFT JOIN film AS F
ON I.film_id = F.film_id
GROUP BY F.film_id
ORDER BY revenue DESC
LIMIT 10;

-- Most Spending Customer so that we can send him/her rewards or debate points
-- USING SUBQUERY
SELECT *
FROM customer
WHERE customer_id IN (
	SELECT X.customer_id
    FROM (
		SELECT customer_id, SUM(amount) AS revenue
        FROM payment
        GROUP BY customer_id
        ORDER BY revenue DESC
        LIMIT 10
    ) AS X);

-- USING JOIN

SELECT C.customer_id, SUM(P.amount) AS renevure_per_cust
FROM payment AS P LEFT JOIN customer AS C
ON P.customer_id = C.customer_id
GROUP BY C.customer_id
ORDER BY renevure_per_cust DESC
LIMIT 10;

-- Which Store has historically brought the most revenue?

SELECT S.store_id, SUM(P.amount) AS storewise_sale
FROM payment AS P LEFT JOIN staff AS S
ON P.staff_id = S.staff_id
GROUP BY S.store_id
ORDER BY storewise_sale DESC;

-- How many rentals we have for each month

SELECT EXTRACT(MONTH FROM rental_date) AS month_num, EXTRACT(YEAR FROM rental_date) AS year_name, COUNT(*) AS no_of_rentals
FROM rental
GROUP BY EXTRACT(YEAR FROM rental_date), EXTRACT(MONTH FROM rental_date);

-- Reward users who have rented at least 30 times (with details of customers) // TRY WITH SUBQUERY

SELECT C.customer_id, CONCAT(C.first_name, " ", C.last_name) AS cust_name, C.email, COUNT(*) AS cust_transactions
FROM rental AS R LEFT JOIN customer AS C
ON R.customer_id = C.customer_id
GROUP BY C.customer_id
HAVING cust_transactions > 29
ORDER BY cust_transactions;

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

SELECT *
FROM film
WHERE LOWER(special_features) LIKE "%behind the scenes%";

-- unique movie ratings and number of movies 

SELECT rating, COUNT(*) AS total_count
FROM film
GROUP BY  rating
ORDER BY total_count DESC;

-- Could you please pull a count of titles sliced by rental duration?

SELECT rental_duration, COUNT(film_id) AS no_of_films
FROM film
GROUP BY rental_duration;

-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION

SELECT rating, COUNT(*) AS movie_count,
	MIN(length) AS min_len,
	ROUND(AVG(length), 0) AS avg_film_length, 
    MAX(length) AS max_len,
	ROUND(AVG(rental_duration), 0) AS avg_rental_duration
FROM film
GROUP BY rating
ORDER BY movie_count DESC;

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?

SELECT replacement_cost,
	ROUND(AVG(rental_rate), 2) AS avg_rental_cost,
	ROUND(MIN(rental_rate), 2) AS min_rental_rate, 
    ROUND(MAX(rental_rate), 2) AS max_rental_rate
FROM film
GROUP BY replacement_cost;


-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

SELECT C.customer_id, COUNT(*) AS no_of_rentals, C.first_name, C.last_name, C.email
FROM rental AS R LEFT JOIN customer AS C
ON R.customer_id = C.customer_id
GROUP BY C.customer_id
HAVING no_of_rentals < 15;

-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC
LIMIT 20;

-- CATEGORIZE MOVIES AS PER LENGTH

SELECT *,
	CASE
		WHEN length < 60 THEN "short_movie"
		WHEN length BETWEEN 60 AND 90 THEN "medium_movie"
		WHEN length > 90 THEN "long_movie"
        ELSE "ERROR"
	END AS movie_category
FROM film;

-- 8-5-25, Thursday;

-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

SELECT DISTINCT title,
	CASE
		WHEN rental_duration <= 4 THEN "rental_too_short"
        WHEN rental_rate >= 3.99 THEN "too_expensive"
        WHEN rating IN ("NC-17", "R") THEN "too_adult"
        WHEN length NOT BETWEEN 60 AND 90 THEN "too_short_or_long"
        WHEN LOWER(description) LIKE "%shark%" THEN "has_shark"
        ELSE "great_for_children"
    END AS fit_for_recommendation    
FROM film;


-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”

SELECT customer_id, first_name, last_name,
	CASE
		WHEN store_id = 1 AND active = 1 THEN "store_1_active"
		WHEN store_id = 1 AND active = 0 THEN "store_1_inactive"
		WHEN store_id = 2 AND active = 1 THEN "store_2_active"
		WHEN store_id = 2 AND active = 0 THEN "store_2_inactive"
        ELSE "ERROR"
    END AS isActive
FROM customer;

-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value associated with each item, and its inventory_id. Thanks!”

SELECT I.inventory_id, I.store_id, F.title, F.description
FROM inventory AS I INNER JOIN film AS F
ON I.film_id = F.film_id;

-- Actor first_name, last_name and number of movies

SELECT A.actor_id, A.first_name, A.last_name, COUNT(FA.film_id) AS total_films
FROM actor AS A LEFT JOIN film_actor AS FA
ON A.actor_id = FA.actor_id
GROUP BY A.actor_id
ORDER BY total_films DESC;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

SELECT *
FROM film_actor
ORDER BY film_id;

SELECT F.film_id, F.title, COUNT(FA.actor_id) AS actor_count 
FROM film_actor AS FA INNER JOIN film AS F
ON F.film_id = FA.film_id
GROUP BY F.film_id
ORDER BY actor_count;

-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”

SELECT A.actor_id, A.first_name, A.last_name, F.title
FROM actor AS A LEFT JOIN film_actor AS FA
ON A.actor_id = FA.actor_id LEFT JOIN film AS F
ON FA.film_id = F.film_id;

-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”

SELECT DISTINCT(F.title), F.description
FROM inventory AS I INNER JOIN film AS F
ON I.film_id = F.film_id
WHERE I.store_id = 2;

-- “We will be hosting a meeting with all of our staff and advisors soon. 
-- Could you pull one list of all staff and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”
-- WE HAVE TO STACK 2 TABLES. UNION

SELECT first_name, last_name, "Staff_Member" AS designation
FROM staff
UNION
SELECT first_name, last_name, "advisor" AS designation
FROM advisor;
