
-- 1a. Display the first and last names of all actors from the table actor.*/
SELECT first_name, last_name FROM sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT concat(first_name,' ',last_name) AS 'Actor Name'
FROM sakila.actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/
SELECT first_name, last_name, actor_id 
FROM sakila.actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN
SELECT * FROM sakila.actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM sakila.actor WHERE last_name LIKE '%LI%'
order by last_name , first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM sakila.country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE sakila.actor
ADD COLUMN middle_name VARCHAR(32) AFTER FIRST_NAME;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE sakila.actor
CHANGE COLUMN middle_name middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE ACTOR 
DROP COLUMN MIDDLE_NAME;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT distinct last_name,count(*) last_name_count
 FROM SAKILA.ACTOR
 group by last_name;
 
 -- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT distinct last_name,count(*) last_name_count
 FROM SAKILA.ACTOR
 group by last_name
HAVING count(*) >= 2;

/* 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
Write a query to fix the record.*/
SELECT * FROM actor
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)*/
UPDATE actor 
SET first_name = IF (first_name = 'HARPO', 'GROUCHO', 'MUCHO GROUCHO')
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM address
INNER JOIN staff ON 
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, sum(payment.amount) Total_Amount
FROM staff
INNER JOIN payment ON
staff.staff_id = payment.staff_id
WHERE month(payment_date) = 8 AND year(payment_date) = 2005
GROUP BY staff.first_name, staff.last_name;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(*) FROM sakila.inventory
WHERE film_id = (
SELECT film_id FROM film
WHERE title = 'Hunchback Impossible');

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, sum(payment.amount)
FROM customer
INNER JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY first_name, last_name
ORDER BY last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
SELECT film.title
FROM film
WHERE language_id =
(SELECT language_id FROM language
WHERE name ='English')
AND title LIKE 'K%' OR 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN 
	(
	SELECT actor_id FROM film_actor
	WHERE film_id = 
		(
		SELECT film_id FROM film
		WHERE title = 'Alone Trip'
        )
	);

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.*/
SELECT first_name, last_name, email FROM customer
	WHERE address_id IN (
SELECT address_id FROM address
	WHERE city_id IN (
SELECT city_id FROM city
	WHERE country_id = (
SELECT country_id FROM country
	WHERE country = 'Canada'
	)));
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title FROM film_list 
	WHERE category = 'Family'; 
    
-- 7e. Display the most frequently rented movies in descending order.
SELECT inventory.film_id, film.title, count(rental.rental_id) frequency FROM rental
INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
INNER JOIN film ON inventory.film_id = film.film_id
GROUP BY film_id
ORDER BY frequency DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM sakila.sales_by_store;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country FROM store
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id;

/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT category.name AS 'category_name' ,sum(payment.amount) gross_revenue FROM category
	INNER JOIN film_category ON  film_category.category_id = category.category_id
	INNER JOIN inventory ON film_category.film_id = inventory.film_id
	INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
	INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category_name
ORDER BY gross_revenue DESC LIMIT 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
CREATE VIEW sakila.top_genres AS
	SELECT category.name AS 'category_name' ,sum(payment.amount) gross_revenue FROM category
	INNER JOIN film_category ON  film_category.category_id = category.category_id
	INNER JOIN inventory ON film_category.film_id = inventory.film_id
	INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
	INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category_name
ORDER BY gross_revenue DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.top_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW sakila.top_genres;