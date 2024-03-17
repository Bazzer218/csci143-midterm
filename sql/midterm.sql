/* PROBLEM 1:
 *
 * The Office of Foreign Assets Control (OFAC) is the portion of the US government that enforces international sanctions.
 * OFAC is conducting an investigation of the Pagila company to see if you are complying with sanctions against North Korea.
 * Current sanctions limit the amount of money that can be transferred into or out of North Korea to $5000 per year.
 * (You don't have to read the official sanctions documents, but they're available online at <https://home.treasury.gov/policy-issues/financial-sanctions/sanctions-programs-and-country-information/north-korea-sanctions>.)
 * You have been assigned to assist the OFAC auditors.
 *
 * Write a SQL query that:
 * Computes the total revenue from customers in North Korea.
 *
 * NOTE:
 * All payments in the pagila database occurred in 2022,
 * so there is no need to do a breakdown of revenue per year.
 */

select country, sum(amount) as "Total Revenue"
from payment
join customer using (customer_id)
join address using (address_id)
join city using (city_id)
join country using (country_id)
where country = 'North Korea'
group by country
;



/* PROBLEM 2:
 *
 * Management wants to hire a family-friendly actor to do a commercial,
 * and so they want to know which family-friendly actors generate the most revenue.
 *
 * Write a SQL query that:
 * Lists the first and last names of all actors who have appeared in movies in the "Family" category,
 * but that have never appeared in movies in the "Horror" category.
 * For each actor, you should also list the total amount that customers have paid to rent films that the actor has been in.
 * Order the results so that actors generating the most revenue are at the top.
 */

select 
actor.first_name, 
actor.last_name,
sum(payment.amount) as total_revenue
from 
actor
join 
film_actor on actor.actor_id = film_actor.actor_id
join 
film on film_actor.film_id = film.film_id
join 
inventory on film.film_id = inventory.film_id
join 
rental on inventory.inventory_id = rental.inventory_id
join 
payment on rental.rental_id = payment.rental_id
join 
film_category on film.film_id = film_category.film_id
join 
category on film_category.category_id = category.category_id
where 
category.name = 'Family'
and actor.actor_id not in (
    select 
    actor_id
    from 
    actor
    join 
    film_actor using(actor_id)
    join 
    film using(film_id)
    join 
    film_category using(film_id)
    join 
    category using(category_id)
    where 
    category.name = 'Horror'
)
group by 
actor.actor_id
order by 
total_revenue desc;





/* PROBLEM 3:
 *
 * You love the acting in AGENT TRUMAN, but you hate the actor RUSSELL BACALL.
 *
 * Write a SQL query that lists all of the actors who starred in AGENT TRUMAN
 * but have never co-starred with RUSSEL BACALL in any movie.
 */

select first_name, last_name 
from film
join film_actor using(film_id)
join actor using(actor_id)
where title = 'AGENT TRUMAN'
and (first_name ||' '|| last_name) not in 
(
    select distinct(first_name ||' '|| last_name) as "Actor Name"
from actor a1
join film_actor fa1 on a1.actor_id = fa1.actor_id
join film f1 on fa1.film_id = f1.film_id
where
(a1.first_name ||' '|| a1.last_name) != 'RUSSELL BACALL' and
f1.title in (
select title from film
join film_actor using(film_id)
join actor using(actor_id)
where first_name = 'RUSSELL' and last_name = 'BACALL')
order by "Actor Name")
order by last_name, first_name;





/* PROBLEM 4:
 *
 * You want to watch a movie tonight.
 * But you're superstitious,
 * and don't want anything to do with the letter 'F'.
 * List the titles of all movies that:
 * 1) do not have the letter 'F' in their title,
 * 2) have no actors with the letter 'F' in their names (first or last),
 * 3) have never been rented by a customer with the letter 'F' in their names (first or last).
 *
 * NOTE:
 * Your results should not contain any duplicate titles.
 */

select distinct film.title
from customer
join rental using(customer_id)
join inventory using(inventory_id)
join film using(film_id)
join film_actor using(film_id)
join actor using(actor_id)
where film.title not ilike '%f%'
and (actor.first_name ||' '|| actor.last_name) not in
(
    select distinct(actor.first_name ||' '|| actor.last_name) as "Actor Name"
from actor
where (actor.first_name ||' '|| actor.last_name) not ilike '%f%')

and (customer.first_name ||' '|| customer.last_name) not in
(
    select distinct(customer.first_name ||' '|| customer.last_name) as "Customer Name"
from customer
where (customer.first_name ||' '|| customer.last_name) not ilike '%f%') 
order by film.title
;




