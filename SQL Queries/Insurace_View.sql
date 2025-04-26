use insurance_analysis;

-- Query-1) Create a view that shows name, state, and policy_type for all policyholders.
create view info as 
select 
	ph.Name,
    ph.state,
    p.policy_type
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id;

select * from info;

-- Query-2) Create a view to display all approved claims with their claim_amount, claim_date, and policy_type.
create or replace view claim_info as 
select
	c.claim_amount,
    c.claim_date,
    p.policy_type
from claims as c
join policies as p
	on c.policy_id = p.policy_id
where c.claim_status = 'Approved';

select * from claim_info;


-- Query-3) Create a view to list all policyholders from "Texas" along with their policy details.
create or replace view policy_holders_from_texas AS
select
	ph.name,
    ph.state,
    p.*
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
where ph.state = 'Texas';

select * from policy_holders_from_texas;

-- Query-5) Create a view to show all payments made for policies of type 'Life'.
create or replace view life_policies_payment_info as
select
	p.policy_type,
    pay.*
from payments as pay
join policies as p
	on pay.policy_id = p.policy_id
where p.policy_type = 'Life';

select * from life_policies_payment_info;


-- Query-6) Create a view with policyholders’ names and their total premium amounts.
create or replace view policyholders_total_premium_amount as 
select 
	 ph.name,
    sum(p.premium_amount) as total_premium_amount
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
group by ph.name
order by total_premium_amount desc;

select * from policyholders_total_premium_amount;

-- Query-7) Create a view that returns policies whose premium is above 400.
create or replace view policies_above_400 as
select
	policy_type,
    premium_amount
from policies 
where premium_amount > 400;

select * from policies_above_400;


-- Query-8) Create a view that lists each policyholder and the total amount they've paid (sum of payments).
create or replace view paid_policy_amount as
select
	ph.name,
    sum(c.claim_amount) as total_claim_amount
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
join claims as c
	on c.policy_id = p.policy_id
group by ph.name;
    
select * from paid_policy_amount;

-- Query-9) Create a view that joins PolicyHolders, Policies, and Claims to show pending claims by user.
create or replace view pending_claims as
select 
	ph.name,
    p.policy_type,
    c.claim_id
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
left join claims as c
	on c.policy_id = p.policy_id
where c.claim_id is NULL;

select * from pending_claims;

-- Query-10) Create a view that displays the average premium amount per policy type.
create or replace view average_amount_per_policy as 
select
	policy_type,
    round(avg(premium_amount),2) as averager_amount
from policies
group by policy_type
order by averager_amount asc;

select * 
from average_amount_per_policy;

-- Query-11) Create a view that returns the policyholder with the highest total claim amount.
create or replace view maximum_total_claim_amount as
select
	ph.name,
    sum(claim_amount) as highest_total_amount
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
join claims as c
	on c.policy_id = p.policy_id
group by ph.name
order by highest_total_amount desc
limit 1;

select * from maximum_total_claim_amount;

-- Query-12) Create a view that shows policies that have no claims filed yet.
create or replace view policies_with_no_claim as 
select
	p.policy_id
from policies as p
left join claims as c
	on p.policy_id = c.policy_id
where c.policy_id is null;

select * from policies_with_no_claim;



select * from claims;
select * from payments;
select * from policies;
select * from policyholders;

