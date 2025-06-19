use Sales_and_Reporting_Analysis;

-- -------------------------------------------------- Multi-CTE / Report-Level Logic -----------------------------------------------------------

-- Query-1) Write a multi-CTE query that outputs:
-- "Department Name", "Month (2023)", "Total Revenue", "Total Cost", "Revenue-to-Cost Ratio", "MoM % change in revenue"
with department_revenue_info as
(
select 
	d.department_id,
	d.department_name,
    date_format(s.sale_date, '%M-%y') as Months,
    round(sum(s.revenue),2) as total_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s	
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name, date_format(s.sale_date, '%M-%y')
),
department_cost_info as
(
select
	d.department_id,
    d.department_name,
    date_format(c.cost_date, '%M-%y') as Months,
    sum(c.cost_amount) as total_cost
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_id, d.department_name,  date_format(c.cost_date, '%M-%y')
),
revenue_with_change as
(
select 
	dri.department_id,
    dri.department_name,
    dri.Months,
    dri.Total_Revenue,
    dci.total_cost,
    round(dri.Total_Revenue / NULLIF(dci.total_cost,0),2) as Revenue_to_Cost_Ratio,
    lag(dri.Total_Revenue) over (partition by dri.department_id order by dri.Months) as Previous_Month_Revenue
from department_revenue_info as dri
left join department_cost_info dci
	on dri.department_id = dci.department_id and dri.Months = dci.Months
)
select
	department_name,
    Months,
    Total_Revenue,
    total_cost,
    Revenue_to_Cost_Ratio,
    round((Total_Revenue - Previous_Month_Revenue) / NULLIF(Previous_Month_Revenue,0) * 100, 2) as 'M_O_M Change'
from revenue_with_change;

-- Query-2) Create a view that shows, for each employee:
-- "Department", "Hire Month", "Total Sales"
-- Revenue Flag ("Top", "Above Avg", "Below Avg" based on total revenue percentile
create or replace view employee_performance as
(
with department_and_revenue_percentile as
(
select 
	e.employee_id,
    e.full_name,
	d.department_name,
    Month(e.hire_date) as Hire_Month,
    sum(s.revenue) as Total_Sales,
    Percent_Rank() over (order by sum(s.revenue)) as Percent_Rank_
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_name, Month(e.hire_date), e.employee_id, e.full_name
)
select
	employee_id,
	full_name,
	department_name,
    Hire_Month,
    Total_Sales,
    Percent_Rank_,
    case
		when Percent_Rank_ >= 0.7 then 'High'
        when Percent_Rank_ between 0.4 and 0.7 then 'Medium'
        Else 'Low'
    end as Revenue_Flag
from department_and_revenue_percentile
);

select * from employee_performance;

-- Query-3) Build a monthly department summary that includes:
-- "Number of employees", "Number of active employees", "Sales per employee", "Cost per employee"
with employee_count_departments as
(
select 
	d.department_id,
    d.department_name,
    count(e.employee_id) as Total_Employees
from departments as d
join employees as e	
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name
),
Active_Employee as
(
select
	d.department_id,
	count(e.employee_id) as Active_Employee_Count
from departments as d
join employees as e	
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
where e.status = 'Active'
group by d.department_id
),
sale_per_employees as
(
select
	d.department_id,
    sum(s.revenue) as total_sales,
    sum(c.cost_amount) as total_cost
from departments as d
join employees as e	
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
join costs as c
	on c.department_id = d.department_id
group by d.department_id
)
select 
	ecd.department_name,
    ecd.Total_Employees,
    ae.Active_Employee_Count,
	spe.total_sales,
    spe.total_cost
from employee_count_departments as ecd
join Active_Employee as ae
	on ecd.department_id = ae.department_id
join sale_per_employees as spe
	on spe.department_id = ecd.department_id;

-- -------------------------------------------------- Data Gaps, Anomalies & Cleaning-----------------------------------------------------------

-- Query-4) Find any employees who made a sale but are no longer marked as "Active".
select 
	distinct e.employee_id
from employees as e
left join sales as s
	on e.employee_id = s.employee_id
where s.employee_id is NOT NULL and e.status != 'Active';

-- Query-5) Detect potential duplicate sales by comparing rows with the same employee_id, sale_date, and similar revenue.
with duplicate_sale as
(
select 
	count(*) as RNK,
	e.employee_id,
    s.sale_date,
    revenue
from employees as e
join sales as s
	on e.employee_id = s.employee_id
group by e.employee_id, s.sale_date, revenue
)
select
	employee_id,
    sale_date,
    revenue
from duplicate_sale
where RNK > 1;


-- Query-6) Identify any cost entries that do not have a matching department in the departments table.
select 
	c.cost_id
from costs as c
left join departments as d
	on c.department_id = d.department_id
where d.department_id is NULL;

-- Query-7) Show sales records where revenue is greater than 2x the employee's average revenue per sale.
with employee_average_revenue as
(
select 
	s.employee_id,
    round(avg(s.revenue),2) as average_revenue
from sales as s
group by s.employee_id
),
revenue_per_Sale as 
(
select 
    s.sale_id,
    s.employee_id,
    s.revenue as total_Revenue
from sales as s
)
select 
	rps.sale_id,
    rps.employee_id,
    rps.total_Revenue,
    ear.average_revenue
from employee_average_revenue as ear 
join revenue_per_Sale as rps 
	on ear.employee_id = rps.employee_id
where rps.total_Revenue > 2 * ear.average_revenue;
-- -------------------------------------------------- Analytics-Driven & Strategy-Ready -----------------------------------------------------------

-- Query-8) Create a summary table that shows for each product category:
-- "Total revenue", "Number of unique employees who sold it", "Avg revenue per employee", "Highest single-sale revenue"
with top_single_sale_revenue as
(
  select
    product_category,
    max(revenue) as highest_single_sale_revenue
  from sales
  group by product_category
),
total_product_category_revenue as
(
  select
    product_category,
    sum(revenue) as total_revenue,
    count(distinct employee_id) as unique_employees
  from sales
  group by product_category
)
select
  tpc.product_category,
  tpc.total_revenue,
  tpc.unique_employees,
  round(tpc.total_revenue / nullif(tpc.unique_employees,0), 2) as avg_revenue_per_employee,
  tsr.highest_single_sale_revenue
from total_product_category_revenue tpc
join top_single_sale_revenue tsr
  on tpc.product_category = tsr.product_category;




