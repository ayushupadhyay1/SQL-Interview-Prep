use Sales_and_Reporting_Analysis;



-- =========================================================== BEGGINER ====================================================================
-- Query-1) Write a query to find the total cost per department, grouped by cost_type, for the year 2023.

select 
    d.department_name,
    c.cost_type,
    sum(c.cost_amount) as total_cost
from departments as d
join costs as c
	on d.department_id = c.department_id
where year(cost_Date) = 2023
group by d.department_name, c.cost_type;


-- Query-2) Retrieve each employee's full name, department name, and their total revenue from sales.
select 
	e.Full_name,
    d.department_name,
    sum(s.revenue) as totla_revenu_from_sales
from employees as e
join departments as d
	on e.department_id = d.department_id
join sales as s
	on s.employee_id = e.employee_id
group by e.full_name, d.department_name
order by totla_revenu_from_sales desc;

-- Query-3) List all departments that have incurred more than $10,000 in total costs.
select 	
	d.department_name,
    sum(c.cost_amount) as total_cost
from departments as d 
join costs as c
	on d.department_id = c.department_id
group by d.department_name
having sum(c.cost_amount) > 10000
order by total_cost desc;

-- Query-4) Show the number of active employees in each department.
select 
	d.department_name,
    count(e.employee_id) as Active_employee_count
from departments as d
join employees as e
	on d.department_id = e.department_id
where e.status = 'Active'
group by d.department_name
order by Active_employee_count desc;

-- =========================================================== INTERMEDIATE ====================================================================

-- Query-5) Find all employees who have made more than one sale.
select 
	e.employee_id,
    e.full_name,
    count(s.sale_id) as sales_count
from employees as e
join sales as s
	on e.employee_id = s.employee_id
group by e.employee_id, e.full_name
having count(s.sale_id) > 1
order by sales_count desc;


-- Query-6) For each department, calculate the average monthly revenue in 2023 and return only those departments with averages above $50,000.
with monthly_revenue as
(
select 
	d.department_id,
    d.department_name,
    date_format(s.sale_date, '%Y - %m') as Date_,
    round(sum(s.revenue),2) as total_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
where year(s.sale_date) = 2023
group by d.department_id, d.department_name, Date_
)
select
	department_id,
    department_name,
    round(avg(total_revenue),2) as average_total_revenue
from monthly_revenue
group by department_id, department_name
having avg(total_revenue) > 50000
order by average_total_revenue desc;



-- Query-7) Display each employee’s name, department, and label them as "High Performer" if their total revenue exceeds $100,000; otherwise label them "Average Performer".
select 	
	e.full_name,
    d.department_name ,
    sum(s.revenue) as total_revenue,
    case
		when sum(s.revenue) >= 100000 then 'High Performer'
        else 'Average Performer'
    end as Employee_Performance
from employees as e
join departments as d
	on e.department_id = d.department_id
join sales as s
	on s.employee_id = e.employee_id
group by e.full_name, d.department_name
order by total_revenue desc;

-- Query-8) Write a query to return each department’s total cost and total revenue in 2023.
with total_cost_per_department as
(
select 
	d.department_id,
    sum(cost_amount) as total_cost_amount
from departments as d
join costs as c
	on d.department_id = c.department_id
where year(c.cost_date) = 2023
group by d.department_id
), total_revenue_per_department as
(
select
	d.department_id,
    sum(revenue) as total_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
where year(s.sale_date) = 2023
group by d.department_id
)
select 
	d.department_name,
    coalesce(cpd.total_cost_amount,0) as total_cost,
    coalesce(rpd.total_revenue,0) as total_revenue_
from departments as d
left join total_cost_per_department as cpd
	on d.department_id = cpd.department_id
left join total_revenue_per_department as rpd
	on d.department_id = rpd.department_id
order by total_cost desc, total_revenue_ desc;


