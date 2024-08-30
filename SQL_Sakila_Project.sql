use sakila;

-- **** Select Statements ************************************************************************************

-- 1
select 
	customer.first_name,
    customer.last_name,
    customer.email,
    address.district
from customer
join address on customer.address_id = address.address_id
where address.district = 'California';


-- 2
select
	title,
    rental_duration
from film
where rental_duration > 5;


-- 3
select
	first_name,
    last_name
from actor
where last_name like "D%";


-- 4
select
	count(store.store_id) as total_number_stores,
    address.address
    from store
    join address on address.address_id = store.address_id
    group by store.store_id;


-- 5
select 
	title,
    rental_rate,
    release_year
from film
order by rental_rate
limit 5;


-- 6
select
	first_name,
    last_name,
    sum(payment.amount) as total_amount_spent
from customer
join payment on payment.customer_id = customer.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total_amount_spent desc;


-- 7
select 
	avg(rental_duration) as average_rental_duration
from film;


-- 8
select
	first_name,
    last_name,
    count(rental.rental_id) as number_of_rentals
    from customer
    join rental on customer.customer_id = rental.customer_id
    group by customer.customer_id, customer.first_name, customer.last_name
    having number_of_rentals > 10;


-- 9
select
	staff.first_name,
    staff.last_name,
    address.address
    from staff
    join store on store.store_id = staff.store_id
    join address on address.address_id = store.address_id;


-- 10
select
	first_name,
    last_name,
    rental.rental_date as rental_date,
    rental.return_date as return_rate
    from customer
    join rental on rental.customer_id = customer.customer_id
    join inventory on inventory.inventory_id = rental.inventory_id
    join film on film.film_id = inventory.film_id
    order by customer.last_name, customer.first_name, rental.rental_date;


-- 11
select
	category.name as category_name,
    count(film.film_id) as number_of_films
from category
join film_category on film_category.category_id = category.category_id
join film on film.film_id = film_category.film_id
group by category.name
order by number_of_films desc;


-- 12
select
	customer.customer_id,
	customer.first_name,
    customer.last_name
from customer
where customer.customer_id not in (
	select rental.customer_id
    from rental
    where rental.rental_date >= curtime() - interval 6 month
);


-- 13
select
	address.address,
    sum(payment.amount) as total_revenue
from store
join address on store.address_id = address.address_id
join inventory on store.store_id = inventory.store_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
group by store.store_id, address.address_id
order by total_revenue desc;


-- 14
select
	title,
    replacement_cost,
    rental_rate
from film
where replacement_cost > 20;


-- 15
select
	customer.first_name,
    customer.last_name,
    sum(payment.amount) as total_amount_spent
from customer
join payment on customer.customer_id = payment.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
limit 5;


-- 16
select
	film.title,
    count(rental.rental_id) as times_rented
from film
join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
group by film.film_id, film.title
order by times_rented desc
limit 10;


-- 17
select
	actor.first_name,
    actor.last_name,
    count(distinct film_category.category_id) as number_of_categories
from actor
join film_actor on actor.actor_id = film_actor.actor_id
join film_category on film_actor.film_id = film_category.film_id
group by actor.actor_id, actor.first_name, actor.last_name
having count(distinct film_category.category_id) > 3
order by number_of_categories desc;


-- 18
select
	category.name as category_name,
    sum(payment.amount) as total_revenue
from category
join film_category on film_category.category_id = category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.category_id, category.name
ORDER BY total_revenue DESC
LIMIT 1;


-- 19
select
    customer.first_name, 
    customer.last_name, 
    year(payment.payment_date) as year, 
    sum(payment.amount) as total_amount_spent
from customer
join payment on customer.customer_id = payment.customer_id
group by customer.customer_id, customer.first_name, customer.last_name, year(payment.payment_date)
order by customer.last_name, customer.first_name, year;


-- 20
select
	title,
    rental_rate,
    rank() over(order by rental_rate desc) as _rank_
from film
order by rental_rate desc
limit 10;


