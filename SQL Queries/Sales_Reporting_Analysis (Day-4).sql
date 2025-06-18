use Sales_and_Reporting_Analysis;


-- --------------------------------------------------- DATA QUALITY CHECKS -----------------------------------------------------------------
-- Query-1) Write a query to detect employees with missing or NULL values in salary or status fields.
select
	employee_id,
    full_name
from employees
where salary is NULL or status is NULL;


-- Query-2) Identify sales records where the employee_id does not exist in the employees table.
select 
	s.sale_id
from sales as s
left join employees as e
	on e.employee_id = s.employee_id
where e.employee_id is NULL;


-- Query-3) Find departments that have cost entries but no employees assigned to them.
select 
	d.department_id,
    d.department_name
from departments as d
left join costs as c	
	on c.department_id = d.department_id
left join employees as e
	on e.department_id = d.department_id
where c.cost_id is NOT NULL and e.employee_id is NULL;

-- -------------------------------------------------------- SUB QUEREIS ----------------------------------------------------------------------

-- Query-4) Get a list of employees whose salary is above the average salary of their department.
select 
	e.employee_id,
    e.department_id,
	e.full_name,
	e.salary
from employees as e
where e.salary > (
				select 
                    avg(e2.salary) as average_salary
                from employees as e2
                where e2.department_id = e.department_id
);



-- Query-5) Find departments where total cost is higher than the average cost across all departments.
select 
	d.department_id,
    d.department_name,
    sum(c.cost_amount) as total_cost_amount
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_id, d.department_name
having sum(c.cost_amount) > (
								select avg(dept_total_cost) 
                                from 
                                (
								select 
									sum(cost_amount) as dept_total_cost
                                from costs
                                group by department_id
								) as dept_cost                            
);

-- Query-6) List employees who have made more sales than the average number of sales per employee.
select
	e.employee_id,
    e.full_name,
    count(s.sale_id) as individual_sale_count
from employees as e
join sales as s
	on e.employee_id = s.employee_id
group by e.employee_id, e.full_name
having count(s.sale_id) > (
							select
								avg(sales_count) as average_sales_count
                            from
                            (
							select
								count(*) as sales_count
                            from sales
                            group by employee_id
                            ) as employee_per_count

);

-- -------------------------------------------------------- Reporting Readiness + CASE Logic ----------------------------------------------------------------------

-- Query-7) Create a column that classifies departments as 'Over Budget' if their total cost > $30,000, else 'Within Budget'.
select
	d.department_id,
    d.department_name,
    sum(cost_amount) as total_cost,
    case
		when sum(cost_amount) > 30000 then 'Over Budget'
        else 'Within Budget'
    end as department_category
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_id, d.department_name;

-- Query-8) Generate a query that adds a column flagging sales records as "High Value" if revenue > $50,000, else "Regular".
select
	sale_id,
    product_category,
    revenue,
    case
		when revenue > 50000 then 'High Value'
        else 'Regular'
    end as revenue_classification
from sales;

-- Query-9) Identify duplicate sales entries by employee and sale date (assume duplicates are not allowed).
select
	employee_id,
    sale_date,
    count(*) as sale_count
from sales
group by employee_id, sale_date
having count(*) > 1;


-- -------------------------------------------------------- Views & Reusability ----------------------------------------------------------------------

-- Query-10) Create a view called employee_sales_summary with employee name, department, total sales, and number of sales made.
create or replace view employee_sales_summary as
(
select 
	e.full_name as employee_name,
    d.department_name,
    sum(s.revenue) as total_sales,
    count(s.sale_id) as number_of_sales
from employees as e
join sales as s
	on e.employee_id = s.employee_id
join departments as d
	on d.department_id = e.department_id
group by e.full_name, d.department_name
);

select * from employee_sales_summary;

-- Query-11) Create a view called department_costs_trend that shows department name, month, and total monthly cost — suitable for Power BI or Tableau.
create or replace view department_costs_trend as
select 
	d.department_name,
    date_format(cost_date, '%M') as Months,
    sum(cost_amount) as total_cost
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_name, date_format(cost_date, '%M');

select * from department_costs_trend;


