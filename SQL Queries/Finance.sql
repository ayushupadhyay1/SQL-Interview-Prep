-- ---------------------------------------------------------- PART-1 (EASY) ---------------------------------------------------------------------

-- Query: 1) Retrieve all customers from the USA.
select 
	CustomerName,
    country
from customers
where country = 'USA';


-- Query: 2) List all accounts with a balance greater than 10,000.
select
	AccountID,
    balance
from accounts
where balance > 10000;

-- Query: 3) Display all transactions of type 'Deposit'.
select
	TransactionID,
    TransactionType
from transactions 
where transactiontype = 'Deposit';

-- Query-4) Retrieve loan details with interest rate above 5%.
select *
from loans
where InterestRate > 5.00;

-- ---------------------------------------------------------- PART-2 (Intermediate) ---------------------------------------------------------------------

-- Query-1) Retrieve customer details who have a loan.
select
	c.customerId,
    l.LoanId,
    c.customerName,
    c.contactEmail,
    l.LoanAmount,
    l.InterestRate,
    l.StartDate,
    l.EndDate
from customers as c
right join loans as l
	on c.CustomerID = l.CustomerID;
    
-- Query-2) Find the total balance of all accounts.
select
	sum(balance) as total_amount
from accounts;

-- Query-3) List customers who made payments in March 2025.
select *
from
(
select
	c.CustomerName,
    date_format(p.PaymentDate, '%Y-%M') as Date_format
from customers as c
join loans as l
	on c.customerID = l.customerID
join payments as p
	on p.loanID = l.loanID
) as updated_date
where date_format = '2025-March';

-- Query-4) Display the total amount deposited in March 2025.
select
	sum(t.amount) as total_amount
from transactions as t
where t.transactionType = 'Deposit'
and date_format(TransactionDate, '%M-%Y')= 'March-2025';


-- Query-5) Show customers who have made withdrawals.
select
	C.CustomerName,
    t.TransactionType
from transactions as t
join accounts as a
	on t.AccountId = a.AccountID
join customers as c
	on c.customerID = a.customerID
where t.TransactionType = 'Withdrawal';

-- Query-6) List all loans starting in 2025.
select 
	LoanID,
    StartDate
from loans
where date_format(StartDate, '%Y') = '2025';


-- Query-7) Retrieve accounts with no transactions.
select
	a.accountID
from accounts as a
left join Transactions as t
on a.accountId = t.AccountID
where t.TransactionID is NULL;

-- Query-8) Retrieve customers who have never taken a loan.
select
	c.CustomerId,
    c.CustomerName
from customers as c
left join loans as l
	on c.CustomerID = l.CustomerID
where l.loanId is NULL;

-- Query-8) Display loan details along with corresponding customer names.
select
	c.CustomerID,
    c.CustomerName,
    l.loanID, 
    l.LoanAmount,
    l.InterestRate,
    l.StartDate,
    l.EndDate
from customers as c
join loans as l
	on c.CustomerId = l.CustomerID;
-- ---------------------------------------------------------- PART-3 (Medium) ---------------------------------------------------------------------
-- Query-1) Retrieve the total number of customers from each country.
select 
	count(customerID) as Customer_Count,
    Country
from customers
group by country;


-- Query-2) Find the total balance held by customers from the USA.
select
	sum(a.balance) as total_balance,
	c.country
from customers as c
join accounts as a
	on c.CustomerID = a.CustomerID
where c.country = 'USA'
group by c.country;


-- Query-3) Get the details of customers who have both a Savings and a Checking account.
select
	C.CustomerName
from customers as c
join accounts as a
on c.CustomerID = a.CustomerID
where a.AccountType in ('Checking', 'Savings')
group by c.CustomerName
having count(distinct a.AccountType) = 2;


-- Query-4) List all accounts opened in February 2025.
select *
from
(
select
	AccountID,
    AccountType,
    date_format(OpenedDate, '%Y-%m') as Account_Opeaned_Date
from accounts
) account_date
where Account_Opeaned_Date = '2025-02';

-- OR

select *
from accounts 
where date_format(OpenedDate, '%Y-%m') = '2025-02';


-- Query-5) Find the top 3 customers with the highest total account balance.
select
	a.AccountID,
    c.CustomerName,
    sum(a.Balance) as total_balance
