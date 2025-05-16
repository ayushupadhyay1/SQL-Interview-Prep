use property_insights;

-- Query-1) Find the top 3 most expensive properties and their corresponding cities and property types.
select
	property_id,
    city,
    property_type,
    price
from properties 
order by price desc
limit 3;

-- Query-2) List all clients who have purchased properties worth more than $20,000,000.
select
	c.client_id,
    c.name,
    t.sale_price
from clients as c
join transactions as t
	on c.client_id = t.client_id
where t.sale_price > 20000000;


-- Query-3) Find the total transaction value handled by each agent.
select
	a.agent_id,
    a.name,
    sum(t.sale_price) as Total_transaction_value
from agents as a
join transactions as t
	on a.agent_id = t.agent_id
group by a.agent_id, a.name;


-- Query-4) Which city has the highest total sales value from closed transactions?
select
    p.city,
    sum(sale_price) as total_sale_price
from properties as p	
join transactions as t
	on p.property_id = t.property_id
where t.status = 'closed'
group by p.city
order by total_sale_price desc
limit 1;

-- Query-5) List all properties that are yet to be sold (not present in any transaction).
select
	p.property_id,
    p.address
from properties as p
left join transactions as t
	on p.property_id = t.property_id
where t.property_id is NULL;


-- Query-6) Find the average sale price by property type.
select
	p.property_type,
    round(avg(t.sale_price),2) as average_sale_price
from properties as p
join transactions as t
	on p.property_id = t.property_id
group by p.property_type
order by average_sale_price desc;


-- Query-7) List all agents who have not closed any transactions in 2023.
select
	a.agent_id,
    a.name
from agents as a
left join transactions as t
	on a.agent_id = t.agent_id
	and t.status = 'closed'
    and year(t.transaction_Date) = 2023
where t.transaction_id IS NULL;

-- Query-8) Identify clients who have purchased more than one property.
select
	c.client_id,
    c.name,
    count(t.property_id) as property_count
from clients as c
join transactions as t
	on c.client_id = t.client_id
group by c.client_id, c.name
having count(t.property_id) > 1;

-- Query-9) Which agent has sold the most square footage in total?
select 
	t.agent_id,
    a.name,
    sum(p.size_sqft) as total_square_feet
from agents as a 
join transactions as t
	on a.agent_id = t.agent_id
join properties as p
	on p.property_id = t.property_id
group by a.agent_id, a.name
order by total_square_feet desc
limit 1;

-- Query-10) List the properties sold in Q2 of 2023 along with agent and client names.
select 
	p.property_id,
    a.name as agent_name,
    c.name as client_name
from clients as c
join transactions as t
	on c.client_id = t.client_id
join properties as p
	on p.property_id = t.property_id
join agents as a
	on a.agent_id = t.agent_id
where year(t.transaction_date) = 2023 and  month(t.transaction_date) in (4,5,6);

-- Query-11) What is the difference between the listed price and sale price for each transaction?
select
	t.transaction_id,
    p.price as listed_price,
    t.sale_price,
    p.price - t.sale_price as difference
from properties as p
join transactions as t
	on p.property_id = t.property_id;

-- Query-12) Which property type brings in the highest total revenue?
select	
	p.property_type,
    sum(t.sale_price) as highest_total_revenue
from properties as p
join transactions as t
	on p.property_id = t.property_id
group by p.property_type
order by highest_total_revenue desc
limit 1;


-- Query-13) Find the most active client in terms of number of transactions.
select
	c.client_id,
    c.name,
    count(t.transaction_id) as clinet_activity_count
from clients as c
join transactions as t
	on c.client_id = t.client_id
group by c.client_id, c.name
order by clinet_activity_count desc
limit 1;


-- Query-14) List agents who have transactions with clients from more than one company.
select
	a.agent_id,
    a.name,
    count(distinct c.company) as distinct_company_count
from agents as a
join transactions as t
	on a.agent_id = t.agent_id
join clients as c
	on c.client_id = t.client_id
group by a.agent_id, a.name
having count(distinct c.company) > 1;

-- ===========================================================================================================================================
-- ============================================================= SQL ADVANCED TOPICS =========================================================
-- ===========================================================================================================================================

-- -------------------------------------------------------------- Window Function ------------------------------------------------------------

-- Query-1) For each agent, show their total sales and their ranking by sales amount within their city.
with total_sales_per_agent as 
(
select 
	a.agent_id,
    a.name,
    p.city,
    sum(t.sale_price) as total_sale_price
from agents as a
join transactions as t
	on a.agent_id = t.agent_id
join properties as p
	on p.property_id = t.property_id
group by a.agent_id, a.name, p.city
)
select
	agent_id,
    name,
    city,
    total_sale_price,
    rank() over (partition by city order by total_sale_price) as RNK
from total_sales_per_agent;


-- Query-2) Show each transaction along with the running total of sale prices for that agent. 
select 
	a.agent_id,
    a.name,
    t.transaction_id,
    t.transaction_date,
    t.sale_price,
    sum(t.sale_price) over (partition by a.agent_id order by  t.transaction_date rows between unbounded preceding and current row) as Running_Total
from agents as a
join transactions as t
	on a.agent_id = t.agent_id;

-- Query-3) List all transactions along with the average sale price in their city for the same month.
select 
	t.transaction_id,
    p.city,
    t.transaction_Date,
    t.sale_price,
    round(avg(t.sale_price) over (partition by p.city, year(t.transaction_Date), month(t.transaction_Date)),2) as city_month_avg
from properties as p
join transactions as t
	on p.property_id = t.property_id;
    
-- ---------------------------------------------------------------- CTE's --------------------------------------------------------------------

-- Query-1) Using a CTE, find all agents who have handled transactions totaling more than $50M.
with agent_handling_transactions_more_than_50M as
(
select 
	a.agent_id,
    a.name,
    sum(t.sale_price) as total_transactions
from agents as a
join transactions as t
	on a.agent_id = t.agent_id
group by a.agent_id, a.name
)
select
	agent_id,
    name,
    total_transactions
from agent_handling_transactions_more_than_50M
where total_transactions  > 50000000;

-- Query-2) Create a CTE that lists the top 5 most expensive properties per city.
with top_5_properties_per_city as 
(
select 
	p.property_id,
    p.address,
    p.price,
    p.city,
    row_number() over (partition by p.city order by p.price desc) as RNK
from  properties as p
)
select
	property_id,
    price,
    city,
    RNK
from top_5_properties_per_city
where RNK <= 5;


