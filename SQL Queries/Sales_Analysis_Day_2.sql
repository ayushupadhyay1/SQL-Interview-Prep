use sales_analysis;

-- ============================================================ EASY ===========================================================================

-- Query-1) List all product names and their types.
select
	product_name,
    product_type
from products;

-- Query-2) Show all sales records that happened in 2024.
select *
from sales
where year(sale_date) = 2024;

-- Query-3) How many sales reps are there in each region?
select
	region,
    count(distinct sales_rep_id) as sales_rep_count
from sales_reps 
group by region
order by sales_rep_count desc;

-- Query-4) What is the total quantity of products sold by each sales rep?
select 
	s.sales_rep_id,
    sr.rep_name,
    sum(s.quantity) as total_quantity
from sales_Reps as sr
join sales as s
	on s.sales_rep_id = sr.sales_rep_id
group by s.sales_rep_id, sr.rep_name
order by total_quantity desc;


-- Query-5) Get customer names and the total number of purchases they made (count of rows in sales table).
select 
	s.customer_id,
    c.customer_name,
    count(s.sale_id) as total_number_of_purchases
from customers as c
join sales as s
	on c.customer_id = s.customer_id
group by s.customer_id, c.customer_name
order by total_number_of_purchases desc;

-- ============================================================ MEDIUM ===========================================================================

-- Query-6) Calculate the total revenue (considering discounts) per product. Formula: (quantity * price_per_unit) - discount_applied
select 
	s.product_id,
    p.product_name,
    round(sum(s.quantity * p.price_per_unit - s.discount_applied),0) as revenue_after_discount
from products as p
join sales as s	
	on p.product_id = s.product_id
group by s.product_id, p.product_name
order by revenue_after_discount desc;


-- Query-7) Find customers who bought more than 20 units in total (across all products).
select 
	s.customer_id,
    c.customer_name,
    sum(s.quantity) as total_quantity
from customers as c
join sales as s
	on c.customer_id = s.customer_id
group by s.customer_id, c.customer_name
having sum(s.quantity) > 20
order by total_quantity;

-- Query-8) List all sales where the discount applied was more than 10% of the total sale value.
SELECT
    s.*,
    ROUND((s.discount_applied / (s.quantity * p.price_per_unit)) * 100, 2) AS discount_percentage
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE (s.discount_applied / (s.quantity * p.price_per_unit)) > 0.10;


-- Query-9) Get each product and show the number of customers who have purchased it.
select
	s.product_id,
    p.product_name,
    count(distinct s.customer_id) as total_customers
from products as p
join sales as s
	on p.product_id = s.product_id
group by s.product_id, p.product_name
order by total_customers desc;


-- Query-10) List the top 3 countries by total revenue generated.
select 
	c.country,
    sum((s.quantity * p.price_per_unit)) as total_revenue
from customers as c
join sales as s
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id
group by c.country
order by total_revenue desc
limit 3;

-- ============================================================ HARD ===========================================================================

-- Query-11) Using a window function, calculate the running total revenue for each customer ordered by sale date.
select 
	s.customer_id,
    c.customer_name,
    (s.quantity * p.price_per_unit) as revenue,
    s.sale_date,
    sum((s.quantity * p.price_per_unit)) over (partition by s.customer_id order by s.sale_date) as total_running_revenue
from customers as c
join sales as s
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id;


-- Query-12) Find the average time (in days) between account creation and first purchase for each customer.
with customers_with_first_purchase_date as
(
select 
	s.customer_id,
    c.customer_name,
    c.account_created_date,
    min(s.sale_date) as first_purchased_date
from customers as c
join sales as s
	on c.customer_id = s.customer_id
group by s.customer_id, c.customer_name, c.account_created_date
)
select
	customer_id,
    customer_name,
    account_created_date,
    first_purchased_date,
    datediff(first_purchased_date, account_created_date) as difference_in_duration
from customers_with_first_purchase_date
order by difference_in_duration desc;

-- Query-13) Use a CTE to find the total revenue per customer, then return only those who spent more than the average revenue of all customers.
with customer_with_total_revenue as
(
select 
	s.customer_id,
    c.customer_name,
    sum(s.quantity * p.price_per_unit) as total_revenue
from customers as c
join sales as s
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id
group by s.customer_id, c.customer_name
), 
average_revenue as 
(
select 
	round(avg(total_revenue),2) as average_revenue
from customer_with_total_revenue as s

)
select
	c.customer_id,
    c.customer_name
from customer_with_total_revenue as c
cross join average_revenue as a
where c.total_revenue > a.average_revenue;
	

-- Query-14) Which sales rep has the highest average discount per sale?
select 
	s.sales_rep_id,
	sr.rep_name,
    round(avg(s.discount_applied),2) as average_discount
from sales_reps as sr
join sales as s
	on sr.sales_rep_id = s.sales_rep_id
group by s.sales_rep_id, sr.rep_name
order by average_discount desc
limit 1;


-- Query-15) List all customers who have only bought “Add-on” products and no “Subscription” products.
select 
	s.customer_id,
    c.customer_name
from customers as c
join sales as s
	on s.customer_id = c.customer_id
join products as p
	on p.product_id = s.product_id
group by s.customer_id, c.customer_name
having sum(case when p.product_type = 'subscription' then 1 else 0 end) = 0
and sum(case when p.product_type = 'Add-on' then 1 else 0 end) > 0;


select * from customers;
select * from products;
select * from sales;
select * from sales_reps;






