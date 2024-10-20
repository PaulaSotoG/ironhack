USE sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT COUNT(i.inventory_id) AS total_copies
FROM sakila.film AS f
JOIN sakila.inventory AS i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

-- List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT title, length
FROM sakila.film
WHERE length > (SELECT AVG(length) FROM sakila.film);


-- Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT a.first_name, a.last_name
FROM sakila.actor AS a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM sakila.film_actor AS fa
    JOIN sakila.film AS f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);


-- Bonus:

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

SELECT f.title
FROM sakila.film AS f
JOIN sakila.film_category AS fc ON f.film_id = fc.film_id
JOIN sakila.category AS c ON fc.category_id = c.category_id
WHERE c.name = 'Family';


-- Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT first_name, last_name, email
FROM sakila.customer
WHERE address_id IN (
    SELECT address_id
    FROM sakila.address
    WHERE city_id IN (
        SELECT city_id
        FROM sakila.city
        WHERE country_id = (
            SELECT country_id
            FROM sakila.country
            WHERE country = 'Canada'
        )
    )
);


-- Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT f.title
FROM sakila.film AS f
JOIN sakila.film_actor AS fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT fa.actor_id
    FROM sakila.film_actor AS fa
    GROUP BY fa.actor_id
    ORDER BY COUNT(fa.film_id) DESC
    LIMIT 1
);

-- Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_payments
FROM sakila.customer AS c
JOIN sakila.payment AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_payments DESC
LIMIT 1;


-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT p.customer_id, SUM(p.amount) AS total_amount_spent
FROM sakila.payment AS p
GROUP BY p.customer_id
HAVING SUM(p.amount) > (
    SELECT AVG(total_amount) 
    FROM (
        SELECT SUM(amount) AS total_amount
        FROM sakila.payment
        GROUP BY customer_id
    ) AS subquery
);


