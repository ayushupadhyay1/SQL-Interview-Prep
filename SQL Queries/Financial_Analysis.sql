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



-- ====================================================== Queries ==============================================================================


use Financial_Anlaysis;

-- Query-1) Find the total balance for each client who has more than one account. Display the client name and total balance.
select *
from 
(
select
	c.name,
    sum(a.balance) total_balance,
    count(a.client_id) as client_count
from clients as c
join accounts as a
	on c.client_id = a.client_id
group by c.name
) as clients_with_more_than_one_accounts
where client_count > 1;

-- Query-2) Using a CTE, calculate the average transaction amount per month. Then return only those accounts where the average transaction amount is greater than $700.
with average_transaction as
(
select
	date_format(transaction_Date, '%M-%Y') as Transaction_month,
    round(avg(amount),2) as total_amount
from transactions as t
group by date_format(transaction_Date, '%M-%Y')
)
select 
	Transaction_month,
    total_amount
from average_transaction
where total_amount > 700;



-- Query-3) Using a CTE, calculate the average transaction amount per account. Then return only those accounts where the average transaction amount is greater than $700.
with average_transaction as
(
select
	account_id as Accounts,
    round(avg(amount),2) as total_amount
from transactions as t
group by account_id
)
select 
	Accounts,
    total_amount
from average_transaction
where total_amount > 700;


-- Query-4) For each account type (Savings, Checking), calculate the total number of accounts, average balance, and maximum balance. Order by average balance descending.
select
account_type,
count(distinct account_id) as Number_of_Accounts,
round(avg(balance),2) as average_balance_value,
round(max(balance),2) as Maximum_balance
from accounts
group by account_type
order by average_balance_value desc;


-- Query-5) List clients who made at least one transaction with an amount greater than $1,000. Include client name, email, transaction amount, and transaction date.
select 
	c.name,
    email,
    t.amount as transaction_amount,
    t.transaction_Date as Date
from clients as c
join accounts as a
	on c.client_id = a.client_id
join transactions as t
	on t.account_id = a.account_id
where t.amount > 1000
order by transaction_amount asc;


-- Query-6) Create a view client_balances that shows client name, account ID, and current balance for all accounts. Then, select all clients whose balance is less than $2,000.
create or replace view client_balances as
(
select
	c.Name,
    a.account_id,
    a.balance
from clients as c
join accounts as a	
	on c.client_id = a.client_id
order by a.account_id asc
);
select *
from client_balances
where balance < 2000
order by balance asc;

-- Query-7)  For each account, list the account ID, transaction date, transaction amount, and the running total of transaction amount ordered by transaction date.
select 
	a.Account_id,
    t.Transaction_date,
    t.amount,
    sum(t.amount) over (partition by a.account_id order by t.transaction_date) as running_total
from accounts as a
join transactions as t
	on a.account_id = t.account_id;

-- Query-8) For each client_id, calculate the total balance for Checking and Savings accounts. Also, include a grand total for all accounts. Use GROUPING SETS to achieve this.
SELECT
    c.client_id,
    a.account_type,
    SUM(a.balance) AS total_balance
FROM clients AS c
JOIN accounts AS a ON c.client_id = a.client_id
GROUP BY ROLLUP(c.client_id, a.account_type);


-- Query-9) For each account, list the account ID, transaction date, and amount. Also, for each account, rank the transactions by transaction date (latest transaction gets rank 1). Display only the first 3 transactions per account.
select *
from
(
select
	a.account_id,
    t.transaction_date,
    t.amount,
    rank() over (partition by a.account_id order by t.transaction_date desc) as rnk
from accounts as a
join transactions as t
	on a.account_id = t.account_id
) transaction_counts
where rnk <= 3;

-- Query-10) Create a CTE that calculates the monthly average transaction amount for each account. Then, in the outer query, return all accounts where the average transaction amount for the last 3 months is greater than $500.
with monthly_trnasactions as
(
select
	account_id as account_ids,
    date_format(transaction_date,'%M-%y') as formatted_date,
    round(avg(amount),2) as average_amount
from transactions
group by account_id, date_format(transaction_date,'%M-%y')
)
select
	account_ids,
    formatted_date,
    average_amount
from monthly_trnasactions
where formatted_date >= current_date() - interval 3 month and average_amount > 500;


-- Query-10) Create a view client_transaction_summary that shows client name, account type, total number of transactions, and the total transaction amount for each account. Then, use this view to get the client name and account type where the total transaction amount is greater than $3,000.
create or replace view clients_transaction_summary as 
(
select
	c.Name,
    a.account_type,
    count(t.transaction_id) as transaction_count,
    sum(t.amount) as total_transaction_amount
from clients as c
join accounts as a	
	on c.client_id = a.client_id
join transactions as t
	on a.account_id = t.account_id
group by c.Name, a.account_type
);
select * 
from clients_transaction_summary
where total_transaction_amount > 3000;

-- Query-11) For each account, list the account ID, transaction amount, and the difference between the current transaction amount and the previous one (i.e., amount - previous_amount). Use LAG() to calculate the previous transaction's amount.

select
	t.account_id,
    t.amount as current_amount,
    lag(t.amount) over (partition by t.account_id order by t.transaction_Date) as previous_amount,
    (t.amount - lag(t.amount) over (partition by t.account_id order by t.transaction_Date)) as amount_difference
from transactions as t;

-- Query-12) For each client, find the highest transaction amount they made across all accounts. Display client name, account ID, and the highest transaction amount.
select
	c.Name,
    max(t.amount) as maximum_amount
from clients as c
join accounts as a
	on c.client_id = a.client_id
join transactions as t
	on t.account_id = a.account_id
group by c.name
order by maximum_amount desc;


-- Query-13)  Flag each transaction as: "High" if amount > $1000 "Medium" if amount between $500 and $1000 "Low" if amount < $500 Return: transaction_id, account_id, amount, transaction_flag.
select
	Transaction_id,
    account_id,
    amount,
case
	when amount > 1000 then "High" 
    when amount between 500 and 1000 then "Medium"
    when amount < 500 then "Low"
end as transaction_flag
from transactions;

-- Query-14) Find clients who have accounts but have not made any transactions. Return: client_id, name, account_id.
select 
	c.client_id,
	c.name,
    a.account_id
from clients as c
join accounts as a
	on c.client_id = a.client_id
left join transactions as t
	on t.account_id = a.account_id
where t.account_id is NULL;

-- Query-15) Accounts with no activity in the last 30 days
select
	account_id
from accounts as a
where not exists(
	select 1
    from transactions as t
    where t.account_id = a.account_id
    and t.transaction_Date >= current_date - interval 30 day
);

-- Query-16) Find out the second highest transaction amount without using limit and top
select
	max(amount) as second_highest_amount
from transactions
where amount < (select
				max(amount) as highest_salary
				from transactions as t1
                );

select * from accoutns;
select * from clients;
select * from transactions;