-- 21
select
	film.title,
    count(rental.rental_id) as rental_count,
    percent_rank() over(order by count(rental_id) asc) as percentile_rank
from film
join inventory on inventory.film_id = film.film_id
join rental on rental.inventory_id = inventory.inventory_id
group by film.film_id, film.title
order by percentile_rank;


-- 22
select
	store.store_id,
    payment.payment_date,
    sum(payment.amount) over(partition by store.store_id order by payment.payment_date asc) as cumulative_revenue
from store
join staff on store.store_id = store.store_id
join payment on staff.staff_id = payment.staff_id
order by store.store_id, payment.payment_date;


-- 23
select
	customer.first_name,
    customer.last_name,
    sum(payment.amount),
    rank() over(order by sum(payment.amount) desc) as payment_rank
from customer
join payment on customer.customer_id = payment.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by payment_rank;


-- 24
with Lead_Table as(
select
	film.film_id,
    rental.rental_date as rental_start_date,
    rental.return_date as rental_end_date,
    lead(rental.rental_date) over (partition by film_id order by rental.rental_date) as next_rental_start_date
    from film
    join inventory on film.film_id = inventory.film_id
    join rental on inventory.inventory_id = rental.inventory_id
    order by 1, 2
)

select
	film_id,
    rental_start_date,
    rental_end_date,
    datediff(next_rental_start_date, rental_end_date) as gap_duration
from Lead_Table
where datediff(next_rental_start_date, rental_end_date) > 0;


-- **** Views ************************************************************************************************
-- 25
create view high_spending_customers as select
	customer.first_name,
    customer.last_name,
    sum(payment.amount) as amount_spent
from customer
join payment on customer.customer_id = payment.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
having sum(payment.amount) > 100
order by amount_spent desc;


-- 26
SELECT 
    film.film_id,
    film.title
FROM film
WHERE film.film_id IN (
    SELECT DISTINCT inventory.film_id
    FROM rental
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    WHERE rental.rental_date >= CURDATE() - INTERVAL 30 DAY
);


-- 27
create view available_films as
select 
    film.title as film_title,
    category.name as category_name,
    address.address as store_location
from inventory
join film on inventory.film_id = film.film_id
join film_category on film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
join store on inventory.store_id = store.store_id
join address on store.address_id = address.address_id
where inventory.inventory_id not in (
    select inventory_id 
    from rental 
    where return_date is null
);


-- 28
create view customer_lookup as 
select
	customer_id,
	first_name,
    last_name,
    email as email_address
from customer
order by customer_id;


-- 29
create view film_lookup as
select
	film_id,
	title as film_title,
    description as film_description
from film
order by film_id;


-- 30
create view actor_lookup as
select
	actor_id,
	first_name,
    last_name
from actor
order by actor_id;


-- 31
create view store_lookup as
select
	store_id,
    city.city,
    address.postal_code
from store
join address on store.address_id = address.address_id
join city on address.city_id = city.city_id
order by store_id;


-- 32
create view film_language_lookup as
select
	film_id,
	title as film_title,
    language.name as film_language
from film
join language on film.language_id = language.language_id
order by film_id;


-- 33
create view customer_rental_summarry_lookup as
select
	customer.customer_id,
    customer.first_name,
    customer.last_name,
    count(rental.rental_id) as total_rentals,
    sum(payment.amount) as total_amount_spent
from customer
join rental on customer.customer_id = rental.customer_id
join payment on rental.rental_id = payment.rental_id
group by customer.customer_id, customer.first_name, customer.last_name
order by customer_id;


-- 34
create view film_category_lookup as
select
	category.name as film_category,
    count(film.film_id) as total_films,
    avg(film.rental_rate) as average_rental_rate
from film
join film_category on film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
group by category.name;


-- 35
create view staff_members_lookup as
with total_rentals_table as(
	select
		staff.staff_id,
        count(rental.rental_id) as total_rentals
	from staff
	join rental on staff.staff_id = rental.staff_id
	group by 1
),

