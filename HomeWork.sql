-- Homework for SQL --Ed McCoy
## Homework Assignment
use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.  
SELECT first_name, last_name
  from actor;
  

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT UPPER(CONCAT(first_name, "   ",last_name ) )AS 'Actor Name'
  from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
from actor
WHERE first_name = "Joe"; 
 
-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT UPPER(last_name)
from actor
WHERE last_name LIKE "%GEN%";
  	
-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT  first_name, UPPER(last_name)
from actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;


-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');


-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER table actor
add column middle_name varchar(50) after first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER table actor
MODIFY COLUMN middle_name BLOB;

-- 3c. Now delete the `middle_name` column.
ALTER table actor
DROP COLUMN middle_name;


-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name ,count(last_name) as counter
from actor
group by last_name;


  	
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
 select last_name ,count(last_name) as counter
from actor
group by last_name
having counter >= 2; 
	
-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor 
set first_name = "HARPO"
where first_name = "GROUCHO" AND last_name = "WILLIAMS";


-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
update actor 
set first_name = "GROUCHO"
where first_name = "HARPO" AND last_name = "WILLIAMS";
#what is the requiremnt really saying ? I just reverted back


-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? 

  -- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

SHOW CREATE TABLE actor;


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select first_name, last_name
from staff
join address on address.address_id  = staff.address_id;



-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
select s.first_name, s.last_name, sum(p.amount) as total
from (payment p
join staff s on s.staff_id = p.staff_id)
where p.payment_date between  '2005-08-01 00:00:00' AND '2005-9-01 00:00:00'
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
 select film.title , count(fa.actor_id) as numberOfActors
 from (film_actor fa
 join film  on film.film_id = fa.film_id )
 group by fa.film_id;
 
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select f.title ,count(*) as NumInInventory
from ( film f
join inventory i on f.film_id = i.film_id)
where f.title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select c.last_name, sum(p.amount) as total
from customer c
join payment p on c.customer_id = p.customer_id
group by c.last_name
order by c.last_name ASC;
--
  	##![Total amount paid](Images/total_payment.png)
--

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
select a.title 
from
(
select m.title 
from film m
where m.title like "K%" OR m.title like "Q%"
)a;



-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name
from actor
where actor_id in 
                  (select actor_id from film_actor where  film_id in (
                                                                       (select film_id
                                                                         from film 
																		where title = 'Alone Trip')));

  
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email, country.country
from customer c
join address a on a.address_id  = c.address_id
join city  cy on  a.city_id = cy.city_id
join country on country.country_id = cy.country_id
where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select title, rating
from film
where rating not in ('R', 'MA');



-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(p.rental_id) as 'NumberRented'
from payment p
join rental rent on p.rental_id = rent.rental_id
join inventory i on i.inventory_id = rent.inventory_id
join film f on f.film_id = i.film_id
group by f.title
order by count(p.rental_id) DESC;

  	
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id , sum(p.amount) as 'Total'
from payment p
join staff sf on p.staff_id = sf.staff_id
join store s on s.store_id = sf.store_id
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, cy.city, c.country
from store s
join address a on s.address_id = a.address_id  
join city cy on cy.city_id = a.city_id
join country c on  c.country_id = cy.country_id;
	

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select cat.name, count(cat.category_id)  as 'NumOfGenres'
from category cat
join film_category fc on cat.category_id = fc.category_id
group by cat.name 
ORDER BY count(cat.category_id) DESC
LIMIT 5;




  	
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top5 as
select cat.name, count(cat.category_id)  as 'NumOfGenres'
from category cat
join film_category fc on cat.category_id = fc.category_id
group by cat.name 
ORDER BY count(cat.category_id) DESC
LIMIT 5;
  	
-- 8b. How would you display the view that you created in 8a?
select * from top5;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top5;

### Appendix: List of Tables in the Sakila DB

-- A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

/*******
```sql
	'actor'
	'actor_info'
	'address'
	'category'
	'city'
	'country'
	'customer'
	'customer_list'
	'film'
	'film_actor'
	'film_category'
	'film_list'
	'film_text'
	'inventory'
	'language'
	'nicer_but_slower_film_list'
	'payment'
	'rental'
	'sales_by_film_category'
	'sales_by_store'
	'staff'
	'staff_list'
	'store'
```
******/

