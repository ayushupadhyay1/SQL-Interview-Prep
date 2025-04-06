-- ----------------------------------------------------- PART-1 (EASY) -------------------------------------------------------------------------
use finance;
-- Quert-1) Basic Join: Retrieve a list of all customers along with their respective account types and balances. 
-- Ensure to include customers who do not have an account.
select
	c.CustomerName,
    a.AccountType,
    a.Balance
from customers as c
left join accounts as a
	on c.CustomerID = a.CustomerID;


-- Quert-2) Filtering with Joins: List all transactions where the account holder is from the USA.
select
	c.CustomerName,
    c.Country,
    sum(t.amount) as Total_Amount
from transactions as t
join accounts as a
	on t.AccountID = a.AccountID
join customers as c
	on c.CustomerID = a.CustomerID
where c.Country = 'USA'
group by c.CustomerName, c.Country;


-- Query-3) Aggregation with GROUP BY: Find the total loan amount taken by each country.
select 
	c.Country,
    sum(l.LoanAmount) as total_loan_amount
from customers as c
join loans as l
	on c.CustomerID = l.CustomerID
group by c.Country;

-- Query-4) Simple Window Function: For each transaction, display the transaction amount and the running total of transactions for the same account.
select
	t.TransactionID,
    t.AccountID,
    t.amount,
    sum(t.amount) over (partition by t.accountId order by t.transactionDate) as running_total
from transactions as t;


-- Query-5) Using COALESCE with Joins: Show all customers along with their loan amounts. If a customer does not have a loan, display "No Loan" instead.
select
	c.CustomerName,
    coalesce(l.LoanAmount, 'No Loan')
from customers as c
left join loans as l
	on c.CustomerID = l.CustomerID;

-- Query-6) Ordering in Window Functions: Rank customers based on their account balance in descending order. If two customers have the same balance, assign them the same rank.
select
	c.CustomerName,
	a.balance,
	rank()over(order by a.balance DESC) as Rank_Balance
from customers as c
join accounts as a
	on c.CustomerID = a.CustomerID;


-- Query-7) Date-based Filtering: Retrieve all accounts that were opened in February 2025.
select
	AccountID,
    OpenedDate
from accounts
where date_format(OpenedDate, '%M-%Y') = 'February-2025';

-- ----------------------------------------------------- PART-2 (MEDIUM) -------------------------------------------------------------------------
-- Query-1) Self Join: Find pairs of customers from the same country. Display each pair only once (i.e., avoid duplicates like (A, B) and (B, A)).
select
	c1.CustomerName as Customer1,
    c2.CustomerName as Customer2,
    c1.Country
from customers as c1
join customers as c2
	on c1.Country = c2.Country
    and c1.CustomerID < c2.CustomerID;

-- Query-2) Window Function - ROW_NUMBER: For each customer, show the most recent transaction they made using ROW_NUMBER().
select 
	C.CustomerName,
    t.TransactionDate,
    t.amount,
    row_number() over (partition by c.CustomerID order by t.TransactionDate DESC) as Order_by_date
from customers as c
join accounts as a
	on c.CustomerID = a.CustomerID
join transactions as t
	on t.AccountID = a.AccountID;

-- Query-3) Common Table Expressions (CTE): Use a CTE to display customers who have an account balance higher than the average balance across all accounts.
with Avgbalance as
(
	select
		avg(balance) as avg_bank_balance
    from accounts
)
select
	a.CustomerId,
    a.Balance
from accounts as a
join Avgbalance as ab
on a.balance > ab.avg_bank_balance;

-- Query-4) Advanced Join with Multiple Tables: Retrieve a list of all transactions along with the customer name, account type, and loan amount (if they have a loan).
select 
	c.CustomerName,
    a.AccountType,
    l.LoanAmount,
    t.Amount
from customers as c
join accounts as a
	on c.CustomerID = a.CustomerID
left join loans as l
	on l.CustomerId = c.CustomerID
join transactions as t
	on t.AccountId = a.AccountID;


-- Query-5) Window Function - LEAD/LAG: For each transaction, show the previous transaction amount for the same account using the LAG() function.
select
	t.accountID,
    t.Amount,
    lag(t.amount) over (partition by t.AccountId order by t.transactionID)
from transactions as t;



-- Query-6) Date Intervals: Find all loans that will mature (end date) within the next 1 year from March 2025.
select
	CustomerID,
    LoanID,
    LoanAmount,
    InterestRate,
    EndDate
from loans
where EndDate <= current_date() + interval 1 year;

-- ----------------------------------------------------- PART-3 (HARD) -------------------------------------------------------------------------
-- Query-1) Complex Aggregation with HAVING: Find customers who have deposited more than $10,000 in total across multiple transactions but have also made at least one withdrawal of more than $5,000.

select 
	c.CustomerName,
		sum(case when t.TransactionType = 'Deposit' then t.Amount end) as total_deposted_amount,
        sum(case when t.TransactionType = 'Withdrawal' then t.Amount end) as total_withdawn_amount
from customers as c
join accounts as a
	on c.CustomerID = a.CustomerID
join transactions as t
	on t.AccountId = a.AccountID
group by c.CustomerName
having sum(case when t.TransactionType = 'Deposit' then t.Amount end) > 10000
and sum(case when t.TransactionType = 'Withdrawal' then t.Amount end) >5000;


-- Query-2) Rank-based Filtering (Advanced Window Function): Retrieve the top 3 highest loan amounts per country using the DENSE_RANK() function.
select *
from
(
select
	c.country,
	sum(l.LoanAmount) as total_loan_amount,
    dense_rank() over (partition by c.country order by l.loanAmount DESC) as dense_rank_count
from customers as c
join loans as l
	on c.CustomerID = l.CustomerID
group by c.country, l.loanAmount
) as loan_amount_count
where dense_rank_count <= 3;



