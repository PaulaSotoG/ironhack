-- Use the sakila database
USE sakila;

-- Display all available tables in the Sakila database
SHOW FULL TABLES;

-- Retrieve all the data from the actor table
SELECT * 
FROM actor;

-- Retrieve all the data from the film table
SELECT * 
FROM film;

-- Retrieve all the data from the customer table
SELECT * 
FROM customer;

-- Retrieve the titles of all films from the film table
SELECT DISTINCT title
FROM film;

-- Retrieve the list of languages used in films, aliased as language from the language table
SELECT name AS language
FROM language;

-- Retrieve the first names of all employees from the staff table
SELECT first_name 
FROM staff;

-- Retrieve unique release years from the film table
SELECT DISTINCT release_year
FROM film;

-- Determine the number of stores that the company has
SELECT COUNT(store_id)
FROM store;

-- Determine the number of employees that the company has
SELECT COUNT(staff_id)
FROM staff;

-- Determine how many films have been rented
SELECT COUNT(rental_id)
FROM rental;

-- Determine how many films are still available for rent (i.e., have not been returned)
SELECT COUNT(*) 
FROM rental
WHERE return_date IS NULL;

-- Determine how many films are available (count of all films in the database)
SELECT COUNT(*)
FROM film;

-- Retrieve the number of distinct last names of the actors in the database
SELECT COUNT(DISTINCT last_name)
FROM actor;

-- Retrieve the 10 longest films
SELECT title, length
FROM film
ORDER BY length DESC
LIMIT 10;

-- Retrieve all actors with the first name "SCARLETT"
SELECT * 
FROM actor 
WHERE first_name = 'SCARLETT';

-- BONUS: Retrieve all movies with ARMAGEDDON in their title and a duration longer than 100 minutes
SELECT title, length 
FROM film 
WHERE title LIKE '%ARMAGEDDON%' 
AND length > 100;

-- BONUS: Determine the number of films that include Behind the Scenes content
SELECT COUNT(*)
FROM film
WHERE special_features LIKE '%Behind the Scenes%';