total_revenue as(
	select
		staff.staff_id,
        sum(payment.amount) as total_revenue
	from staff
    join payment on staff.staff_id = payment.staff_id
    group by 1
)

select
	staff.first_name,
    staff.last_name,
    total_rentals,
    total_revenue
from staff
left join total_rentals_table on staff.staff_id = total_rentals_table.staff_id
left join total_revenue on staff.staff_id = total_revenue.staff_id;


-- 36
create view high_rated_films as
select
	title as film_title,
    rental_rate,
    release_year
from film
where rental_rate > 3.99;


-- 37
create view film_availability as
select 
    film.title as film_title,
    COUNT(inventory.inventory_id) as total_copies,
    COUNT(rental.rental_id) as copies_rented_out
from film
join inventory on film.film_id = inventory.film_id
left join rental on inventory.inventory_id = rental.inventory_id and rental.return_date is null
group by film.film_id, film.title;


-- 38
create view customer_lifetime_value as
select
    customer.first_name as FirstName,
    customer.last_name as LastName,
    COUNT(rental.rental_id) as TotalRentals,
    SUM(payment.amount) as TotalAmountSpent,
    AVG(payment.amount) as AverageAmountSpentPerRental,
    MIN(rental.rental_date) as FirstRentalDate,
    MAX(rental.rental_date) as MostRecentRentalDate
from
    customer
    inner join rental on customer.customer_id = rental.customer_id
    inner join payment on rental.rental_id = payment.rental_id
group by
    customer.customer_id
order by
    TotalAmountSpent desc;


-- 39
create view film_statistics as
select 
    film.title as FilmTitle,
    category.name as CategoryName,
    count(rental.rental_id) as TotalRentals,
    sum(payment.amount) as TotalRevenue,
    avg(film.length) as AverageRentalDuration,
    count(distinct rental.customer_id) as DistinctCustomers,
    film.replacement_cost as ReplacementCost,
    (sum(payment.amount) - film.replacement_cost) as Profitability
from 
    film
    inner join film_category on film.film_id = film_category.film_id
    inner join category on film_category.category_id = category.category_id
    inner join inventory on film.film_id = inventory.film_id
    inner join rental on inventory.inventory_id = rental.inventory_id
    inner join payment on rental.rental_id = payment.rental_id
group by 
    film.film_id, category.category_id
order by 
    Profitability desc;


-- 40
create view store_detailed_statistics as
with rental_calculations as
( 
    select
        store.store_id,
        count(rental.rental_id) as total_rentals,
        count(distinct rental.customer_id) as number_of_customers
    from store    
    left join inventory
        on inventory.store_id = store.store_id
    left join rental
        on rental.inventory_id = inventory.inventory_id
    group by 1
),

-- Address Finder returns: whole address
address_finder as (
    select
        store.store_id,
        concat(country.country, ", ", address.district, ", ", city.city,
        ", ", address.address, ", ", address.postal_code) as store_address
    from store
    join address
        on store.address_id = address.address_id
    join city
        on address.city_id = city.city_id
    join country
        on city.country_id = country.country_id  
    group by 1
),

-- Payment Calculation returns: total_revenue
payment_calculation as (
    select
        store.store_id,
        sum(payment.amount) as total_revenue
    from store
    left join inventory
        on inventory.store_id = store.store_id
    left join rental
        on rental.inventory_id = inventory.inventory_id
    left join payment
        on payment.rental_id = rental.rental_id
    group by 1
),

most_rented_3_films as (
    select
        store.store_id,
        film.title,
        count(rental.rental_id) as rental_count,
        row_number() over (partition by store.store_id order by count(rental.rental_id) desc) as rank_of_films
    from film
    left join inventory
        on inventory.film_id = film.film_id
    left join rental
        on rental.inventory_id = inventory.inventory_id
    left join store
        on store.store_id = inventory.store_id
    group by 1,2
)

