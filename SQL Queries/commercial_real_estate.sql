-- ======================================================== DATABASE =================================================================

create database Commercial_Real_Estate;

use Commercial_Real_Estate;

-- 1. Properties Table
CREATE TABLE Properties (
    property_id INT PRIMARY KEY,
    property_name VARCHAR(100),
    property_type VARCHAR(50), -- e.g., Office, Retail, Industrial
    city VARCHAR(50),
    state VARCHAR(50),
    acquisition_date DATE,
    purchase_price DECIMAL(15,2)
);

INSERT INTO Properties VALUES
(1, 'Downtown Plaza', 'Retail', 'Chicago', 'IL', '2018-03-12', 12000000),
(2, 'Tech Tower', 'Office', 'Austin', 'TX', '2020-06-25', 18500000),
(3, 'LogiPark Center', 'Industrial', 'Phoenix', 'AZ', '2019-10-14', 9000000),
(4, 'Market Square', 'Retail', 'San Diego', 'CA', '2021-01-11', 15000000),
(5, 'Innovation Hub', 'Office', 'Seattle', 'WA', '2022-09-01', 21000000);

-- 2. Leases Table
CREATE TABLE Leases (
    lease_id INT PRIMARY KEY,
    property_id INT,
    tenant_name VARCHAR(100),
    lease_start DATE,
    lease_end DATE,
    monthly_rent DECIMAL(10,2),
    FOREIGN KEY (property_id) REFERENCES Properties(property_id)
);

INSERT INTO Leases VALUES
(101, 1, 'Urban Outfitters', '2021-01-01', '2026-12-31', 25000),
(102, 2, 'TechCorp Inc.', '2020-07-01', '2025-06-30', 40000),
(103, 3, 'FastLogistics', '2020-01-01', '2024-12-31', 15000),
(104, 1, 'H&M', '2022-02-01', '2027-01-31', 28000),
(105, 5, 'StartupWorks', '2022-10-01', '2027-09-30', 35000);

-- 3. MaintenanceRequests Table
CREATE TABLE MaintenanceRequests (
    request_id INT PRIMARY KEY,
    property_id INT,
    request_date DATE,
    issue_description TEXT,
    status VARCHAR(20), -- e.g., Open, Closed, In Progress
    cost DECIMAL(10,2),
    FOREIGN KEY (property_id) REFERENCES Properties(property_id)
);

INSERT INTO MaintenanceRequests VALUES
(1001, 1, '2023-03-15', 'HVAC malfunction', 'Closed', 4500),
(1002, 3, '2023-04-10', 'Loading dock repair', 'Open', 1200),
(1003, 4, '2023-05-20', 'Roof leakage', 'In Progress', 5200),
(1004, 2, '2023-06-01', 'Elevator malfunction', 'Closed', 3000),
(1005, 5, '2023-06-18', 'Internet connectivity issue', 'Closed', 800);

-- 4. PropertyManagers Table
CREATE TABLE PropertyManagers (
    manager_id INT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    property_id INT,
    FOREIGN KEY (property_id) REFERENCES Properties(property_id)
);

INSERT INTO PropertyManagers VALUES
(1, 'Alice Robinson', '555-1234', 'alice@mgmtco.com', 1),
(2, 'Ben Torres', '555-5678', 'ben@mgmtco.com', 2),
(3, 'Clara Yoon', '555-9101', 'clara@mgmtco.com', 3),
(4, 'David Singh', '555-1213', 'david@mgmtco.com', 4),
(5, 'Eva Morales', '555-1415', 'eva@mgmtco.com', 5);

-- ================================================================ EASY =====================================================================

-- Query-1) List all properties in Texas (state = 'TX').
select *
from properties 
where state = 'TX';


-- Query-2) Find all leases that are currently active as of today.
select 
	*
from leases
where lease_start <= current_date() and lease_end >= current_date();

-- Query-3) Count how many properties are of type 'Office'.
select
	count(p.property_id) as property_count
from Properties as p
where p.property_type = 'Office';

-- Query-4) Retrieve names of tenants paying more than $30,000 in monthly rent.
select
	l.tenant_name,
    l.monthly_rent
from leases as l
where l.monthly_rent > 30000;

-- Query-5) Show property names with at least one maintenance request.
select 
	p.property_id,
    p.property_name,
    count(mr.request_id) as request_count
from Properties as p
join MaintenanceRequests as mr 	
	on p.property_id = mr.property_id
group by p.property_id, p.property_name
having count(mr.request_id) >= 1;

-- ================================================================ MEDIUM =====================================================================

-- Query-6) For each property, calculate the total monthly rent collected from its tenants.
select 
	p.property_id,
    p.property_name,
    sum(l.monthly_rent) as total_collected_rent
from properties as p
join Leases as l
	on p.property_id = l.property_id
group by p.property_id, p.property_name
order by total_collected_rent desc;

-- Query-7) Get the average maintenance cost per property.
select 
	p.property_type,
    round(avg(mr.cost),2) as average_maintenance_cost
from properties as p
join MaintenanceRequests as mr
	on p.property_id = mr.property_id
group by p.property_type
order by average_maintenance_cost desc;

-- Query-8) List the property manager names along with the property name and city they manage.
select 
	p.property_id,
    p.property_name,
    p.property_type,
    p.city,
    pm.name  as Property_Manager_name
from properties as p
join PropertyManagers as pm
	on p.property_id = pm.property_id;
    

