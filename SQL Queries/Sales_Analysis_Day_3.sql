use sales_analysis;

-- ============================================================ EASY ===========================================================================

-- Query-1) List all products with their price and type, sorted by price descending.
select
	product_name,
    price_per_unit as product_price,
    product_type
from products
order by product_price desc;

-- Query-2) Get the list of all sales reps hired after January 1, 2022.
select *
from sales_reps
where hire_date > '2022-01-01';

-- Query-3) How many products were sold by each sales rep (based on count of sales rows)?
select 
	s.sales_rep_id,
    sr.rep_name,
    count(s.product_id) as product_count
from sales as s
join sales_reps as sr
	on s.sales_rep_id = sr.sales_rep_id
group by s.sales_rep_id, sr.rep_name
order by product_count desc;

-- Query-4) List all customers with their industry and total number of purchases.
select 
	s.customer_id,
    c.customer_name,
    c.industry,
    sum(s.quantity) as total_purchases
from customers as c
join sales as s
	on c.customer_id = s.customer_id
group by s.customer_id, c.customer_name, c.industry
order by total_purchases desc;

-- Query-5) Show total revenue generated for each product (quantity × price_per_unit) before discount.
select
	s.product_id,
    p.product_name,
    sum(s.quantity * p.price_per_unit) as total_revenue
from products as p
join sales as s
	on p.product_id = s.product_id
group by s.product_id, p.product_name
order by total_revenue desc;

-- ============================================================ MEDIUM ===========================================================================

-- Query-6) Using a CASE statement, label each product as “Core” if it's a Subscription, else “Add-on”.
select
	product_name,
    case
		when product_type = "Subscription" then "Core"
        else "Add-on"
    end as Product_labels
from products;


-- Query-7) Which customers made purchases in more than one calendar year?
select 
	s.customer_id,
    c.customer_name
from customers as c
join sales as s
	on c.customer_id = s.customer_id
group by s.customer_id, c.customer_name
having count(distinct year(s.sale_date)) > 1;

-- Query-8) List the average discount given by each rep, but only for transactions above 5 units.
select
	s.sales_rep_id,
    sr.rep_name,
    round(avg(discount_applied),2) as avg_discount
from sales_reps as sr
join sales as s
	on s.sales_rep_id = sr.sales_rep_id
where s.quantity > 5
group by s.sales_rep_id, sr.rep_name
order by avg_discount desc;


-- Query-9) Using a JOIN, show each customer along with the names of the products they’ve purchased.
select
	s.customer_id,
    c.customer_name,
    p.product_name
from customers as c
join sales as s
	on s.customer_id = c.customer_id
join products as p
	on p.product_id = s.product_id
order by s.customer_id;

-- Query-10) Calculate total discounted revenue (quantity × price - discount) per sales rep and rank them.
with sales_rep_ranks as
(
select 
	s.sales_rep_id,
    sr.rep_name,
    sum(s.quantity * p.price_per_unit - s.discount_applied) as discounted_revenue
from sales_reps as sr
join sales as s
	on s.sales_rep_id = sr.sales_rep_id
join products as p
	on p.product_id = s.product_id
group by s.sales_rep_id, sr.rep_name
)
select
	sales_rep_id,
    rep_name,
    discounted_revenue,
    rank() over (order by discounted_revenue desc) as rnk
from sales_rep_ranks;

-- ============================================================ HARD ===========================================================================

-- Query-11) Using a CTE and DENSE_RANK(), show the top 2 products in each product_type category by total revenue.
with top_products as 
(
select
	p.product_type,
    p.product_name,
    sum(p.price_per_unit * s.quantity) as total_quantity
from products as p
join sales as s
	on s.product_id = p.product_id
group by p.product_type, p.product_name
)
select *
from
(
select
	product_type,
    product_name,
    total_quantity,
    dense_rank() over (partition by product_type order by total_quantity desc) as rnk
from top_products
)as top_2_product_itmes
where rnk <= 2;

-- Query-12) Which customer has the highest average revenue per transaction (after discount)?
with transaction_revenue as
(
select 
	s.customer_id,
    c.customer_name,
    s.sale_id as transactions,
   (s.quantity * p.price_per_unit - s.discount_applied) as discounted_revenue
from customers as c
join sales as s
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id
)
select
	customer_id,
    customer_name,
    round(avg(discounted_revenue)) as average_discounted_revenue
from transaction_revenue
group by customer_id, customer_name
order by average_discounted_revenue desc
limit 1;


-- Query-13) List customers whose purchases make up more than 25% of total revenue in their country.

-- Query-14) Using window function Get each sales rep’s percentage contribution to total revenue in their region.
with representative_revenue_collection as
(
select 
	s.sales_rep_id,
    sr.rep_name,
    sr.region,
    sum(s.quantity * p.price_per_unit) as revenue_per_rep
from sales_reps as sr
join sales as s
	on s.sales_rep_id = sr.sales_rep_id
join products as p
	on p.product_id = s.product_id
group by s.sales_rep_id, sr.rep_name, sr.region
)
select
	sales_rep_id,
    rep_name,
    region,
    revenue_per_rep,
    sum(revenue_per_rep) over (partition by region) as total_revenue_by_region,
    round(revenue_per_rep * 100 / sum(revenue_per_rep) over (partition by region),2) as percentage_contribution
from representative_revenue_collection
group by sales_rep_id, rep_name, region,revenue_per_rep;


-- Query-15) Write a query to show customer churn: list customers who made a purchase in 2023 but none in 2024.




