create database insurance_analysis;

use insurance_analysis;
-- ======================================================== DATABASE CREATION ===================================================================
CREATE TABLE PolicyHolders (
    policyholder_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    gender CHAR(1),
    state VARCHAR(50)
);

INSERT INTO PolicyHolders VALUES
(1, 'John Smith', '1980-01-01', 'M', 'Illinois'),
(2, 'Jane Doe', '1990-03-15', 'F', 'Texas'),
(3, 'Alice Green', '1985-07-20', 'F', 'California'),
(4, 'Bob Martin', '1975-11-02', 'M', 'Texas'),
(5, 'Carol White', '1992-06-10', 'F', 'Florida'),
(6, 'Tom Hanks', '1983-08-08', 'M', 'Illinois'),
(7, 'Sam Wilson', '1979-12-30', 'M', 'New York'),
(8, 'Kate Bell', '1995-09-12', 'F', 'California'),
(9, 'Mike Tyson', '1970-02-28', 'M', 'Florida'),
(10, 'Emma Stone', '1987-04-22', 'F', 'New York');

CREATE TABLE Policies (
    policy_id INT PRIMARY KEY,
    policyholder_id INT,
    policy_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    premium_amount DECIMAL(10,2),
    FOREIGN KEY (policyholder_id) REFERENCES PolicyHolders(policyholder_id)
);

INSERT INTO Policies VALUES
(101, 1, 'Life',    '2021-01-01', '2026-01-01', 500),
(102, 2, 'Health',  '2020-06-15', '2025-06-15', 300),
(103, 3, 'Auto',    '2022-01-10', '2023-01-10', 200),
(104, 4, 'Life',    '2019-03-05', '2024-03-05', 450),
(105, 5, 'Health',  '2023-02-20', '2026-02-20', 350),
(106, 6, 'Auto',    '2021-10-01', '2022-10-01', 180),
(107, 7, 'Life',    '2022-08-20', '2027-08-20', 520),
(108, 8, 'Health',  '2020-12-01', '2025-12-01', 310),
(109, 9, 'Auto',    '2021-05-05', '2022-05-05', 220),
(110,10, 'Life',    '2023-07-01', '2028-07-01', 490);

CREATE TABLE Claims (
    claim_id INT PRIMARY KEY,
    policy_id INT,
    claim_date DATE,
    claim_amount DECIMAL(10,2),
    claim_status VARCHAR(20),
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);

INSERT INTO Claims VALUES
(1001, 101, '2022-05-01', 1000, 'Approved'),
(1002, 102, '2021-11-10', 2000, 'Rejected'),
(1003, 103, '2022-07-15', 1500, 'Approved'),
(1004, 104, '2020-03-25', 2500, 'Pending'),
(1005, 105, '2023-06-18', 3000, 'Approved'),
(1006, 106, '2021-12-09', 1200, 'Rejected'),
(1007, 107, '2023-04-14', 1600, 'Approved'),
(1008, 108, '2022-02-10', 1800, 'Pending'),
(1009, 109, '2021-08-22', 2200, 'Approved'),
(1010, 110, '2024-01-30', 2700, 'Approved');

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    policy_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);

INSERT INTO Payments VALUES
(201, 101, '2021-01-01', 500),
(202, 101, '2022-01-01', 500),
(203, 101, '2023-01-01', 500),
(204, 102, '2020-06-15', 300),
(205, 102, '2021-06-15', 300),
(206, 102, '2022-06-15', 300),
(207, 103, '2022-01-10', 200),
(208, 105, '2023-02-20', 350),
(209, 106, '2021-10-01', 180),
(210, 107, '2022-08-20', 520),
(211, 107, '2023-08-20', 520);



-- ========================================================= PART-1 (EASY) ==================================================================

-- Query-1) List all policyholders with their corresponding policy type and premium amount.
select 
	ph.Name,
    p.policy_type,
    p.premium_amount
from policies as p
join policyholders as ph
	on p.policyholder_id = ph.policyholder_id;

-- Query-2) Find the total number of policies per policy type.
select
	policy_type,
    count(policy_id) as Number_of_policies
from policies 
group by policy_type
order by Number_of_policies desc;

-- Query-3) Show the number of claims per claim status.
select
	claim_status,
    count(claim_id) as Number_of_claims
from claims
group by claim_status;

-- Query-4) Get the list of policyholders who made a payment in 2023.
select 
	distinct ph.name,
    date_format(pay.payment_date, '%Y') as Payment_year
from policyholders as ph
join policies as p
	on ph.policyholder_id = ph.policyholder_id
join payments as pay
	on p.policy_id = pay.policy_id
where date_format(pay.payment_date, '%Y') = 2023;

-- ========================================================= PART-2 (Medium) ==================================================================

-- Query-1) Using a CTE, calculate the total premium amount paid per policyholder.
with premium_amount_count as 
(
select 
	ph.policyholder_id as Policyholder_id,
    ph.name as policyholder_name,
   sum(p.premium_amount) as total_premium_amount
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
group by ph.policyholder_id, ph.name
)
select
	Policyholder_id,
    policyholder_name,
    total_preminum_amount
from premium_amount_count;

-- Query-2) List policyholders who have more than one payment associated with their policy.
select 
    ph.name,
    p.policy_id,
    count(pay.payment_id) as num_payments