-- Query-9) Find properties that had more than one maintenance request in 2023.
select *
from
(
select 
	p.property_id,
    p.property_name,
    count(mr.request_id) as request_count,
    year(request_date) as Maintenance_Request_Year
from properties as p
join MaintenanceRequests as mr
	on p.property_id = mr.property_id
group by p.property_id, p.property_name, year(request_date)
) as properties_with_more_than_one_requests
where Maintenance_Request_Year = '2023' and request_count > 1;

-- Query-10) Identify tenants with lease duration greater than 4 years.
select *
from
(
select
	tenant_name,
    lease_start,
    lease_end,
    round(datediff(lease_end, lease_start) / 365,0) as Duration
from leases
) properties_with_more_than_4_years_tenure
where Duration > 4;

-- ================================================================ HARD =====================================================================

-- Query-11) Return the top 2 properties with the highest number of tenants.
select 
	p.property_id,
    p.property_name,
    count(tenant_name) as tenant_count
from properties as p
join leases as l
	on p.property_id = l.property_id
group by p.property_id, p.property_name
order by tenant_count desc
limit 2;


-- Query-12) For each property, show the lease with the highest rent.
select 
	property_id,
    property_name,
    lease_id,
    lease_start,
    lease_end,
    monthly_rent
from
(
select 
	p.property_id,
    p.property_name,
    l.lease_id,
    l.lease_start,
    l.lease_end,
    l.monthly_rent,
    rank() over (partition by p.property_id order by l.monthly_rent desc) as RNK
from properties as p
join leases as l
	on p.property_id = l.property_id
) as highest_proiperty_rant 
where RNK = 1;

-- Query-13) Find tenants whose leases will expire within the next 12 months.
select
	*
from leases 
where lease_end between current_date() and current_date() + interval 12 month;

-- Query-14) For each property type, calculate the average purchase price and total number of properties.
select 
	p.property_type,
    round(avg(p.purchase_price),2) as average_property_purchase_price,
    count(p.property_id) as property_count
from properties as p
group by p.property_type
order by average_property_purchase_price desc;

-- Query-15) Show properties with no maintenance requests in the last 12 months.
select 
	p.property_id,
    p.property_name
from properties as p
left join MaintenanceRequests as mr
	on p.property_id = mr.property_id
    and mr.request_date >= current_date() - interval 12 month
where mr.request_date is NULL;
 
 -- ================================================================ ADVANCED =====================================================================
-- Query-16) CTE: Use a CTE to rank leases by monthly rent within each property.
with monthly_rent_property as
(
select
	p.property_id,
    p.property_name,
    l.monthly_rent
from leases as l
join properties as p
	on l.property_id = p.property_id
)
select
	property_id,
    property_name,
    monthly_rent,
    rank() over (partition by property_id order by monthly_rent desc) as RNK
from monthly_rent_property;


-- Query-17) Window Function: For each lease, show total rent over the entire lease and its rank among all leases.
select
	l.lease_id,
	l.property_id,
    l.tenant_name,
    l.lease_start,
    l.lease_end,
    l.monthly_rent,
    round(datediff(l.lease_end, l.lease_start) / 30,0) as total_months,
    ROUND(l.monthly_rent * (DATEDIFF(l.lease_end, l.lease_start) / 30), 2) AS total_rent,
	RANK() OVER (ORDER BY (l.monthly_rent * (DATEDIFF(l.lease_end, l.lease_start) / 30)) DESC) AS RNK
from leases as l
group by l.lease_id;

-- Query-18) Subquery: Find properties where the average maintenance cost is above the average for all properties.
select 
	p.property_id,
    p.property_name,
    mr.cost
from properties as p
join MaintenanceRequests as mr
	on p.property_id = mr.property_id
where mr.cost > 
(
select
	avg(cost)
from MaintenanceRequests
)
order by mr.cost desc;


-- Query-19) View: Create a view that shows current lease status (Active/Expired) for each tenant.
create or replace view lease_status as 
(
select
	l.lease_id,
    l.property_id,
    l.tenant_name,
	case
		when l.lease_end < current_date then 'Lease Expired'
        else 'Active'
    end as lease_status
from leases as l
);

select * from lease_status;

-- Query-20) JOIN + CTE: List managers managing properties where total rent collected exceeds $50,000 monthly, using a CTE to pre-calculate totals.
with managers_managing_properties_over_50K as
(
select
	pm.manager_id,
    pm.name,
    p.property_id,
    p.property_name,
    p.property_type,
    sum(l.monthly_rent) as collected_monthly_rent
from PropertyManagers as pm
join properties as p
	on pm.property_id = p.property_id
join leases as l
	on l.property_id = p.property_id
group by pm.manager_id, pm.name, p.property_id, p.property_name, p.property_type
)
select
	manager_id,
    name,
    property_id,
    property_name,
    property_type,
    collected_monthly_rent
from managers_managing_properties_over_50K
where collected_monthly_rent > 50000;

-- Query-21) CASE Statement: Categorize maintenance requests into "Low" (<$1,000), "Medium" (<$4,000), "High" (>= $4,000) cost buckets.
select
	mr.request_id,
    mr.property_id,
    mr.request_date,
    mr.issue_description,
    mr.status,
    mr.cost,
    case
		when mr.cost < 1000 then 'Low'
        when mr.cost < 4000 then 'Medium'
        when mr.cost >= 4000 then 'High'
    end as Maintenance_Cost_Bucket
from MaintenanceRequests as mr;


