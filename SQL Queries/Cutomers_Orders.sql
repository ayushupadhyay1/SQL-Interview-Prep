-- --------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------    TABLE CREATION     -----------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

create database customer;

use customer;

-- Customer Table Creations

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    City VARCHAR(50),
    SignupDate DATE
);

INSERT INTO Customers (CustomerID, Name, Email, City, SignupDate) VALUES
(1, 'Alice Johnson', 'alice@gmail.com', 'New York', '2023-01-15'),
(2, 'Bob Smith', 'bob@gmail.com', 'Los Angeles', '2023-02-10'),
(3, 'Charlie Davis', 'charlie@yahoo.com', 'Chicago', '2023-03-05'),
(4, 'David White', 'david@gmail.com', 'New York', '2023-01-20'),
(5, 'Emma Brown', 'emma@gmail.com', 'San Francisco', '2023-04-25'),
(6, 'Alice Johnson', 'alice@gmail.com', 'New York', '2023-01-15'), 
(7, 'Frank Black', 'frank@gmail.com', 'Los Angeles', '2023-05-14'),
(8, 'Grace Wilson', 'grace@yahoo.com', 'Chicago', '2023-06-30'),
(9, 'Henry Moore', 'henry@gmail.com', 'New York', '2023-07-10'),
(10, 'Ivy Carter', 'ivy@gmail.com', 'San Francisco', '2023-08-20');

-- Order table Creation

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10,2),
    Status VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount, Status) VALUES
(101, 1, '2023-01-18', 250.50, 'Completed'),
(102, 2, '2023-02-12', 180.00, 'Pending'),
(103, 3, '2023-03-07', 320.75, 'Completed'),
(104, 4, '2023-01-22', 150.00, 'Cancelled'),
(105, 5, '2023-04-27', 275.00, 'Completed'),
(106, 6, '2023-01-18', 250.50, 'Completed'), 
(107, 7, '2023-05-16', 125.00, 'Shipped'),
(108, 8, '2023-07-02', 210.60, 'Completed'),
(109, 9, '2023-07-12', 340.20, 'Pending'),
(110, 10, '2023-08-22', 500.00, 'Completed');

-- Products Table Creation
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);

INSERT INTO Products (ProductID, ProductName, Category, Price) VALUES
(1, 'Laptop', 'Electronics', 800.00),
(2, 'Smartphone', 'Electronics', 600.00),
(3, 'Tablet', 'Electronics', 400.00),
(4, 'Headphones', 'Accessories', 150.00),
(5, 'Keyboard', 'Accessories', 100.00),
(6, 'Mouse', 'Accessories', 50.00),
(7, 'Monitor', 'Electronics', 300.00),
(8, 'Chair', 'Furniture', 200.00),
(9, 'Desk', 'Furniture', 500.00),
(10, 'Smartwatch', 'Electronics', 250.00);

-- Create Order Details Table 

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity) VALUES
(1, 101, 1, 1),
(2, 101, 4, 2),
(3, 102, 2, 1),
(4, 103, 3, 1),
(5, 104, 5, 1),
(6, 105, 6, 3),
(7, 106, 1, 1), 
(8, 107, 7, 2),
(9, 108, 8, 1),
(10, 109, 9, 1);

-- --------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------      SQL Queries     ----------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------



-- ------------------------------------------------ PART-1 (EASY) -----------------------------------------------------------
-- Query-1) Write a query to fetch all customers who signed up after March 2023.
select *
from customers
where signupdate > '2023-03-31';

-- Query-2) Retrieve the total number of completed orders.
select 
	count(status) as Total_Completed_order 
from orders 
where status = 'Completed';


-- Query-3) Find the total revenue generated from completed orders.
select
	sum(TotalAmount) as total_generated_revenue
from orders
where status = 'Completed';


-- Query-4) Display the product names and their categories sorted alphabetically.
select
	ProductName,
    category
from products
order by category asc;


-- Query-5) Fetch unique cities from the Customers table.
select
	distinct city as unique_cities
from customers;

-- ------------------------------------------------ PART-2 (MEDIUM) -----------------------------------------------------------
-- Query-1) Retrieve all duplicate records from the Customers table.
select
	Name,
    Email,
    City,
    SignUpDate,
    count(*) as Duplicates
from customers
group by Name, City, Email, SignUpDate
having count(*) > 1;



-- Query-2) Find customers who have placed more than one order.
select
	customerID,
    count(OrderID) as order_count
from orders
group by customerID
having count(orderID) > 1;


