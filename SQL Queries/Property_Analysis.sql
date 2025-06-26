use property_analysis;

-- Query-1) Get the list of properties with their occupancy status based on whether they have at least one active lease.
select 
	p.property_id,
    p.name,
    p.type,
    p.city,
    case
		when count(case when l.lease_status = 'Active' then 1 end) > 0 then 'Occupied'
        else 'Vacant'
    end as occupanct_status
from Properties as p
left join leases as l
	on p.property_id = l.property_id
group by p.property_id, p.name, p.type, p.city, lease_status;


-- Query-2) For each property, calculate the total annual rent generated from all active leases.
select 
	p.property_id,
    p.name,
    sum(l.monthly_rent * 12) as total_rent
from leases as l
join properties as p
	on l.property_id = p.property_id
where lease_status = 'Active'
group by p.property_id, p.name;

-- Query-3) List all leases expiring within the next 6 months from today’s date.
select
	l.lease_id,
    l.property_id,
    p.name,
    l.lease_start,
    l.lease_end
from leases as l
join properties as p
	on l.property_id = p.property_id
where l.lease_end between current_date() and current_date() + interval 6 month;

-- Query-4) Show the count of tenants grouped by industry, sorted in descending order.
select
	t.industry,
    count(t.tenant_id) as Tenent_Count
from tenants as t
group by t.industry
order by Tenent_Count desc;

-- Query-5) For each property, calculate the total expenses per category (e.g., Utilities, Maintenance, Taxes).
with total_expenses as
(
select 
	p.property_id,
    p.name,
    pe.category,
    sum(amount) as total_expenses,
    rank() over (partition by pe.category order by sum(amount) desc) as RNK
from properties as p
join Property_Expenses as pe
	on p.property_id = pe.property_id
group by p.property_id, p.name, pe.category
)
select
	property_id,
    name,
    category,
    total_expenses
from total_expenses;

-- Query-6) For all leases, calculate the duration in months between lease_start and lease_end.
select
	lease_id,
    lease_start,
    lease_end,
    round(datediff(lease_end, lease_start) / 30.44, 2) as Duration
from leases;


-- Query-7) Identify properties that have expired leases but no active ones.
select 
    p.property_id,
    p.name
from properties as p
join leases as l
	on p.property_id = l.property_id
group by p.property_id, p.name
having
	sum(case when l.lease_status = 'Expired' then 1 else 0 end) > 0
    and sum(case when l.lease_status = 'Active' then 1 else 0 end) = 0;

-- Query-8) Show the average rent per square foot for each property (only for active leases).
select 
	p.property_id,
    p.name,
    round(avg((l.monthly_rent* 12) / p.square_feet), 2) as average_rent_per_square_feet
from properties as p
join leases as l
	on p.property_id = l.property_id
where l.lease_status = 'Active'
group by p.property_id, p.name;

-- Query-9) List tenants who are paying more than $25,000 in monthly rent, along with their property names.
select *
from
(
select 
	t.tenant_id,
    t.tenant_name,
    p.name as property_name,
    l.monthly_rent as monthly_rent
from tenants as t
join leases as l
	on t.tenant_id = l.tenant_id
join properties as p
	on p.property_id = l.property_id
) as tenant_information 
where monthly_rent > 25000;

-- Query-10) Show the total expenses per month across all properties for the current year.
select 
	p.property_id,
    p.name,
    month(pe.expense_date) as expense_month,
    sum(pe.amount) as total_monthly_expenses
from properties as p
join property_expenses as pe
	on p.property_id = pe.property_id
where year(pe.expense_date) = year(current_date)
group by p.property_id, p.name, month(pe.expense_date)
order by p.property_id, expense_month;

-- Query-11) Find the top 3 properties with the highest total maintenance expenses.
select 
	p.property_id,
    p.name,
    sum(amount) as total_maintenance_amount
from properties as p
join property_expenses as pe
	on p.property_id = pe.property_id
where pe.category = 'Maintenance' 
group by p.property_id, p.name
order by total_maintenance_amount desc
limit 3;

-- Query-12) List properties that currently do not have any leases (active, expired, or terminated).
select 
	p.property_id,
    p.name
from properties as p
left join leases as l
	on p.property_id = l.property_id
where l.property_id is NULL;

-- Query-13) List all leases that are set to expire within 3 months and are marked as Active. Assume these need renewal.
select
	l.lease_id,
    l.lease_start,
    l.lease_end
from leases as l
where l.lease_end between current_date() and current_date() + interval 3 month
and l.lease_status = 'Active';

-- Query-14) Calculate the age (in years) of each property as of today. 
select
	p.property_id,
    p.name,
    type,
    year_built,
	(year(current_date) - p.year_built) as Building_age_in_year
from properties as p;