select 
    store.store_id,
    af.store_address,
    ifnull(rc.total_rentals, 0) as total_rentals,
    ifnull(pc.total_revenue, 0) as total_revenue,
    ifnull(pc.total_revenue / rc.total_rentals, 0) as avg_revenue_per_rental,
    ifnull(rc.number_of_customers, 0) as number_of_customers,
    group_concat(mf.title order by mf.rank_of_films desc separator ', ') as three_most_rented_films
from store
left join address_finder af
    on af.store_id = store.store_id
left join rental_calculations rc
    on rc.store_id = store.store_id
left join payment_calculation pc
    on pc.store_id = store.store_id
left join most_rented_3_films mf
    on mf.store_id = store.store_id
        and mf.rank_of_films <= 3
group by 1,2,3,4,5,6;

select * from store_detailed_statistics;


-- **** Triggers *********************************************************************************************

-- 41
delimiter //
create trigger active_customer
before insert on customer
for each row
begin
	if new.active is null then
    set new.active = 1;
    end if;
end//
delimiter ;


-- 42
delimiter //
create trigger capitalize_name
before insert on customer
for each row
begin
	set new.first_name = upper(new.first_name);
end//
delimiter ;


-- 43
create table customer_log(
	log_id int auto_increment primary key,
    customer_id int,
    first_name varchar(50),
    last_name varchar(50),
    insert_date timestamp default current_timestamp
);
delimiter //
create trigger log_new_customer
after insert on customer
for each row
begin
	insert into customer_log(customer_id, first_name, last_name, insert_date)
    values (new.customer_id, new.first_name, new.last_name, now());
end//
delimiter ;


-- 44
create table rental_rate_log (
    log_id int auto_increment primary key,
    film_id int,
    old_rental_rate decimal(4,2),
    new_rental_rate decimal(4,2),
    change_date timestamp default current_timestamp
);

delimiter //

create trigger log_rental_rate_increase
after update on film
for each row
begin
    if new.rental_rate > old.rental_rate then
        insert into rental_rate_log (film_id, old_rental_rate, new_rental_rate, change_date)
        values (new.film_id, old.rental_rate, new.rental_rate, NOW());
    end if;
end//

delimiter ;


-- 45
delimiter //
create trigger update_last_update_column
before update on customer
for each row
begin
	set new.last_update = now();
end//

delimiter ;


-- 46
create table rental_deletions_log(
	log_id int auto_increment primary key,
    rental_id int,
    deletion_date timestamp default current_timestamp,
    staff_id int
);

delimiter //
create trigger log_rental_deletion
after delete on rental
for each row
begin
	insert into rental_deletions_log(rental_id, deletion_date, staff_id)
    values (old.rental_id, now(), old.staff_id);
end//

delimiter ;


-- 47
delimiter //
create trigger return_date_update
after insert on payment
for each row
begin
	update rental
		set rental.return_date = now()
		where rental_id = new.rental_id
        and return_date is null;
end//

delimiter ;


-- 48
create table high_rated_films_log(
	log_id int auto_increment primary key,
    film_title varchar(128),
    rental_rate decimal(4, 2),
    insertion_date timestamp default current_timestamp
);

delimiter //
create trigger high_rated_film_addition_log
after insert on film
for each row
begin
	if new.rental_rate > 4.99 then
    insert into high_rated_films_log(film_title, rental_rate, insertion_date)
    values (new.title, new.rental_rate, now());
    end if;
end//

delimiter ;


-- 49
create table customer_table_email_change_log(
	log_id int auto_increment primary key,
    customer_id smallint unsigned,
    old_email varchar(50),
    new_email varchar(50),
    date_of_change timestamp default current_timestamp,
    foreign key (customer_id) references customer(customer_id)
);

delimiter //
create trigger log_email_change
before update on customer
for each row
begin
	if old.email <> new.email then
		insert into customer_table_email_change_log(customer_id, old_email, new_email, date_of_change)
        values(old.customer_id, old.email, new.email, now());
	end if;
end//

delimiter ;


-- **** Stored Procedures ************************************************************************************