-- Query-3) Fetch the top 3 most sold products.
select
    sum(Quantity) as total_quantity,
    ProductID
from OrderDetails as od
group by ProductID
order by total_quantity desc
limit 3;


-- Query-4) Retrieve all customers who have never placed an order.
select
	c.name
from customers as c
left join orders as o
on c.CustomerID = o.CustomerID
where o.orderId is NULL;


-- Query-5) Get the highest and lowest order amount.
select
	min(TotalAmount) as Lowest,
    max(TotalAmount) as Highest
from orders;


-- Query-6) Find the customer who has spent the most money.
select
	c.CustomerID,
    sum(TotalAmount) as Total_Spent
from customers as c
join orders as o
on c.CustomerID = o.CustomerID
group by c.CustomerID
order by Total_Spent desc
limit 1;

-- Query-7) Display the total number of orders in each order status.
select
	Status,
	count(orderID) as total_number_of_orders
from orders
group by status;  



-- Query-7) Fetch the Customer Name, Order Date, and Total Amount for all completed orders.
select
	c.Name,
	o.OrderDate,
    o.TotalAmount,
    status
from customers as c
join orders as o
on c.CustomerId = o.CustomerID
where o.status = 'Completed';


-- Query-8) Write a query to return the most ordered product category.

select 
    count(od.ProductID) as order_count,
    p.Category
from products as p
join OrderDetails as od
on p.ProductId = od.ProductID
join Orders as o
on od.OrderId = o.OrderID
group by p.Category
order by order_count desc
limit 1;

-- Query-9) Retrieve all products that have never been ordered.
select 
	p.ProductName
from products as p
left join OrderDetails as od
on p.ProductId = od.ProductID
where od.productId is NULL; 

-- Query-10) Write a query to count the number of orders placed by each customer, sorting the result in descending order.
select 
	c.Name,
    count(*) as Order_Placed
from customers as c
join orders as o
on c.CustomerId = o.CustomerID
group by c.Name, O.OrderID
order by Order_Placed desc;

-- Query-11) Fetch customers whose names contain ‘a’ or ‘e’ (case insensitive).
select name
from customers
where name like '%a%' or name like '%e%';

-- ------------------------------------------------ PART-3 (HARD) -----------------------------------------------------------
-- Query-1) Find the second-highest revenue-generating customer.
select 
	c.name,
    sum(o.totalamount) as Total_Revenue
from customers as c
join orders as o
on c.customerId = o.CustomerID
group by c.name
order by Total_Revenue desc
limit 1 offset 1;


-- Query-2) Write a query to fetch all orders where the total amount is higher than the average order amount.
select 
	o.OrderID,
    o.TotalAmount
from orders as o
where o.TotalAmount > 
(
	select
		avg(TotalAmount)
    from orders 
);

-- Query-3) Retrieve the Customer Name, Order Date, Product Name, and Quantity for all orders using Advanced Joins.
select 
	c.name,
    o.orderdate,
    p.productname,
    od.quantity
from customers as c
join orders as o
on c.customerID = o.customerID
join orderdetails as od
on o.orderId = od.orderID
join products as p
on p.ProductID = od.ProductID;

-- Query-4) Identify duplicate records from the Orders table.
select 
    OrderDate,
    Status,
    count(*) as duplicate
from orders
group by OrderDate,Status
having count(*) > 1;

-- Query-5) Write a query to return all customers who placed consecutive orders within 7 days.
select
	c.name,
    o1.Orderdate as first_order_Date,
    o2.Orderdate as Second_order_Date,
    p.Productname
from customers as c
join orders as o1
	on c.CustomerID = o1.CustomerID
join orders as o2
	on o1.customerId = o2.customerID
join orderdetails as od
	on od.OrderID = o1.OrderID
join Products as p
	on p.ProductId = od.ProductId
where o1.orderdate < o2.orderdate
and datediff(o2.orderdate , o1.orderdate) <= 7;

-- Query-6) Find the top 3 cities with the highest revenue.
select 
	c.city,
    sum(o.TotalAmount) as Highest_Revenue
from customers as c
join orders as o
on c.customerID = o.customerID
group by c.city
order by Highest_Revenue DESC
limit 3;

-- Query-7) Retrieve the first order date and last order date for each customer.
select
	c.name,
    c.CustomerID,
    Min(o.OrderDate) as First_Order_Date,
    Max(o.OrderDate) as Last_Order_Date
from orders as o
join customers as c
on o.CustomerID = c.CustomerID
group by c.name, c.CustomerID;
