use sales_analysis;

-- ------------------------------------------------------------ EASY --------------------------------------------------------------------------

-- Query-1) List all customers and their industries.
select
	customer_name,
    industry
from customers;

-- Query-2) Show all sales along with the product name.
select 
	p.product_id,
    p.product_name,
    count(sale_id) as total_sales
from products as p
join sales as s
	on p.product_id = s.product_id
group by p.product_id, p.product_name
order by total_sales desc;


-- Query-3) How many distinct industries do we serve?
select
	count(distinct industry) as distinct_industry_count
from customers;

-- Query-4) Show all products with price less than $60.
select
	product_id,
    product_name,
    price_per_unit
from products
where price_per_unit < 60
order by price_per_unit desc;

-- Query-5) What’s the total quantity sold per product?
select 
	p.product_id,
    p.product_name,
    sum(s.quantity) as total_quantity
from products as p
join sales as s
	on p.product_id = s.product_id
group by p.product_id, p.product_name
order by total_quantity DESC;

-- ------------------------------------------------------------ MEDIUM --------------------------------------------------------------------------

-- Query-6) Find total revenue per customer (apply discounts).
select 
	c.customer_id,
    c.customer_name,
    sum(s.quantity * p.price_per_unit) as total_revenue,
    sum(s.discount_applied) as total_discount,
    (sum(s.quantity * p.price_per_unit) - sum(s.discount_applied)) as revenue_after_discount
from customers as c
join sales as s
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id
group by c.customer_id, c.customer_name
order by revenue_after_discount desc;

-- Query-7) List all customers who bought more than one product.
select 
	c.customer_id,
    c.customer_name,
    count(distinct s.product_id) as product_count
from customers as c
join sales as s
	on c.customer_id = s.customer_id
group by c.customer_id, c.customer_name
having count(distinct s.product_id) > 1;

-- Query-8) Show total units sold per product_type.
select
	product_type,
    sum(s.quantity) as total_units_sold
from products as p
join sales as s	
	on p.product_id = s.product_id
group by product_type
order by total_units_sold desc;

-- Query-9) Retrieve customer names and their assigned sales rep names using a join.
select 
	c.customer_id,
    c.customer_name,
    s.sales_rep_id,
    sr.rep_name
from customers as c
join sales as s	
		on c.customer_id = s.customer_id
join sales_reps as sr
	on sr.sales_rep_id = s.sales_rep_id;
    
-- Query-10) Which country has the highest number of customers?
select 
	c.country,
    count(distinct s.customer_id) as customer_count
from customers as c
join sales as s	
	on c.customer_id = s.customer_id
group by c.country
order by customer_count desc
limit 1;

-- ------------------------------------------------------------ HARD --------------------------------------------------------------------------

-- Query-11) Find top 2 sales reps based on total revenue generated.
select 
	s.sales_rep_id,
    sr.rep_name,
    sum(s.quantity * p.price_per_unit) as total_revenue
from sales_reps as sr
join sales as s
	on sr.sales_rep_id = s.sales_rep_id
join products as p
	on p.product_id = s.product_id
group by s.sales_rep_id, sr.rep_name
order by total_revenue desc
limit 2;


-- Query-12) Write a query to show monthly revenue trends.
select 
	year(s.sale_date) as Years,
	month(s.sale_date) as Months,
    sum(s.quantity * p.price_per_unit) as total_revenue
from sales as s
join products as p
	on s.product_id = p.product_id
group by year(s.sale_date), month(s.sale_date)
order by year(s.sale_date), month(s.sale_date);

-- Query-13) Find customers who have purchased both a “Subscription” and an “Add-on” product.
select 
	s.customer_id,
    c.customer_name,
    s.product_id,
    p.product_name
from customers as c
join sales as s
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id
where  p.product_name = 'Subscription' and p.product_name = "Add-on";
    

-- Query-14) Calculate average discount given per sales rep.
select
	s.sales_rep_id,
    sr.rep_name,
    round(avg(s.discount_applied),2) as average_discount_applied
from sales_reps as sr
join sales as s
	on sr.sales_rep_id = s.sales_rep_id
group by s.sales_rep_id, sr.rep_name
order by average_discount_applied desc;
    

-- Query-15) Rank customers based on their total spending using window functions.
select 
	s.customer_id,
    c.customer_name,
    sum(s.quantity * p.price_per_unit) as total_spent,
    rank() over (order by  sum(s.quantity * p.price_per_unit) desc) as rnk
from customers as c
join sales as s
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id
group by s.customer_id, c.customer_name;


 select * from customers;
select * from products;
select * from sales;
select * from sales_reps;


