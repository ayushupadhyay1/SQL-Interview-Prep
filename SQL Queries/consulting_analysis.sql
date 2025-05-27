use consulting;
-- ======================================================== BASIC QUERIES=================================================================

-- Query-1) List all clients and the industries they belong to.
select
	Client_id,
    Client_Name,
    Industry
from clients;

-- Query-2) Find all ongoing projects and the clients they are associated with.
select 
    c.client_name,
    project_name
from clients as c
join Projects as p
	on c.client_id = p.client_id
where p.status = 'Ongoing';

-- Query-3) Get the total number of projects handled by each consultant
select 	
	c.consultant_id,
    c.name,
    count(p.project_id) as Projects_Count
from Consultants as c
join Assignments as a
	on c.consultant_id = a.consultant_id
join projects as p 
	on p.project_id = a.project_id
group by c.consultant_id, c.name, c.consultant_id
order by Projects_Count desc;

-- ======================================================== AGGREGATION & JOINS =================================================================

-- Query-4) Calculate the total hours worked by consultants on each project.
select 
	c.consultant_id,
	c.name,
    p.project_name,
    sum(a.hours_worked) as total_worked_hours
from consultants as c
join Assignments as a
	on c.consultant_id = a.consultant_id
join Projects as p
	on p.project_id = a.project_id
group by c.name, p.project_name, c.consultant_id
order by total_worked_hours desc;

-- Query-5) Show the total amount billed and paid for each project.
select 
	p.project_id,
    p.project_name,
    sum(pb.amount_billed) as total_amount_billed
from projects as p
join project_billing as pb
	on p.project_id = pb.project_id
group by p.project_id, p.project_name
order by p.project_id;


-- Query-6) Find clients with more than one project.
select *
from 
(
select 
	c.client_id,
    c.client_name,
    count(p.project_id) as project_count
from clients as c
join projects as p
	on c.client_id = p.client_id
group by c.client_id, c.client_name
) as clients_with_more_than_one_projects
where project_count > 1;
    

-- ======================================================== FILTEING & DATA LOGIC =================================================================
-- Query-7) List projects that ended before May 2024.
select
	p.project_id,
	p.project_name,
    date_format(end_date, '%M-%y') as End_Date
from projects as p
where end_date < '2024-05-01';


-- Query-8) Find the average billing amount per project for completed projects.
select 
	p.project_id,
    p.project_name,
    round(avg(pb.amount_billed),2) as average_billing_amount
from Projects as p
join Project_Billing as pb
	on p.project_id = pb.project_id
where p.status = 'completed'
group by p.project_id, p.project_name
order by p.project_id;


-- Query-9) Identify consultants who have worked on more than one project.
select 
	c.consultant_id,
    c.name,
    count(a.project_id) as project_count
from consultants as c
join assignments as a
	on c.consultant_id = a.consultant_id
group by c.consultant_id, c.name
having count(a.project_id) > 1;

-- ======================================================== ADVANCED SQL =================================================================

-- Query-10) Find the top 2 consultants who worked the most hours across all projects.
select 
	c.consultant_id,
    c.name,
    sum(a.hours_worked) as total_working_hours
from Consultants as c
join Assignments as a
	on c.consultant_id = a.consultant_id
group by c.consultant_id, c.name
order by total_working_hours desc
limit 2;

-- Query-11) Show projects where billed amount is more than paid amount.
select 
	p.project_id,
    p.project_name,
    sum(pb.amount_billed) as total_billed_amount,
    sum(pb.amount_paid) as total_paid_amount
from projects as p
join project_billing as pb
	on p.project_id = pb.project_id
group by p.project_id, p.project_name
having sum(pb.amount_billed) > sum(pb.amount_paid);

-- Query-12) For each client, find the latest project they are working on.
select *
from 
(
select 
    c.client_id,
    p.project_id,
    p.project_name,
    p.start_Date,
    p.end_Date,
    rank() over (partition by c.client_id order by p.start_date desc) as RNK
from clients as c
join projects as p
	on c.client_id = p.client_id
) as clients
where RNK = 1;

-- ======================================================== ANALYTICAL USE-CASES =================================================================

-- Query-13) Calculate the payment ratio (amount_paid / amount_billed) for each project.
select 
	p.project_id,
    p.project_name,
    round(sum(pb.amount_paid) / NULLIF(sum(pb.amount_billed),0),2) as payment_ratio
from projects as p
join project_billing as pb
	on p.project_id = pb.project_id
group by p.project_id, p.project_name;

-- Query-14) Determine the average number of hours worked by role (e.g., Analyst, Manager).
select 
	c.role,
    round(avg(a.hours_worked),2) as average_working_hours
from Consultants as c
join Assignments as a
	on c.consultant_id = a.consultant_id
group by c.role
order by average_working_hours desc;


-- Query-14) List the clients for whom the payment ratio is below 0.8.
select *
from
(
select 
	c.client_id,
    c.client_name,
    round(sum(pb.amount_paid) / NULLIF(sum(pb.amount_billed),0),2) as payment_ratio
from Clients as c
join projects as p
	on c.client_id = p.client_id
join project_billing as pb
	on pb.project_id = p.project_id
group by c.client_id
) as clients_with_less_than_8_ratio
where payment_ratio < 0.8;




