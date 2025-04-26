-- =========================================================== Table Creation ================================================================
Create database Financial_Anlaysis;

use Financial_Anlaysis;

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    join_date DATE
);

INSERT INTO clients (client_id, name, email, join_date) VALUES
(1, 'Alice Johnson', 'alice.j@email.com', '2020-01-10'),
(2, 'Bob Smith', 'bob.s@email.com', '2019-11-23'),
(3, 'Catherine Lee', 'catherine.l@email.com', '2021-03-15'),
(4, 'David Patel', 'david.p@email.com', '2018-06-30'),
(5, 'Emily Zhang', 'emily.z@email.com', '2022-01-05'),
(6, 'Frank Brown', 'frank.b@email.com', '2017-08-12'),
(7, 'Grace Kim', 'grace.k@email.com', '2020-12-01'),
(8, 'Harry White', 'harry.w@email.com', '2019-09-10'),
(9, 'Ivy Green', 'ivy.g@email.com', '2023-02-25'),
(10, 'Jack Black', 'jack.b@email.com', '2021-07-07');


CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    client_id INT,
    account_type VARCHAR(20),
    balance DECIMAL(12, 2),
    created_at DATE,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

INSERT INTO accounts (account_id, client_id, account_type, balance, created_at) VALUES
(101, 1, 'Savings', 5000.00, '2020-01-12'),
(102, 2, 'Checking', 2500.50, '2019-11-25'),
(103, 3, 'Savings', 10500.75, '2021-03-17'),
(104, 4, 'Checking', 4000.00, '2018-07-01'),
(105, 5, 'Savings', 3000.00, '2022-01-07'),
(106, 6, 'Savings', 800.00, '2017-08-15'),
(107, 7, 'Checking', 12500.90, '2020-12-02'),
(108, 8, 'Savings', 9500.00, '2019-09-12'),
(109, 9, 'Checking', 100.00, '2023-02-26'),
(110, 10, 'Savings', 6700.00, '2021-07-09'),
(111, 1, 'Checking', 2000.00, '2020-03-01'),
(112, 2, 'Savings', 4000.00, '2020-02-01');


CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(10), -- 'credit' or 'debit'
    amount DECIMAL(10, 2),
    transaction_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, transaction_date) VALUES
(1001, 101, 'credit', 1000.00, '2020-02-01'),
(1002, 102, 'debit', 300.00, '2020-03-05'),
(1003, 103, 'credit', 2000.00, '2021-04-01'),
(1004, 104, 'debit', 1500.00, '2018-08-10'),
(1005, 105, 'credit', 500.00, '2022-02-15'),
(1006, 106, 'debit', 200.00, '2017-09-10'),
(1007, 107, 'credit', 3500.00, '2020-12-10'),
(1008, 108, 'debit', 800.00, '2020-01-10'),
(1009, 109, 'credit', 100.00, '2023-03-01'),
(1010, 110, 'credit', 600.00, '2021-07-15'),
(1011, 111, 'debit', 300.00, '2020-03-15'),
(1012, 112, 'credit', 700.00, '2020-02-15');

use Financial_Anlaysis;

-- ===================================================== Joins & Aggregations ================================================================

-- Query-1) Find all clients who have both a savings and a checking account.
select 
	c.Client_id,
    c.Name,
    count(a.account_type) as account_count
from clients as c
join accounts as a
	on c.client_id = a.client_id
group by c.client_id, c.name
having count(a.account_type) = 2;

-- Query-2) List clients who do not have any transactions recorded.
select
	c.client_id,
	c.Name
from clients as c
left join accounts as a
	on a.client_id = c.client_id
left join transactions as t
	on t.account_id = a.account_id
group by c.client_id, c.Name
having count(t.transaction_id) = 0;

-- Query-3) Identify clients who have only one account and have made more than one transaction on it.
select *
from
(
select
	c.client_id,
	c.name,
    count(distinct a.account_id) as account_count,
    count(t.transaction_id) as transaction_count
from clients as c
join accounts as a
	on c.client_id = a.client_id
join transactions as t
	on t.account_id = a.account_id
group by c.client_id, c.name
) as clients_transaction_count
where account_count = 1 and transaction_count > 1;

-- Query-4) Find the top 3 clients with the highest average transaction amount.
select
	c.client_id,
    c.Name,
    round(avg(t.amount),2) as average_transaction_amount
from clients as c
join accounts as a
	on c.client_id = a.client_id
join transactions as t
	on t.account_id = a.account_id
group by c.client_id, c.name
order by average_transaction_amount desc
limit 3;
    
-- ===================================================== Window Functions ================================================================
-- Query-1) For each client, show their account with the highest balance using window functions.
select *
from
(
select
	c.client_id,
    c.name,
    a.account_id,
    a.balance,
    rank() over (partition by a.client_id order by a.balance desc) as rnk
from clients as c
join accounts as a
	on c.client_id = a.client_id
) as account_with_highest_balance
where rnk = 1;