-- Query-9) Create a CTE that calculates monthly revenue for each department, and use it to find the month with the highest revenue for each department.
with revenue_for_department as
(
select 
	d.department_id,
    d.department_name,
    date_format(s.sale_date, '%Y-%m') as sale_date_,
    sum(revenue) as total_monthly_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name, sale_date_
), ranked_revenu as
(
select
	*,
    rank() over (partition by department_id order by total_monthly_revenue desc) as RNK
from revenue_for_department
)
select
	department_id,
    department_name,
    sale_date_,
    total_monthly_revenue
from ranked_revenu
where RNK = 1;

-- =========================================================== ADVANCED ====================================================================
-- Query-10) Rank employees within their departments based on total revenue from sales.
with Employee_rank_based_on_revenue as
(
select 
	e.employee_id,
    e.full_name,
    d.department_name,
    sum(s.revenue) as total_revenue
from employees as e
join departments as d
	on e.department_id = d.department_id
join sales as s
	on s.employee_id = e.employee_id
group by e.employee_id, e.full_name, d.department_name
)
select
	employee_id,
    full_name,
    department_name,
    total_revenue,
    row_number() over (partition by department_name order by total_revenue desc) as RNK
from Employee_rank_based_on_revenue;


-- Query-11) Identify departments where total costs exceeded $30,000 in 2023.
select * 
from
(
select 
	d.department_id,
    d.department_name,
    sum(cost_amount) as total_cost
from departments as d
join costs as c
	on c.department_id = d.department_id
where year(cost_date) = 2023
group by d.department_id, d.department_name
) as departments_with_higher_revenue
where total_cost > 30000;

-- Query-12) Calculate the revenue-to-cost ratio for each department.
with total_cost_per_department as
(
select
	department_id,
    sum(cost_amount) as total_cost
from costs
group by department_id
), total_revenue_per_department as
(
select 
	d.department_id,
    sum(s.revenue) as total_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
group by department_id
)
select
	d.department_name,
    coalesce(trp.total_revenue, 0) as total_cost_,
    coalesce(cpd.total_cost, 0) as total_revenu_,
    case
		when coalesce(cpd.total_cost, 0) = 0 then NULL
        else round(coalesce(trp.total_revenue, 0) / cpd.total_cost, 2)
    end as revenu_to_cost_ratio
from departments as d
left join total_cost_per_department as cpd
	on d.department_id = cpd.department_id
left join total_revenue_per_department as trp
	on d.department_id = trp.department_id;

-- Query-13) For each department, list the top 2 employees by revenue contribution using a window function.
with top_2_employees as 
(
select 
	d.department_id,
    d.department_name,
    e.full_name,
    sum(s.revenue) as total_revenue,
    row_number() over (partition by d.department_id order by sum(s.revenue) desc) as RNK
from employees as e
join departments as d
	on e.department_id = d.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name, e.full_name
)
select
	department_id,
    department_name,
    full_name,
    total_revenue
from top_2_employees
where RNK <= 2;

-- Query-14) Find cost types that make up more than 50% of the total cost for their department.
select * from costs;
select * from departments;
select * from employees;
select * from sales;

WITH total_cost_per_department AS (
  SELECT
    department_id,
    SUM(cost_amount) AS total_cost
  FROM costs
  GROUP BY department_id
),
cost_type_distribution AS (
  SELECT
    c.department_id,
    c.cost_type,
    SUM(c.cost_amount) AS cost_type_total,
    tcd.total_cost,
    ROUND(SUM(c.cost_amount) / tcd.total_cost, 2) AS contribution_ratio
  FROM costs AS c
  JOIN total_cost_per_department AS tcd
    ON c.department_id = tcd.department_id
  GROUP BY c.department_id, c.cost_type, tcd.total_cost
)
SELECT
  d.department_name,
  ctd.cost_type,
  ctd.cost_type_total,
  ctd.total_cost,
  ctd.contribution_ratio
FROM cost_type_distribution AS ctd
JOIN departments AS d
  ON ctd.department_id = d.department_id
WHERE ctd.contribution_ratio > 0.5
ORDER BY d.department_name;




