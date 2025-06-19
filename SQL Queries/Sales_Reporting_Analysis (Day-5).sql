use Sales_and_Reporting_Analysis;

-- -------------------------------------------------- Window Functions & Rankings -----------------------------------------------------------

-- Query-1) For each department, rank employees based on their total sales revenue (highest to lowest).
with employee_ranking as
(
select 
	e.employee_id,
    e.full_name,
    d.department_name,
    sum(s.revenue) as total_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by e.employee_id, e.full_name,d.department_name
)
select
	employee_id,
    full_name,
    department_name,
    total_revenue,
    rank() over (partition by department_name order by total_revenue desc) as RNK
from employee_ranking;


-- Query-2) Retrieve each employee’s total sales and show the running total of revenue within their department.
with total_revenue_by_employee as
(
select 
	e.employee_id, 
    e.full_name,
    d.department_id,
	d.department_name,
    sum(s.revenue) as total_sales
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by e.employee_id, e.full_name, d.department_id, d.department_name
)
select
	employee_id,
    full_name,
    department_name,
    total_sales,
    sum(total_sales) over (partition by department_id order by total_sales) as running_total
from total_revenue_by_employee;

-- Query-3) Calculate the difference in revenue for each employee compared to the department average.
with employee_total_revenue as
(
select 
	e.employee_id,
    e.full_name,
    d.department_id,
    d.department_name,
    sum(s.revenue) as total_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by e.employee_id, e.full_name, d.department_id, d.department_name
),
department_average_revenue as
(
select 
	department_id,
    avg(total_revenue) as average_department_revenue
from employee_total_revenue
group by department_id
)
select
	er.employee_id,
    er.full_name,
    er.total_revenue,
    er.department_name,
    round(dr.average_department_revenue,2) as average_department_revenue_,
    round((er.total_revenue - dr.average_department_revenue),2) as revenue_difference
from employee_total_revenue as er
join department_average_revenue as dr
	on er.department_id = dr.department_id;
    
-- Query-4) Find the first sale (by date) made by each employee.
select 
	employee_id,
    full_name,
    sale_date
from 
(
select 
	e.employee_id,
    e.full_name,
    s.sale_date,
    rank() over (partition by e.employee_id order by sale_date) as RNK
from employees as e
join sales as s
	on e.employee_id = s.employee_id
) as first_sale_date
where RNK = 1;

-- Query-5) Show the month-over-month revenue growth for each department in 2023.
with Month_on_Month_Revenue as
(
select 	
	d.department_id,
	d.department_name,
    month(s.sale_date) as Months,
    sum(s.revenue) as current_month_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on e.employee_id = s.employee_id
where year(s.sale_date) = 2023
group by d.department_id, d.department_name, month(s.sale_date)
order by Months
),
revenue_with_growth as
(
select
	department_id,
	department_name,
    Months,
    current_month_revenue,
    lag(current_month_revenue) over (partition by department_name order by Months) as Previous_Revenue
from Month_on_Month_Revenue
)
select
	department_id,
    department_name,
    Months,
    current_month_revenue,
    Previous_Revenue,
    round((current_month_revenue - Previous_Revenue) / nullif(Previous_Revenue,0) * 100,2) as mom_revenue_growth
from revenue_with_growth;

-- -------------------------------------------------- Multi-Step Queries & KPI Chains -----------------------------------------------------------
-- Query-6) Write a query to calculate the average revenue per employee and flag those below the average.
with individual_employee_revenue as
(
select 
	e.employee_id,
    e.full_name,
    sum(s.revenue) as employee_revenue
from employees as e
join sales as s
	on e.employee_id = s.employee_id
group by e.employee_id, e.full_name
),
average_employee_revenue as
(
select
    avg(employee_revenue) as average_revenue
from individual_employee_revenue
)
select	
	ie.employee_id,
    ie.full_name,
    ie.employee_revenue,
    case
		when ie.employee_revenue < ae.average_revenue then 'below average'
        else 'Normal'
    end as employees_with_less_salary
from individual_employee_revenue as ie
cross join average_employee_revenue as ae;


-- Query-7) For each department and month, calculate total revenue, total cost, and their difference.
with department_with_total_cost as
(
select 
	d.department_id,
	d.department_name,
    date_format(c.cost_date, '%M-%Y') as Months,
    sum(c.cost_amount) as total_cost_amount
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_id, d.department_name, Months
),
department_with_total_sales as
(
select 
	d1.department_id,
	d1.department_name,
    DATE_FORMAT(s.sale_date, '%M-%Y') AS Months,
    sum(s.revenue) as total_sale_amount
from departments as d1
join employees as e
	on d1.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
    group by d1.department_id,  d1.department_name, Months
)
select 
	dep_cost.department_name,
    dep_cost.Months,
    dep_cost.total_cost_amount,
    dept_sales.total_sale_amount,
    (dept_sales.total_sale_amount - dep_cost.total_cost_amount) as difference
from department_with_total_cost as dep_cost
join department_with_total_sales as dept_sales
	on dep_cost.department_id = dept_sales.department_id
    and dep_cost.Months = dept_sales.Months;


-- Query-8) Create a summary that shows the percentage of total company revenue contributed by each department.

with total_company_revenue as
(
select
	sum(revenue) as total_revenue
from sales
)
select 
	d.department_name,
    sum(s.revenue) as department_revenue,
    (sum(s.revenue) / t.total_revenue) * 100 as revenue_percentage
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
cross join total_company_revenue as t
group by d.department_name, t.total_revenue
order by revenue_percentage desc;

-- Query-9) Build a query to display employee sales performance as "High", "Moderate", or "Low" based on their percentile rank within the company.
with employee_sales as
(
select 
	e.employee_id,
    e.full_name,
    sum(revenue) as total_sales
from employees as e
join sales as s
	on e.employee_id = s.employee_id
group by e.employee_id, e.full_name
),
percentile_distribution as
(
select
	employee_id,
    full_name,
    total_sales,
    percent_rank() over (order by total_sales) as sales_percentile
from employee_sales
)
select
	employee_id,
    full_name,
    total_sales,
    sales_percentile,
    case
		when sales_percentile >= 0.7 then 'High'
        when sales_percentile >= 0.3 then 'Moderate'
        else 'Low'
    end as percentile_distribution
from percentile_distribution;

-- -------------------------------------------------- Advanced Logic for Report Automation -----------------------------------------------------------

-- Query-10) Create a query that produces a report-ready table with: (department name, employee name, total revenue, 
-- total cost, rank within department, performance flag ("Above Avg" or "Below Avg")

-- Query-11) Find all employees who had no sales in the first half of 2023 but had at least one sale in the second half.

-- Query-12) Create a view that shows monthly aggregated metrics (revenue, cost, ratio) for all departments.

-- Query-13) Find employees whose sales values have increased in every consecutive quarter of 2023.

-- Query-14) Write a query that identifies and removes duplicate sales records based on employee ID and sale date, keeping only the one with the highest revenue.

