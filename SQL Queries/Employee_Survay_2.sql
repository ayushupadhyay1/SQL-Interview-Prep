use employee_survey;

-- -------------------------------------------------------- PART-1 (EASY) -------------------------------------------------------------------------

-- Query-1) List all employees who work in the 'Engineering' department.
select
	e.Name,
    d.department_name
from employee as e
join departments as d
	on e.department_Id = d.Department_Id
where d.department_name = 'Engineering';

-- Query-2)Get the name and salary of employees who earn more than 50,000.
select 
	Name,
    Salary
from employee
where salary > 50000;

-- Query-3)List all orders made in the month of April 2023.
select
	order_id
from orders
where date_format(order_Date,'%M-%Y') = 'April-2023';

-- Query-4) Find all products with a price less than 100.
select
	Product_name,
    Price
from products
where price > 100;

-- Query-5) List customer names who placed at least one
select
	c.name
from orders as o
join customers as c
	on c.Customer_id = o.customer_id
group by c.name;

-- -------------------------------------------------------- PART-2 (Medium) -------------------------------------------------------------------------
-- Query-1) Find employees who have the same manager.
select
	manager_id,
    group_concat(Name) as Employee_Name
from employee
where manager_id is not null
group by manager_id
having count(*) > 1;

-- Query-2) List all employees who are also managers.
select
	distinct e1.Name
from employee as e1
join employee as e2
	on e1.Emp_ID = e2.Manager_id;


-- Query-3) Display the first and last record for each employee based on the hire_date.
select
	name,
    min(hire_Date) as First_record,
    Max(hire_Date) as Last_Record
from employee
group by name;

-- Query-4) Find the most recent transaction for each customer.
select
	c.Name,
    t.txn_id,
   t.txn_date as Most_Recent_Date,
    amount
from customers as c
join transactions as t
	on c.customer_id = t.customer_id
where t.txn_Date = 
(
	select
		max(t.txn_Date)
		from transactions as t1
        where t1.customer_id = c.customer_id
);


-- Query-5) Get the total salary of each department and display only departments where the total is greater than 50,000.
select *
from
(
select
	e.Department_id,
    d.Department_name,
	sum(e.salary) as Total_salary
from employee as e
join departments as d
	on e.department_id = d.department_id
group by e.Department_id, d.Department_name
) as department_total_salary
where Total_salary > 50000;

-- Query-6) Get the total number of employees hired per month and year.
select
	count(emp_id) as Hired_Employee,
    date_format(Hire_Date, '%M') as Months,
    date_format(Hire_Date, '%Y') as Years
from employee as e
group by date_format(Hire_Date, '%M'), date_format(Hire_Date, '%Y');

-- Query-7) List all the employees who earn more than the average salary for their department.
select
	e.Name,
    e.Department_id,
    e.Salary as Higher_Salary_Than_Avg
from employee as e
where e.Salary > 
(
	select
		avg(e2.salary) as avg_salary
    from employee as e2    
    where e2.department_id = e.department_id
);

-- Query-8) Find employees who have joined in the same month and year.
select * from customers;
select * from employee;
select * from departments;
select * from orders;
select * from products;
select * from transactions;

-- Query-9) List all products that have never been ordered.
select
	p.Product_Name
from products as p
left join orders as o
	on o.product_id = p.product_id
where o.product_id is NULL;

-- Query-10) Find the first purchase date of each customer.
select
	c.Name,
    min(o.order_Date) as First_Purchase_Date
from customers as c
join orders as o
	on c.Customer_id = o.Customer_id
group by c.Name, C.Customer_id;

-- Query-11) Calculate the running total of orders for each customer sorted by order date. (Window Function)
select
	c.Customer_id,
    o.Price * o.quantity as total_price,
    sum(o.price * o.quantity) over (partition by c.customer_id order by o.order_date) as Running_Total
from customers as c
join orders as o
	on c.Customer_id = o.Customer_id;

-- Query-12) Find the average order value by customer for each month.
select
	Customer_id,
	round(avg(price),2) as avg_value,
    date_format(order_date, '%M-%Y') as Order_Date
from orders
group by date_format(order_date, '%M-%Y'), customer_id;

-- Query-13) Display customers who made purchases in at least 3 different months. (Window Function + Filtering)
select
	c.Name,
    date_format(order_date, '%M-%Y') as order_date
from customers as c
join orders as o
	on c.Customer_id = o.Customer_id
group by c.Name, date_format(order_date, '%M-%Y')
having count(o.customer_id) >= 3; 


-- -------------------------------------------------------- PART-3 (Hard) -------------------------------------------------------------------------

-- Query-1) Find all pairs of products that were ordered together at least once. (Self Join or CTE)

-- Query-2) Identify customers who made a purchase every month for the past year.
select * from employee;
select * from customers;
select * from orders;
select * from products;
select * from transactions;

-- Query-3) Calculate the year-on-year growth of revenue.

-- Query-4) Find the 'Nth' highest salary from the employee table (e.g., 5th highest salary). (Window Function)
select
	name,
    salary,
    nth_value(salary,2) over (order by salary desc rows between unbounded preceding and unbounded following) as 5th_highest_salary
from employee;

select
	Name,
    nth_value (salary,5) over (order by salary desc rows between unbounded preceding and unbounded following) as 5th_highest_salaary
from employee;

-- Query-5) Get the second-lowest salary without using LIMIT or OFFSET.
select 
	min(salary) as Minimum_Salary
from employee
where salary > (select min(salary) from employee);

-- Query-6) Find the employee(s) with the longest tenure at the company.
select
	emp_id,
    name,
    date_format(Hire_Date, '%Y') as Hire_Year,
	timestampdiff(year,Hire_Date, Current_Date) as Tenure
from employee as e
order by Tenure DESC
limit 1;

-- Query-7) Get the second-higest salary without using LIMIT or OFFSET.
select 
	max(salary) as Maximum_salary
from employee
where salary < (select max(salary) from employee);


-- Query-5) Get the second-lowest salary without using LIMIT or OFFSET.
select
	name,
    salary,
    nth_value(salary,2) over (order by salary asc rows between unbounded preceding and unbounded following) as Second_highest_salary
from employee;

