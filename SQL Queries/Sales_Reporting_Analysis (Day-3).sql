use Sales_and_Reporting_Analysis;

-- ---------------------------------------------------- INTERMEDIATE -------------------------------------------------------------------------
-- Query-1) Write a query to find departments with no sales activity in 2023.
select 
	d.department_id,
    d.department_name
from departments as d
left join employees as e
	on d.department_id = e.department_id
left join sales as s
	on s.employee_id = e.employee_id and year(s.sale_date) = 2023
where s.sale_id is NULL;


-- Query-2) For each department, calculate total cost and average salary of employees.
select 
	d.department_id,
    d.department_name,
    round(tc.total_cost, 2) as total_cost,
    round(avg_sal.average_salary, 2) as average_salary
from departments as d
left join (
	select 
		department_id,
        sum(cost_amount) as total_cost
    from costs 
    group by department_id
) as tc on d.department_id = tc.department_id
left join (
	select
		department_id,
        avg(salary) as average_salary
    from employees
    group by department_id
) as avg_sal on d.department_id = avg_sal.department_id;
    

-- Query-3) Get a list of employees who made at least one sale in Q1 but no sales in Q2.
select 
	e.employee_id,
    e.full_name
from employees as e
left join sales as s
	on e.employee_id = s.employee_id and year(s.sale_date) = 2023
group by e.employee_id, e.full_name
having
	sum(case when month(s.sale_date) between 1 and 3 then 1 else 0 end) >= 1
    and sum(case when month(s.sale_date) between 4 and 6 then 1 else 0 end) = 0;


-- Query-4) Show department-wise average monthly revenue in 2023.
select 
	d.department_id,
    d.department_name,
	month(s.sale_date) as Months,
    round(avg(s.revenue),2) as average_revenue
from departments as d
join employees as e
	on d.department_id = e.department_id
join sales as s
	on s.employee_id = e.employee_id
where year(s.sale_date) = 2023
group by d.department_id, d.department_name, month(s.sale_date)
order by d.department_id, Months;

-- ---------------------------------------------------- ADVANCED -------------------------------------------------------------------------

-- Query-5) Write a query to show revenue contribution % by employee within their department.



-- Query-6)Create a view named dept_summary that contains department ID, total revenue, total cost, and revenue-to-cost ratio.
create or replace view dept_summary as
(
select 
	d.department_id,
    sum(s.revenue) as total_revenue,
    sum(c.cost_amount) as total_cost_amount,
    round(sum(s.revenue) / NULLIF(sum(c.cost_amount),0),2) as revenue_to_cost_ratio
from departments as d
join costs as c
	on d.department_id = c.department_id
join employees as e
	on e.department_id = d.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_id
);

select * from dept_summary;

-- Query-7) Find departments where more than 50% of total cost comes from a single cost_type.
select 
	d.department_id,
    d.department_name,
    c.cost_type,
    round(sum(c.cost_amount) * 100 / (select sum(cost_amount) from costs),2) as cost_percentage
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_id, d.department_name, c.cost_type
having round(sum(c.cost_amount) * 100 / (select sum(cost_amount) from costs),2) > 50;


-- Query-8) For each month in 2023, list the top-selling product category by revenue.
with monthly_category_revenue as
(
select
	product_category,
    month(sale_date) as sale_month,
    sum(revenue) as total_revenue
from sales
where year(sale_date) = 2023
group by product_category, month(sale_date)
),

top_performaing_products as
(
select
	product_category,
    sale_month,
    total_revenue,
    rank() over (partition by sale_month order by total_revenue desc) as RNK
from monthly_category_revenue
)
select
	product_category,
    sale_month,
    total_revenue
from top_performaing_products
where RNK = 1;

-- Query-9) Use a correlated subquery to find employees whose salary is above the average salary of their department.		
select
	e.employee_id,
    e.full_name,
    e.department_id,
    e.salary
from employees as e
where e.salary > (
					select
						avg(e2.salary) as average_salary
                    from employees as e2
                    where e2.department_id = e.department_id
);

-- Query-10) 
-- To create a dataset suitable for Tableau with:
-- Department name
-- Monthly revenue
-- Monthly cost
-- Revenue-to-cost ratio
-- Revenue growth compared to previous month

with monthly_revenue as
(
select 
	d.department_id,
	d.department_name,
    date_format(s.sale_date, '%Y-%m') as months,
    sum(s.revenue) as total_revenue
from departments as d
join costs as c
	on c.department_id = d.department_id
join employees as e
	on e.department_id = d.department_id
join sales as s
	on s.employee_id = e.employee_id
group by d.department_id, d.department_name, date_format(s.sale_date, '%Y-%m')
),

monthly_cost as
(
select 
	d.department_id,
    date_format(c.cost_date, '%Y-%m') as Months,
    sum(c.cost_amount) as total_cost
from departments as d
join costs as c
	on d.department_id = c.department_id
group by d.department_id, date_format(c.cost_date, '%Y-%m')
),

combines_revenue as
(
select 
	mr.department_id,
    mr.department_name,
    mr.months,
    mr.total_revenue,
    coalesce(mc.total_cost, 0) as total_cost,
    round(mr.total_revenue / nullif(mc.total_cost,0),2) as revenue_to_cost_ratio
from monthly_revenue as mr
left join monthly_cost as mc
	on mr.department_id = mc.department_id and mr.Months = mc.Months
)
select
    department_name,
    months,
    total_revenue,
    total_cost,
    revenue_to_cost_ratio,
    total_revenue - round(lag(total_revenue) over (partition by department_id order by months),2) as revenue_growth
from combines_revenue;











