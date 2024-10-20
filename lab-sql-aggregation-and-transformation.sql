-- You need to use SQL built-in functions to gain insights relating to the duration of movies:
-- 1.1 Determine the shortest and longest movie durations and name the values as max_duration and min_duration.

SELECT 
    IFNULL(MAX(length), 0) AS max_duration, 
    IFNULL(MIN(length), 0) AS min_duration
FROM sakila.film;
    
-- 1.2. Express the average movie duration in hours and minutes. Don't use decimals.
-- Hint: Look for floor and round functions.

SELECT round(avg(length), 0) as avg_duration
FROM sakila.film;

-- You need to gain insights related to rental dates:

-- 2.1 Calculate the number of days that the company has been operating.
-- Hint: To do this, use the rental table, and the DATEDIFF() function to subtract the earliest date in the rental_date column from the latest date.

SELECT DATEDIFF(
           (SELECT MAX(rental_date) FROM sakila.rental),  
           (SELECT MIN(rental_date) FROM sakila.rental)   
       ) AS days_operating;

-- 2.2 Retrieve rental information and add two additional columns to show the month and weekday of the rental. Return 20 rows of results.

SELECT rental_id, rental_date, customer_id, staff_id,
       DATE_FORMAT(CONVERT(rental_date, DATE), '%M') AS rental_month,  
       DATE_FORMAT(CONVERT(rental_date, DATE), '%W') AS rental_weekday  
FROM sakila.rental
LIMIT 20;

-- 2.3 Bonus: Retrieve rental information and add an additional column called DAY_TYPE with values 'weekend' or 'workday', depending on the day of the week.
-- Hint: use a conditional expression.

SELECT rental_id, rental_date, customer_id, staff_id,
       DATE_FORMAT(CONVERT(rental_date, DATE), '%W') AS rental_weekday, 
       CASE 
           WHEN DATE_FORMAT(CONVERT(rental_date, DATE), '%W') IN ('Saturday', 'Sunday') THEN 'weekend'
           ELSE 'workday'
       END AS day_type
FROM sakila.rental
LIMIT 20;

-- Next, you need to analyze the films in the collection to gain some more insights. Using the film table, determine:
-- 1.1 The total number of films that have been released.

SELECT COUNT(*)
FROM sakila.film;

-- 1.2 The number of films for each rating.

SELECT rating, COUNT(film_id) 
FROM sakila.film
GROUP BY rating;

-- 1.3 The number of films for each rating, sorting the results in descending order of the number of films. This will help you to better understand the popularity of different film ratings and adjust purchasing decisions accordingly.

SELECT rating, COUNT(*) AS film_count
FROM sakila.film
GROUP BY rating
ORDER BY film_count DESC;

-- Using the film table, determine:
-- 2.1 The mean film duration for each rating, and sort the results in descending order of the mean duration. Round off the average lengths to two decimal places. This will help identify popular movie lengths for each category.

SELECT rating, 
       ROUND(AVG(length), 2) AS mean_duration  
FROM sakila.film
GROUP BY rating
ORDER BY mean_duration DESC; 

-- 2.2 Identify which ratings have a mean duration of over two hours in order to help select films for customers who prefer longer movies.

SELECT rating, 
       ROUND(AVG(length), 2) AS mean_duration 
FROM sakila.film
GROUP BY rating
HAVING AVG(length) > 120 
ORDER BY mean_duration DESC;


-- Bonus: determine which last names are not repeated in the table actor.

SELECT last_name
FROM sakila.actor
GROUP BY last_name
HAVING COUNT(last_name) = 1;
