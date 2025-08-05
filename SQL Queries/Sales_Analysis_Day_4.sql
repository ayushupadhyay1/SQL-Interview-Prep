use sales_analysis;

-- ------------------------------------------------------------ EASY --------------------------------------------------------------------------

-- Query-1) Get the total number of customers in each industry.
select
	industry,
    count(customer_id) as total_number_of_customers
from customers 
group by industry
order by total_number_of_customers desc;


-- Query-2) List all products where price is between $20 and $80.
select
	product_id,
    product_name,
    price_per_unit as product_price
from products
where price_per_unit between 20 and 80
order by product_price;

-- Query-3) How many distinct products has each customer purchased?
select 
	s.customer_id,
    c.customer_name,
    count(distinct s.product_id) as disctict_product_count
from customers as c
join sales as s
	on c.customer_id = s.customer_id
group by s.customer_id, c.customer_name
order by disctict_product_count desc;

-- Query-4) Show all sales with more than 10 units sold.
select *
from sales
where quantity > 10;

-- Query-5) List all sales made by reps in the “North America” region.
select 
	s.sales_rep_id,
    sr.rep_name,
    sr.region,
    count(s.sale_id) as total_sales
from sales_reps as sr
join sales as s	
	on s.sales_rep_id = sr.sales_rep_id
where sr.region = 'North America'
group by s.sales_rep_id, sr.rep_name, sr.region
order by total_sales desc;

-- ------------------------------------------------------------ MEDIUM --------------------------------------------------------------------------

-- Query-6) For each customer, calculate their lifetime value (LTV): (SUM(quantity * price_per_unit) - SUM(discount_applied))
with Customer_Lifetime_Value as 
(
select 
	s.customer_id,
    c.customer_name,
    sum(s.quantity * p.price_per_unit) as total_revenue,
    sum(s.discount_applied) as total_discount
from customers as c
join sales as s	
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id
group by s.customer_id, c.customer_name
)
select
	customer_id,
    customer_name,
    (total_revenue - total_discount) as LTV
from Customer_Lifetime_Value
order by LTV desc;


-- Query-7) Which product type contributes most to total revenue? Use grouping and aggregate revenue logic.
with revenue_by_product as
(
select
	p.product_type,
    sum(p.price_per_unit * s.quantity) as total_revenue
from products as p
join sales as s
	on p.product_id = s.product_id
group by p.product_type
),
total_revenue as
(
select
	sum(s.quantity * p.price_per_unit) as total_revenue
from products as p
join sales as s
	on p.product_id = s.product_id
)
select 
	rp.product_type,
    rp.total_revenue as revenue_by_product,
    tr.total_revenue,
    round((rp.total_revenue / tr.total_revenue),2) * 100 as contribution_in_percentage
from revenue_by_product as rp
cross join total_revenue as tr;

-- Query-8) Write a query that lists every customer and whether they’ve purchased a “Subscription” plan (Yes/No).
select 
	s.customer_id,
    c.customer_name,
    case
		when max(case when p.product_type = 'subscription' then 1 else 0 end) = 1 then 'Yes'
        else 'No'
    end as Subscription_Purchased_Status
from customers as c
join sales as s
	on c.customer_id = s.customer_id
join products as p
	on p.product_id = s.product_id
group by s.customer_id, c.customer_name
order by s.customer_id;

-- Query-9) Find the average number of days between two purchases for each customer (hint: LAG + DATEDIFF).
with days_duration as
(
select	
	s.customer_id,
    c.customer_name,
    s.sale_date,
    lag(s.sale_date) over (partition by s.customer_id order by s.sale_date) as previous_purchase_date
from customers as c
join sales as s
	on c.customer_id = s.customer_id
)
select
	customer_id,
    customer_name,
    round(avg(datediff(sale_date, previous_purchase_date)),2) as avg_duration_in_days
from days_duration
group by customer_id, customer_name
order by avg_duration_in_days desc;


-- Query-10) Using a subquery, list the sales that had the highest discount in the dataset.
select
	sale_id,
    discount_applied as total_discount
from sales
where discount_applied = (select max(discount_applied) from sales);

-- ------------------------------------------------------------ HARD --------------------------------------------------------------------------

-- Query-11) For each month, show the total revenue and the month-over-month change using LAG(). Output: month, total_revenue, mom_change
with monthly_revenue as
(
select
	month(s.sale_date) as Months,
    SUM(s.quantity * p.price_per_unit - s.discount_applied) as total_revenue
from sales as s
join products as p
	on s.product_id = p.product_id
group by month(s.sale_date)
),
Month_on_month_change as 
(
select
	Months,
    total_revenue,
    lag(total_revenue) over (order by Months) as previous_month
    
from monthly_revenue
)
select
	Months,
    total_revenue,
    total_revenue - coalesce(previous_month, 0) as mom_change 
from Month_on_month_change;


-- Query-12) List the top 3 reps by revenue-to-discount ratio. (SUM(price * qty) / NULLIF(SUM(discount), 0))
select
	s.sales_rep_id,
    sr.rep_name,
    round(sum(s.quantity * p.price_per_unit) / nullif(sum(s.discount_applied),0),0) as revenue_to_discount
from sales_reps as sr
join sales as s
	on s.sales_rep_id = sr.sales_rep_id
join products as p
	on p.product_id = s.product_id
group by s.sales_rep_id, sr.rep_name
order by revenue_to_discount desc
limit 3;

-- Query-13) Use a CTE to calculate customer segments: “High” if total revenue > $1000, “Mid” if between $500, and $1000 “Low” otherwise
with customer_segments as
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
order by s.customer_id
)
select	
	customer_id,
    customer_name,
    total_revenue,
    case
		when total_revenue > 1000 then "High"
        when total_revenue between 500 and 1000 then "Medium"
        else "Low"
    end as customer_segmentation
from customer_segments;

-- Query-14) Which customers haven’t purchased any product in the last 180 days from the most recent sale date?
with product_purchase as
(
select 
	s.customer_id,
    c.customer_name,
    max(s.sale_date) as most_recent_sale_date
from customers as c
join sales as s
	on c.customer_id = s.customer_id
group by s.customer_id, c.customer_name
)
select
	customer_id,
    customer_name,
    most_recent_sale_date
from product_purchase
where most_recent_sale_date <= current_date() - interval 180 day;


-- Query-15) Show each rep’s rank within their region based on total revenue using PARTITION BY.
with regional_based_ranking as
(
select
	s.sales_rep_id,
    sr.rep_name,
    sr.region,
    sum(s.quantity * p.price_per_unit) as total_regional_revenue
from sales_reps as sr
join sales as s
	on sr.sales_rep_id = s.sales_rep_id
join products as p
	on p.product_id = s.product_id
group by s.sales_rep_id, sr.rep_name, sr.region
)
select
	sales_rep_id,
    rep_name,
    region,
    total_regional_revenue,
    rank() over (partition by region order by total_regional_revenue desc) as rnk
from regional_based_ranking;