-- 50
delimiter //
create procedure get_customer_by_last_name(in input_last_name varchar(45))
begin
	select 
		customer_id, 
        first_name, 
        last_name, 
        email,
        address.address
	from customer
    join address on customer.address_id = address.address_id
    where last_name = input_last_name;
end//
delimiter ;


-- 51
delimiter //
create procedure get_films_by_category(in input_film_category varchar(25))
begin
	select film.title, film.description, film.rental_rate
    from film
    join film_category on film.film_id = film_category.film_id
    join category on film_category.category_id = category.category_id
    where category.name = input_film_category;
end//
delimiter ;


-- 52
delimiter //
create procedure customer_email_update(in input_customer_id smallint, in new_email varchar(50))
begin
	update customer
    set email = new_email
    where customer_id = input_customer_id;
end//
delimiter ;


-- 53
delimiter //
create procedure get_rental_count_for_store(in input_store_id tinyint, out total_rentals int)
begin
	select
		count(rental.rental_id) into total_rentals
	from rental
    join inventory on rental.inventory_id = inventory.inventory_id
    join store on inventory.store_id = store.store_id
    where store_id = input_store_id;
end//
delimiter ;


-- 54
delimiter //
create procedure get_films_by_language(in input_language_id tinyint)
begin
	select 
		title, 
        description
	from film
    where language_id = input_language_id;
end//
delimiter ;


-- 55
delimiter //
create procedure get_customers_from_city(in input_city varchar(50))
begin
	select 
		count(customer_id) as total_customers
    from customer
    join address on customer.address_id = address.address_id
    join city on address.city_id = city.city_id
    where city.city = input_city;
end//
delimiter ;


-- 56
delimiter //

create procedure get_rental_revenue_by_month_year(
    in input_month tinyint,
    in input_year year,
    out total_revenue decimal(10,2)
)
begin
    select 
        sum(p.amount) into total_revenue
    from 
        payment p
    where 
        month(p.payment_date) = input_month
        and year(p.payment_date) = input_year;
end//

delimiter ;


-- 57
delimiter //
create procedure get_total_rentals_by_any_customer(in input_customer_id smallint, out total_rentals int)
begin
	select
		count(rental.rental_id) as total_rentals
	from rental
    join customer on rental.customer_id = customer.customer_id
    where customer.customer_id = input_customer_id;
end//
delimiter ;

set @total_rentals = 0;
call get_total_rentals_by_any_customer(1, @total_rentals);
select @total_rentals as total_rentals;


-- 58
delimiter //
create procedure get_film_availability(
    in input_film_id int,
    out available_copies int,
    out availability_message varchar(50)
)
begin
    -- Calculate the number of available copies of the film
    select 
        count(i.inventory_id) into available_copies
    from 
        inventory i
    where 
        i.film_id = input_film_id
        and i.inventory_id not in (
            select r.inventory_id
            from rental r
            where r.return_date is null
        );

    -- Set the availability message based on the count of available copies
    if available_copies > 0 then
        set availability_message = 'The film is available.';
    else
        set availability_message = 'The film is out of stock.';
    end if;
end//

delimiter ;

set @available_copies = 0;
set @availability_message = "";
call get_film_availability(1, @available_copies, @availability_message);
select 
	@available_copies as available_copies,
    @availability_message as availability_message;


-- 59
delimiter //

create procedure get_customer_full_name(
    in input_customer_id int,
    out full_name varchar(100)
)
begin
    select concat(customer.first_name, ' ', customer.last_name) into full_name
    from customer
    where customer.customer_id = input_customer_id;
end//

delimiter ;

set @full_name = "";
call get_customer_full_name(3, @full_name);
select @full_name as full_name;

-- 60
delimiter //
create procedure get_number_of_films_by_category(in input_category_id tinyint, out total_films int)
begin
	select
		count(inventory.film_id) into total_films
	from inventory
    join film_category on inventory.film_id = film_category.film_id
    join category on film_category.category_id = category.category_id
    where category.category_id = input_category_id;
end//
delimiter ;

set @total_films = 0;
call get_number_of_films_by_category(1, @total_films);
select @total_films as total_films;