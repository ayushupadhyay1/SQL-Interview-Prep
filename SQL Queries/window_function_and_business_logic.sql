use employee_survey;

-- -------------------------------------------------------- WINDOW FUNCTION --------------------------------------------------------------
-- Query-1) For each employee, show their name, department name, salary, and the average salary of their department.
select
	e.Name,
    d.Department_name,
    salary,
    avg(salary) over (partition by d.department_id) as department_avg_salary
from employee as e
join departments as d
	on e.Department_id = d.department_id;

-- Query-2) Display the top 2 highest-paid employees in each department.
with ranked_employees as (
select
	e.Name,
    d.Department_name,
    e.salary,
	dense_rank() over (partition by d.department_id order by salary desc) as rnk
from employee as e
join departments as d
	on e.Department_id = d.Department_id
)
select
	name,
    Department_name,
    salary
from ranked_employees
where rnk <= 2;

-- Query-3) For each employee, calculate their salary rank within their department (highest salary = rank 1).
select
	e.Name,
    d.department_name,
    e.salary,
    dense_rank() over (partition by d.department_id order by e.salary desc) as rnk
from employee as e
join departments as d
	on e.Department_id = d.Department_id;

-- Query-4) For each product, calculate the running total of quantity ordered over time (order_date ascending).
select
	product_id,
    order_date,
    quantity,
    price,
    sum(quantity) over (partition by product_id order by order_date asc) as product_count
from orders;



-- Query-5) List all customers and show their total transaction amount, and the difference between each transaction amount and their average transaction amount.
with customer_transaction as (
select
	c.Name,
    round(sum(t.amount),2) as total_amount,
    round(avg(t.amount),2) as avg_amount
from customers as c
join transactions as t
	on c.Customer_id = t.Customer_id
group by c.name
)
select
	Name,
    total_amount,
    avg_amount,
    round((total_amount - avg_amount),2 )as difference
from customer_transaction;
-- -------------------------------------------------------- ADVANCED JOIN --------------------------------------------------------------

SELECT 
    e1.name AS employee_name,
    e2.name AS manager_name,
    d.department_name
FROM
    employee AS e1
        LEFT JOIN
    employee AS e2 ON e1.Manager_id = e2.Emp_ID
        JOIN
    departments AS d ON e1.department_id = d.Department_id;

-- Query-2) Find customers who have not placed any orders.
SELECT 
    c.Name
FROM
    customers AS c
        LEFT JOIN
    orders AS o ON c.Customer_id = o.Customer_id
WHERE
    o.customer_id IS NULL;

-- Query-3) For each department, show the department name and the total number of employees, even if it’s zero (use the appropriate JOIN).
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.emp_id) AS employee_count
FROM
    employee AS e
        LEFT JOIN
    departments AS d ON e.Department_id = d.Department_id
GROUP BY d.department_id , d.department_name

-- Query-4) List all employees and the name of the latest product ordered by their corresponding customer (assuming emp_id = customer_id for this question).
SELECT 
    e.name AS customer_name,
    p.product_name,
    MAX(o.order_date) AS latest_order
FROM
    orders AS o
        JOIN
    products AS p ON o.product_id = p.product_id
        JOIN
    employee AS e ON o.customer_id = e.emp_id
GROUP BY p.product_name , e.name

-- Query-5) Find products that have never been ordered.
SELECT 
    p.Product_name
FROM
    products AS p
        LEFT JOIN
    orders AS o ON p.Product_id = o.Product_id
WHERE
    o.product_id IS NULL

-- -------------------------------------------------------- ADVANCED SELECT --------------------------------------------------------------

SELECT 
    p.product_name,
    ROUND(SUM(o.quantity * o.price), 2) AS total_revenue
FROM
    products AS p
        JOIN
    orders AS o ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 1

-- Query-3) Retrieve employees who were hired before their managers.
SELECT 
    *
FROM
    (SELECT 
        e1.name AS employee_name,
            e2.name AS manager_name,
            e1.hire_date AS employee_hire_date,
            e2.hire_date AS manager_hire_date
    FROM
        employee AS e1
    LEFT JOIN employee AS e2 ON e1.emp_id = e2.manager_id) AS hire_date
WHERE
    employee_hire_date < manager_hire_date
        AND manager_hire_date IS NOT NULL

-- Query-4) For each customer, show their total spending on orders and total transaction amount side by side.

SELECT 
    p.Product_id,
    p.Product_name,
    c.region,
    SUM(o.quantity) AS Popular_products
FROM
    customers AS c
        JOIN
    orders AS o ON c.Customer_id = o.Customer_id
        JOIN
    products AS p ON p.product_id = o.product_id
GROUP BY p.Product_id , p.Product_name , c.region
ORDER BY Popular_products DESC

-- Query-2) Show the monthly revenue trend (total order price per month).
SELECT 
    *
FROM
    products
select * from employee;
select * from departments;
select * from transactions;
select * from customers;
select * from orders;

-- Query-3) Find departments with average salary greater than the overall company average.

-- Query-4) List employees who have not placed any orders, assuming emp_id maps to customer_id.

-- Query-5) For each department, show the employee with the longest tenure (based on hire_date).
select *
from
(
select
	e.name,
    d.department_name,
    datediff(current_date(), e.hire_date)/365 as Tenure,
    row_number() over (partition by e.department_id order by (year(current_date()) - year(e.hire_date)) desc) as RNK
from employee as e
join departments as d
	on e.department_id = d.department_id
) as x
where x.RNK = 1;





