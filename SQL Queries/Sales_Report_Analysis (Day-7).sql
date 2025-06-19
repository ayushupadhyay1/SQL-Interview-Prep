use Sales_and_Reporting_Analysis;

-- ============================================================ BASIC ========================================================================

-- Query-1) Write a query to find each department’s total revenue and total cost.
with department_total_cost as
(
select
	d.department_id,
    d.department_name,
    sum(c.cost_amount) as total_cost
from departments as d
join costs as c
	on c.department_id = d.department_id
group by d.department_id, d.department_name
),
department_total_revenue as
(
select
	d.department_id,
    d.department_name,
    sum(s.revenue) as total_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name
)
select 
	dtc.department_name,
    dtc.total_cost,
    dtr.total_revenue
from department_total_cost as dtc
join department_total_revenue as dtr
	on dtc.department_id = dtr.department_id;
    

-- Query-2) List all employees who have never made a sale.
select 
	e.employee_id,
    e.full_name
from employees as e
left join sales as s
	on e.employee_id = s.employee_id
where s.employee_id is NULL;

-- Query-3) Show the number of sales and total revenue for each product category.
select
	product_category,
    count(sale_id) as Number_Of_Sales_Count,
    round(sum(revenue),0) as total_revenue
from sales
group by product_category;

-- Query-4) Find departments where the average cost per cost entry is above ₹10,000.
select 
	d.department_name,
    round(avg(c.cost_amount),2) as average_cost_amount
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_name
having avg(c.cost_amount) > 10000;

-- Query-5) Get the list of employees who joined before 2022 and are still marked as "Active".
select
	e.employee_id,
    e.full_name
from employees as e
where year(e.hire_date) < 2022 and e.status = 'Active';

-- ============================================================ INTERMEDIATE ========================================================================
-- Query-6) For each employee, calculate total revenue, number of sales, and average sale value.
select 
	e.employee_id,
    e.full_name,
    coalesce(sum(s.revenue), 0) as total_Revenue,
    count(s.sale_id) as sale_count,
    round(coalesce(avg(s.revenue),0),2) as average_sale_value
from employees as e
left join sales as s
	on e.employee_id = s.employee_id
group by e.employee_id, e.full_name;

-- Query-7) Write a CTE that calculates the average revenue per department, and return employees whose revenue is above their department average.
with department_total_revenue as
(
select 
	d.department_id,
    d.department_name,
    avg(s.revenue) as average_department_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s	
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name
),
employee_revenue_performance as
(
select 
	e.employee_id,
    d.department_id,
    s.revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
)
select 
	dtr.department_id,
    dtr.department_name,
    round(dtr.average_department_revenue,2) as average_department_revenue,
    erp.employee_id,
    erp.revenue
from department_total_revenue as dtr
join employee_revenue_performance erp
	on dtr.department_id = erp.department_id
where erp.revenue > dtr.average_department_revenue;

-- Query-8) Create a monthly summary that shows: department name, month, total revenue, total cost, and revenue-to-cost ratio.
with department_monthly_revenue as
(
select 
	d.department_id,
	d.department_name,
    month(s.sale_date) as Months,
    sum(s.revenue) as total_revenue
from departments as d
join employees as e
	on e.department_id = d.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name, month(s.sale_date)
),
departmetn_total_cost as
(
select
	d.department_id,
    month(c.cost_Date) as Months,
    sum(c.cost_amount) as total_cost
from departments as d
join costs as c
	on d.department_id = c.department_id
    group by d.department_id, month(c.cost_Date)
)
select 
	dmr.department_name,
    dmr.Months,
    dmr.total_revenue,
    dtc.total_cost,
	round(dmr.total_revenue /  NULLIF(dtc.total_cost,0), 2) as Revenue_to_cost_ratio
from department_monthly_revenue as dmr
join departmetn_total_cost as dtc 
	on dmr.department_id = dtc.department_id and dmr.Months = dtc.Months;

-- Query-9) Show the top 2 employees by total revenue in each department using a window function.
with employee_with_total_revenue as
(
select 	
	e.employee_id,
    e.Full_Name,
    d.department_id,
    d.department_name,
    sum(s.revenue) as total_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by e.employee_id, e.Full_Name, d.department_id, d.department_name
)
select
	employee_id,
    Full_Name,
    department_name,
    total_revenue,
    rank() over (partition by department_id order by total_revenue desc) as RNK
from employee_with_total_revenue;

-- ============================================================ ADVANCED ========================================================================

-- Query-10) Write a query to detect duplicate sales (same employee_id, sale_date, and revenue).
select 
	count(*),
	e.employee_id,
    s.sale_date,
    s.revenue
from employees as e
join sales as s
	on e.employee_id = s.employee_id
group by e.employee_id, s.sale_date, s.revenue
having count(*) > 1;

-- Query-11) Create a report that shows each department’s "Revenue Efficiency" status:
-- "Excellent" if ratio > 3, "Good" if between 2–3, "Needs Review" if < 2
with department_total_revenue as
(
select 
	d.department_id,
    d.department_name,
    sum(s.revenue) as Total_Revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name
),
department_total_cost as 
(
select
	d.department_id,
    d.department_name,
    sum(c.cost_amount) as total_cost
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_id, d.department_name
)
select 
	dtr.department_id,
    dtr.department_name,
    dtr.Total_Revenue,
    dtc.total_cost,
    round(dtr.Total_Revenue /  dtc.total_cost, 2) as Revenue_Performance,
    case
		when round(dtr.Total_Revenue /  dtc.total_cost, 2) > 3 then 'Excellent '
        when round(dtr.Total_Revenue /  dtc.total_cost, 2) between 2 and 3 then 'Good '
        when round(dtr.Total_Revenue /  dtc.total_cost, 2) < 2 then 'Need Review '
    end as Revenue_Status
from department_total_revenue as dtr
join department_total_cost dtc
	on dtr.department_id = dtc.department_id;