from accounts as a
join customers as c
	on a.customerId = c.customerID
group by a.AccountID, c.CustomerName
order by total_balance desc
limit 3;


-- Query-6) Retrieve all transactions that are deposits and occurred in March 2025.
select *
from transactions
where TransactionType = 'Deposit'
and date_format(TransactionDate, '%M-%Y') = 'March-2025';


-- Query-7) Get the loan details for customers who have a loan interest rate greater than 5%.
select
	l.*
from customers as c
join loans as l
	on c.CustomerId = l.CustomerID
where l.InterestRate > 5.00;

-- Query-8) List customers who made payments of more than $2000 in a single transaction.
select
	c.CustomerName,
    p.PaymentAmount
from customers as c
join loans as l
	on c.CustomerId = l.CustomerId
join payments as p
	on p.loanID = l.loanID
where p.PaymentAmount > 2000;

-- Query-9) Retrieve the total transaction amount for each account.
select
	a.AccountID,
    sum(t.amount) total_amount
from transactions as t
join accounts as a
	on t.accountID = a.AccountID
group by a.AccountID;


-- ---------------------------------------------------------- PART-3 (HARD) ---------------------------------------------------------------------
-- Query-1) Find customers with the highest loan amount.
select
	c.CustomerID,
    l.LoanAmount
from customers as c
join loans as l
	on c.CustomerID = l.CustomerID
order by l.LoanAmount DESC
limit 1;

-- Query-2) Retrieve accounts with transactions above the average amount.
select
	t.AccountID,
    t.Amount
from transactions as t
where t.amount > 
				(
				select
				avg(amount) as avg_amount
				from transactions
				);
                
-- Query-3) List customers with multiple accounts.
select
	c.Customername,
    count(a.accountId) as account_count
from customers as c
join accounts as a
	on c.CustomerID = a.customerID
group by c.Customername
having count(a.accountId) > 1;


-- Query-4) Retrieve customers who made a payment more than once.
select
	c.customerName,
    count(p.paymentId) as payment_count
from customers as c
join loans as l
	on c.CustomerID = l.CustomerID
join Payments as p
	on p.loanID = l.LoanID
group by c.CustomerName
having count(p.paymentId) > 1;

-- Query-5) Find the customer with the highest account balance.
select
	c.CustomerName,
    a.balance
from customers as c
join accounts as a
	on c.CustomerID = a.CustomerID
order by a.balance desc
limit 1;

-- Query-6) List customers who have never taken a loan.
select 
	c.CustomerName
from customers as c
left join loans as l
	on c.customerId = l.customerID
where l.LoanID is NULL;
    
-- Query-7) Display the loan amount remaining for each customer.
select
	l.CustomerID,
    c.CustomerName,
	l.LoanID,
    l.LoanAmount,
    p.PaymentAmount,
    (l.LoanAmount - p.PaymentAmount) as Remaining_Loan
from loans as l
join payments as p
	on l.LoanID = p.LoanID
join customers as c
	on c.CustomerId = l.CustomerID;

-- Query-8) Retrieve accounts that had more deposits than withdrawals.
select
	t1.AccountID,
   sum(case when t1.Transactiontype = 'Deposit' then 1 else 0 end) as total_Deposits,
   sum(case when t1.TransactionType = 'Withdraw' then 1 else 0 end) as total_Wihdraw
from Transactions as t1
group by t1.AccountID
having sum(case when t1.TransactionType = 'Deposit' then 1 else 0 end) > 
		sum(case when t1.TransactionType = 'Withdraw' then 1 else 0 end);


use finance;



-- Query-7) List customers who have multiple loans and the total amount they owe.
select
	c.CustomerName,
    c.CustomerID,
    sum(l.LoanAmount) as total_loan_amount
from customers as c
join loans as l
	on c.CustomerID = l.CustomerID
group by c.CustomerName,c.CustomerID
having count(l.loanID) > 1;


-- Query-8)Identify accounts that have had no transactions in the last 3 months.
select *
from accounts
where OpenedDate >= current_date() - INTERVAL 3 month and OpenedDate is NULL;


-- Query-9) Find customers who made a deposit of more than $5000 and a withdrawal of more than $2000 on the same day.
select * from loans;
select * from customers;
select * from accounts;

-- Query-10) Rank customers based on their total loan amount and return only the top 5.