-- Query-2) Calculate the running total of credits per account, ordered by transaction date.
select
	a.client_id,
	a.account_id,
    a.account_type,
    a.balance,
    sum(t.amount) over (partition by a.account_id order by t.transaction_date) as runing_total
from accounts as a
join transactions as t
	on a.account_id = t.account_id
where t.transaction_type = 'Credit';

-- Query-3) For each account, find the transaction with the highest amount and rank the remaining ones.
select
	a.account_id,
    t.amount,
    rank() over (partition by a.account_id order by t.amount desc) as rnk
from accounts as a
join transactions as t
	on a.account_id = t.account_id;

-- Query-4) Get the latest transaction amount for each account and compare it to the previous one.
select
	a.account_id,
    t.transaction_date,
    t.amount,
    lag(t.amount) over (partition by a.account_id order by t.transaction_date desc) as previous_amount
from accounts as a
join transactions as t
	on a.account_id = t.account_id
order by a.account_id, t.transaction_date desc;

-- Query-5) Calculate the average debit amount per client and compare each debit transaction to that average.
select
	c.client_id,
	c.name,
    t.transaction_type,
    round(avg(t.amount) over (partition by c.client_id),2) as average_debitted_amount,
    t.amount as debitted_amount,
    lag(t.amount) over (partition by c.client_id order by t.transaction_Date) as previous_debitted_amount
from clients as c
join accounts as a
	on c.client_id = a.client_id
join transactions as t
	on t.account_id = a.account_id
where t.transaction_type = 'Debit';

-- ===================================================== CTEs & Subqueries ================================================================
-- Query-1) Using a CTE, find all clients whose total transaction amount (credit + debit) exceeds $5,000.
with total_transaction_amount_credit_and_Debit as 
(
select
	c.client_id as Client_id_number,
    c.name as client_name,
	sum(amount) as total_transaction_amount
from clients as c
join accounts as a
	on c.client_id = a.client_id
join transactions as t
	on t.account_id = a.account_id
group by c.client_id, c.name
)
select
	Client_id_number,
    client_name,
    total_transaction_amount
from total_transaction_amount_credit_and_Debit
where total_transaction_amount > 5000;

-- Query-2) With a CTE, identify accounts that had no transactions for more than 6 months between any two transactions.
with no_transactions as
(
select
	t.account_id as Acc_id,
    t.transaction_date as trans_date,
    lag(t.transaction_Date) over (partition by t.account_id order by t.transaction_date) as previous_transaction_Date
from transactions as t

) 
select
	Acc_id,
	previous_transaction_Date
from no_transactions
where previous_transaction_Date is not null and 
trans_date > previous_transaction_Date + interval 6 month;

-- Query-3) Using a CTE, determine which clients have more than one account and have a combined balance of over $10,000.
with account_counts as 
(
select
	c.client_id as client_ids,
    c.name as client_name,
    count(a.account_id) as account_count,
    sum(a.balance) as total_balance
from clients as c
join accounts as a
	on c.client_id = a.client_id
group by c.client_id, c.name
)
select
	client_ids,
    client_name,
    account_count,
    total_balance
from account_counts
where account_count > 1
and total_balance > 10000;

-- Query-4) Use a CTE to list clients who opened their first account more than a year after joining.
select * from accounts;
select * from clients;
select * from transactions;

-- Query-5) Find accounts that have had more than 2 consecutive credits without a debit in between.


-- ===================================================== Views ================================================================

-- Query-1) Create a view that shows client name, account type, account balance, and total number of transactions.
create or replace view client_account_info as 
(
select 
	c.Name,
    a.account_type,
    a.balance,
    count(t.transaction_id) as transaction_count
from clients as c
join accounts as a
	on c.client_id = a.client_id
left join transactions as t
	on a.account_id  = t.account_id
group by c.Name, a.account_type, a.balance
);
select *
from client_account_info;

-- Query-2) Create a view to show only active clients (those with transactions in the last 12 months).
create or replace view active_user as 
(
select 
	c.Name,
    t.transaction_date
from clients as c
join accounts as a
	on c.client_id = a.client_id
join transactions as t
	on a.account_id = t.account_id
where transaction_Date >= current_Date() - interval 12 month
);
select *
from active_user;

-- Query-3) Make a view that lists clients and flags them as “High Value” if any of their account balances exceed $10,000.
create or replace view amount_category as 
(
select
account_id,
account_type,
balance,
case
	when balance > 10000 then 'High Value'
    else 'Normal Value'
end as amount_category
from accounts
);
select *
from amount_category;

-- Query-4) Define a view that shows average monthly credit and debit amounts per client.
create or replace view avg_amount_per_client as
(
select
	month(t.transaction_date) as _month,
    year(t.transaction_date) as _year,
	a.client_id,
	round(avg(case when t.transaction_type = 'credit' then (t.amount) end),2) as average_credit_amount,
	round(avg(case when t.transaction_type = 'debit' then (t.amount) end),2) as average_debitted_amount
from accounts as a
join transactions as t
	on a.account_id = t.account_id
group by a.client_id, month(t.transaction_date), year(t.transaction_date)
);
select *
from avg_amount_per_client;
