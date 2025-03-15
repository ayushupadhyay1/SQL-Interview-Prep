-- Create product table

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2)
);
-- Insert data into product table
INSERT INTO Products (product_id, product_name, category, price)
VALUES
(101, 'Laptop', 'Electronics', 800),
(102, 'Smartphone', 'Electronics', 600),
(103, 'Tablet', 'Electronics', 300),
(104, 'Headphones', 'Accessories', 50),
(105, 'Charger', 'Accessories', 20),
(106, 'Monitor', 'Electronics', 150),
(107, 'Mouse', 'Accessories', 25);

-- Create sales table
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    sale_date DATE,
    customer_name VARCHAR(255),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Insert into sales table
INSERT INTO Sales (sale_id, product_id, quantity, sale_date, customer_name)
VALUES
(1, 101, 2, '2025-01-05', 'Alice'),
(2, 102, 1, '2025-01-10', 'Bob'),
(3, 103, 3, '2025-01-15', 'Charlie'),
(4, 101, 1, '2025-01-20', 'David'),
(5, 106, 2, '2025-01-25', 'Eve'),
(6, 105, 5, '2025-02-01', 'Frank'),
(7, 102, 2, '2025-02-10', 'Grace'),
(8, 107, 1, '2025-02-15', 'Helen');


-- ------------------------------------------------------------ PART-1 (EASY) --------------------------------------------------------------------------

-- Query-1) Find the total quantity sold for each product.
select 
	product_id,
    sum(quantity) as Total_Items_Sold
from Sales
group by product_id;

-- Query-2) List all unique product categories.
select
	distinct(category) as Unique_Product_Categories
from Products;

-- Query-3) Find the highest-priced product
select
	product_id,
    product_name,
	max(price) as Max_Price
from products
group by product_id, product_name
order by Max_Price desc
limit 1;

-- Query-4) List customers who purchased more than 1 item
select * from Products;
select * from Sales;

-- Query-5) Get the total sales for each category (based on quantity sold)
select
	category,
    round(sum(price),0) as total_sale_price,
    count(category) as category_count
from Products
group by category;





-- Query-5) List products that have never been sold (no sales in the Sales table).
select
	p.product_id,
    p.product_name
from products as p
left join sales as s
on p.product_id = s.product_id
where s.product_id is null;

-- Query-6) Find the total sales amount for each product (price * quantity)
select
	p.product_name,
    s.quantity,
    p.price,
	round((p.price * s.quantity),0 )as total_sales
from products as p
join sales as s
on p.product_id = s.product_id;

select * from Products;
select * from Sales;

-- ------------------------------------------------------------ PART-2 (MEDIUM) -------------------------------------------------------------------

-- Query-1) Find the average price of products in each category.
select
	category,
    round(avg(price),2) as average_price
from products as p
group by category;

-- Query-2) List the top 3 products with the highest total sales (price * quantity).

select
	p.product_name,
    round(sum(p.price * s.quantity),2 )as total_sales
from products as p
join sales as s
on p.product_id = s.product_id
group by p.product_name
order by total_sales desc
limit 3;

-- Query-3) Find the products with the lowest total sales (based on quantity sold).
select
	p.product_name,
    round(sum(s.quantity * p.price),2)as total_price,
    round(sum(s.quantity),0) as total_quantity
from products as p
join sales as s
on p.product_id = s.product_id
group by p.product_name
order by total_price asc
limit 1;

-- Query-4) Get the number of products sold by each customer.
select
	product_id,
    count(distinct customer_name) as customer_name
from sales
group by product_id;

-- Query-5) Find the total sales for the month of January 2025.
select *
from
(
select
	date_format(s.sale_date, '%Y-%m') as formatted_date ,
    round(sum(s.quantity * p.price),2) as total_sales
from products as p
join sales as s
on p.product_id = s.product_id
group by formatted_date
) as date_format
where formatted_date = '2025-01';

-- Query-6) For each product, find the difference between the highest and lowest sale quantity
select 
	p.product_id,
    p.product_name,
    max(s.quantity) as maximum_quantity,
    min(s.quantity) as minimum_quantity,
    (max(s.quantity) - min(s.quantity)) as difference
from sales as s
join products as p
on s.product_id = p.product_id
group by p.product_id;

-- Query-7) Find the difference between the maximum and minimum price for each products.
select
	product_name,
    max(price) as Maximum,
    min(price) as Minimum,
    (max(price) - min(price)) as Difference
from products
group by product_name;

-- Query-8) List products that have been sold in the last 30 days.
select *
from sales 
where sale_Date >= current_date() - interval 30 day;


-- ------------------------------------------------------------ PART-3 (HARD) ------------------------------------------------------------------

-- Query-1) Find the customers who have purchased both a product from the 'Electronics' category and a product from the 'Accessories' category
select 
	s.customer_name
from sales as s
join products as p
on s.product_id = p.product_id
where p.category in ('Electronics', 'Accessories')
group by s.customer_name
having count(distinct p.category) = 2;


-- Query-2) List products that have been sold more than once but with different prices in separate sales transactions.
select * from sales;
select * from products;

select 
	s.product_id,
    p.price,
    p2.price
from sales as s
join products as p
on s.product_id = p.product_id
join products as p2
on p.product_id = p2.product_id
group by p.price, p2.price
having count(s.product_id) = 2;

-- Query-3) Find the customer who has spent the most money across all their purchases (total = price * quantity).
select 
	s.customer_name,
    round(sum(quantity * p.price),2) as total_price,
    count(distinct p.category) as category_count
from sales as s
join products as p
on s.product_id = p.product_id
group by s.customer_name
order by total_price desc
limit 1;

-- Query-4) List the product categories and the total sales (price * quantity) for each category in the last 60 days.
select
	p.category,
    round(sum(p.price * s.quantity),0) as total_Sale
from sales as s
join products as p
on s.product_id = p.product_id
where s.sale_date >= current_date() - interval 60 day
group by p.category;


-- Query-5) Find the top 3 customers who bought the most quantity of products in February 2025
select *
from
(
select
	s.customer_name,
    sum(s.quantity) as total_quantity,
    date_format(s.sale_date, '%M - %Y') as Month_Year
from sales as s
join products as p
on s.product_id = p.product_id
group by s.customer_name, s.sale_date
) as selected_date
where Month_Year = 'February - 2025'
order by total_quantity desc
limit 3;

-- Query-6) For each product, find the earliest and latest sale dates
select 
	p.product_id,
    p.product_name,
    min(s.sale_date) as earliest_date,
    max(s.sale_date) as latest_date
from products as p
join sales as s
on p.product_id = s.product_id
group by p.product_id, p.product_name;



select * from sales;
select * from products;





















