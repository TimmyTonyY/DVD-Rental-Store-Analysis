use sakila;

-- 1. What is the total number of rentals for the last 12 months?

select count(rental_id) as num_0f_rentals
from rental
where rental_date - interval '12' month;

-- 2. What is the total revenue generated from movie rentals for the last 12 months?

select round(sum(amount)) as total_revenue
from payment
where payment_date - interval 12 month ;

-- 3. What are the top-rented movies for the last 12 months?

select f.title, count(f.title) as top_movies
from rental r
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where rental_date - interval 12 month
group by 1
order by 2 desc ;

-- 4. who are the best performing customers

with best_customers as (
select concat_ws(' ',c.first_name,c.last_name) as fullname, r.rental_id
from rental r
join customer c on c.customer_id = r.customer_id
)
select fullname, count(fullname) as total_rent
from best_customers
group by 1
order by 2 desc;

-- 5. How many big spenders among our walk-in customers stay in any of our hot selling cities?

with spender_customers as (
select concat_ws(' ', c.first_name,c.last_name) as fullname, ci.city, p.amount
from rental r
join payment p on p.rental_id = r.rental_id
join customer c on c.customer_id = p.customer_id
join address a on a.address_id = c.address_id
join city ci on ci.city_id = a.city_id
)
select fullname, city, round(sum(amount)) as total_spender
from spender_customers
group by 1, 2
order by 3 desc;

-- 6. which genre of movies should we focus on?
with focus_movies as (
select r.rental_id, c.name
from rental r
join inventory i on i.inventory_id = r.inventory_id
join film_category fc on fc.film_id = i.film_id
join category c on c.category_id = fc.category_id
)
select name, count(name) as num_of_rental
from focus_movies
group by 1
order by num_of_rental desc;

-- 7. which rating of movie is popular among our frequent luxury customers?
		-- cte method
with cte_1 as (
select concat_ws(' ', c.first_name, c.last_name) as fullname, f.rating
from film f
join inventory i on i.film_id = f.film_id
join store s on s.store_id = i.store_id
join customer c on c.store_id = s.store_id
)
select rating, count(rating)
from cte_1
group by 1
order by 2 desc ;


      -- join method
select f.rating, count(f.rating) as popular_rate
from film f
join inventory i on i.film_id = f.film_id
join store s on s.store_id = i.store_id
join customer c on c.store_id = s.store_id
group by 1
order by popular_rate desc;

-- 8. What is the average rental duration for the last 12 months?

select  round(avg(f.rental_duration))
from rental r
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where r.rental_date - interval '12' month;

-- 9. What is the distribution of rental duration for the last 12 months?

select r.rental_id, f.rental_duration, rental_date
from rental r
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where rental_date - interval 12 month;

		-- or
        
select sum(f.rental_duration) as rental_distribution
from rental r
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where rental_date - interval 12 month;

-- 10. Which actors are the most popular among customers?

with popular_actors as (
select concat_ws(' ', a.first_name, a.last_name) as actor_name, 
       concat_ws(' ', c.first_name, c.last_name) as customer_name , f.title
from film f
join film_actor fa on fa.film_id = f.film_id
join inventory i on i.film_id = f.film_id
join store s on s.store_id = i.store_id
join customer c on c.store_id = s.store_id
join actor a on a.actor_id = fa.actor_id
)
select actor_name, count(actor_name) as popular_actor
from popular_actors
group by 1
order by popular_actor desc;

-- 11. Are there any seasonal trends in DVD rentals?

select year(rental_date) as year, 
       date_format(rental_date, '%M') as month_name, 
       count(month(rental_date)) as seasonal_sale
from rental
group by 1, 2;

-- 12. What is the relationship between customer age and rental behavior?

/* one and only one 
		to 
	one or many */
    
-- 13. What is the customer retention rate for the last 12 months?
 
select c.first_name, c.last_name, f.rental_rate
from customer c
join store s on s.store_id = c.store_id
join inventory i on i.store_id = s.store_id
join film f on f.film_id = i.film_id
join rental r on r.inventory_id = i.inventory_id
where rental_date - interval '12' month;

-- 14. what is the churn rate of our luxury customers?

with loss_customers as (
select c.customer_id, concat_ws(' ', c.first_name, c.last_name) as customer_name , amount
from customer c
join payment p on p.customer_id = c.customer_id
where amount = 0
),
total_customers as (
select count(customer_id) as num_of_customer
from customer
)
select customer_id, round(loss_customers.customer_id / total_customers.num_of_customer * 100) as churn_rate 
from loss_customers, total_customers;