from policyholders as ph
join policies as p
	on p.policyholder_id = p.policyholder_id
join payments as pay
	on pay.policy_id = p.policy_id
group by ph.name, p.policy_id
having count(pay.payment_id) > 1;

-- Query-3) Display policyholders who have never made a claim.
select
	ph.name,
	ph.policyholder_id,
    p.policy_id
from policies as p
left join claims as c
	on p.policy_id = c.policy_id
join policyholders as ph
	on ph.policyholder_id = p.policyholder_id
where c.policy_id is NULL;


-- Query-4) Retrieve the average claim amount per policy type.
select 
	p.policy_type,
    round(avg(c.claim_amount),2) as average_claim_amount
from claims as c
join policies as p
	on c.policy_id = p.policy_id
group by p.policy_type;

-- Query-5) Find the top 3 most expensive claims that were approved.
select
	claim_amount,
    claim_status
from claims 
where claim_status = 'Approved'
order by claim_amount desc
limit 3;

-- Query-6) Write a query to return the latest payment made for each policy using a window function.
select *
from
(
select 
	p.policy_id,
    p.policy_type,
    pay.payment_date,
    dense_rank() over (partition by policy_id order by payment_Date desc) as Latest_payment_Date
from payments as pay
join policies as p
	on pay.policy_id = p.policy_id
) as latest_Date
where Latest_payment_Date = 1;

-- Query-7) Calculate the running total of payments per policy ordered by date.
select 
	p.policy_id,
    p.policy_type,
    pay.amount,
    sum(pay.amount) over (partition by p.policy_id order by pay.payment_date ASC) as running_total
from payments as pay
join policies as p
	on pay.policy_id = p.policy_id;

-- Query-8) For each policyholder, show the first and last payment date using window functions.
select 
	ph.policyholder_id,
	ph.name,
	pay.payment_Date,
first_value(pay.payment_Date) over (
			partition by ph.policyholder_id 
            order by pay.payment_Date
            rows between unbounded preceding and unbounded following) as first_Date,
last_value(pay.payment_Date) over (
			partition by ph.policyholder_id 
            order by pay.payment_Date
            rows between unbounded preceding and unbounded following) as last_Date
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
join payments as pay
	on pay.policy_id = p.policy_id;

-- Query-9) Create a query to show the number of claims made in each year.
select
    date_format(claim_Date, '%Y') as claim_year,
    count(claim_id) as claim_count
from claims
group by date_format(claim_Date, '%Y')
order by claim_count desc;

-- Query-10) Show all policies that have claims associated with them, even if there are multiple claims per policy (use JOIN).
select
	p.policy_id,
    p.policy_type
from claims as c
join policies as p
	on c.policy_id = p.policy_id;

-- Query-11) Use a CTE to filter policies with total payments greater than 1000.
with large_payments as 
(
select
	p.policy_id as Policy_ID,
    p.policy_type Policy_Type,
    sum(pay.amount) as total_payment
from policies as p
join payments as pay
	on p.policy_id = pay.policy_id
group by p.policy_id, p.policy_type
)
select
	Policy_ID,
    Policy_Type,
    total_payment
from large_payments
where total_payment > 1000;

-- Query-12) Find policies that had both approved and rejected claims (hint: use GROUP BY and HAVING).
select
	p.policy_id,
    p.policy_type,
    count(distinct c.claim_status) as status_count
from policies as p
join claims as c
	on p.policy_id = c.policy_id
group by p.policy_id, p.policy_type
having count(distinct c.claim_status) >= 2;

-- ========================================================= PART-3 (Hard) ==================================================================

-- Query-1) Use a window function to rank policyholders based on total claim amount in descending order.
with total_claim as 
(
select 
	ph.name as Policyholder_Name,
    sum(c.claim_amount) as Total_Claim_Amount
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
join claims as c
	on p.policy_id = c.policy_id
group by ph.name
)
select
	Policyholder_Name,
    Total_Claim_Amount,
    dense_rank() over (order by Total_Claim_Amount desc) as RNK
from total_claim;

-- Query-2) For each policyholder, calculate the percentage of approved claims over total claims.
select
	ph.name,
    count(c.claim_id),
    sum(case when c.claim_status = 'Approved' then 1 else 0 end) as approved_claims,
    round(100 * sum(case when c.claim_status = 'Approved' then 1 else 0 end) / count(c.claim_id),2) as Percentage
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
join claims as c
	on c.policy_id = p.policy_id
group by ph.name;

-- Query-3) Using advanced aggregation and CTEs, find the average premium amount paid by state, but only include states with more than 2 policyholders.
with policyholder_headcount as 
(
select 
	ph.state as states,
    round(avg(premium_amount),2) as avg_premium_amount,
    count(distinct ph.policyholder_id) as policyholder_count
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
group by ph.state
)
select
	states,
    avg_premium_amount
from policyholder_headcount
where policyholder_count > 2;

-- Query-4) Get the top 2 claim amounts per state where claim status is approved, using DENSE_RANK.
select *
from
(
select 
	ph.state,
	c.claim_amount,
    dense_rank() over (partition by ph.state order by c.claim_amount desc) as RNK
from policyholders as ph
join policies as p
	on ph.policyholder_id = p.policyholder_id
join claims as c
	on c.policy_id = p.policy_id
where c.claim_status = 'Approved'
order by ph.state asc
) as highest_claims
where RNK <= 2;

