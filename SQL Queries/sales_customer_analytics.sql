use sales_customer_analytics;

-- =================================================== WINDOW FUNCTION ======================================================================

-- Query-1) Find each customer's most recent order date and rank their orders by recency.
select *
from
(
select 
	c.customer_id,
    c.customer_name,
    o.order_Date,
    rank() over (partition by customer_id order by o.order_Date desc) as RNK
from customers as c
join orders as o
	on c.customer_id = o.customer_id
) as latest_orders
where RNK = 1;
    

-- Query-2) Calculate the running total of sales (total_amount) across all orders ordered by date.
select
	order_id,
    total_amount,
    sum(total_amount) over (order by order_Date desc) as running_total
from orders;

-- Query-3) For each product, find its average item price and how each order item's price deviates from the average.
select
	p.product_id,
    p.product_name,
    oi.item_price,
    round(avg(item_price) over (partition by p.product_id),2) as average_item_price,
    oi.item_price - avg(item_price) over (partition by p.product_id )as price_deviation
from products as p
join order_items as oi
	on p.product_id = oi.product_id;


-- =================================================== ADVANCED JOINS & ANALYSIS ======================================================================

-- Query-4) Get a list of customers who have never placed an order.
select
	c.customer_id,
    c.customer_name
from customers as c
left join orders as o
	on c.customer_id = o.customer_id
where o.customer_id is NULL;


-- Query-5) List all orders where the total amount recorded in orders does not match the sum of item prices in order_items.
select *
from
(
select 
	o.order_id,
    sum(oi.item_price) as sum_of_item_price,
    o.total_amount as order_total_amount
from orders as o
join order_items as oi
	on o.order_id = oi.order_id
group by o.order_id, o.total_amount
) as price_coparision
where sum_of_item_price != order_total_amount;

-- Query-6) Find products that have never been sold.
select
	p.product_id,
    p.product_name
from products as p
left join order_items as oi
	on p.product_id = oi.product_id
where oi.product_id is NULL;


-- =================================================== CTE's & Logic ======================================================================
-- Query-7) For each customer, find the number of days between their signup date and their first order.
with date_difference as
(
select
	c.customer_id as Customer_id,
    c.customer_name as Name_,
    c.signup_date as Customer_Signup_Data,
   min(o.order_date) as Customer_Order_Date
from customers as c
join orders as o
	on c.customer_id = o.customer_id
    group by c.customer_id, c.customer_name, c.signup_date 
) 
select
	Customer_id,
    Name_,
    Customer_Signup_Data,
    Customer_Order_Date,
    datediff(Customer_Order_Date, Customer_Signup_Data) as days_between_signup_and_first_order
from date_difference;

-- Query-8) Create a report that shows each customer’s total spend, average order value, and number of orders.
with customer_spending_report as 
(
select
	c.customer_id as Customer_Id_,
    c.customer_name as Customer_Name_,
   round(sum(o.total_amount),2) as total_amount_spent,
   round(avg(o.total_amount),2) as average_order_value,
   count(o.order_id) as order_count
from customers as c
join orders as o
	on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
)
select
	Customer_Id_,
    Customer_Name_,
    total_amount_spent,
    average_order_value,
    order_count
from customer_spending_report;

-- Query-9) Identify repeat customers (placed more than 1 order) and their most frequently purchased product category.
select
	c.customer_id,
    c.customer_name,
    count(o.order_id) as order_count,
    p.category,
    count(p.category) as category_frequency
from customers as c
join orders as o
	on c.customer_id = o.customer_id
join order_items as oi
	on oi.order_id = o.order_id
join products as p
	on p.product_id = oi.product_id
group by c.customer_id, c.customer_name, p.category
having count(o.order_id) > 1;
 

