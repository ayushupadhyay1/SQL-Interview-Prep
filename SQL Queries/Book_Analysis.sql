use book_analysis;

-- ======================================================== CASE STATEMENT ===================================================================

-- Query-1) Write a SQL query that retrieves all books and categorizes their publication_year into 'Old Books' (before 2016), 'Modern books' (2017-2020), or 'recently added' (after 2020).
select
	book_id,
    title,
    case
		when publication_year < 2017 then 'Old Books'
        when publication_year between 2017 and 2020 then 'Modern books'
        when publication_year > 2020 then 'Recently Added Books'
    end as book_categories
from books;

-- Query-2) From the Loans table, write a query that shows loan_id, book_id, borrower_id, and a loan_status column. The loan_status should be 'Returned' if return_date is not NULL, and 'Outstanding' if return_date is NULL.
select
	loan_id,
    book_id,
    borrower_id,
    case
		when return_date is NOT NULL then 'Returned'
        when return_date is NULL then 'Outstanding'
    end as Loan_Status
from Loans;

-- Query-3) Write a query that lists each borrower's full name (first_name and last_name) and classifies them based on how many books they currently have outstanding: 'High Borrower' (2 or more), 'Moderate Borrower' (1), or 'No Outstanding Loans' (0).
select 
	b.borrower_id,
    first_name,
    last_name,
    count(case when l.return_date is NULL then 1 end) as book_count,
    case
		when count(case when l.return_date is NULL then 1 end) >= 2 then 'High Borrower'
        when count(case when l.return_date is NULL then 1 end) >= 1 then 'Moderate Borrower'
        when count(case when l.return_date is NULL then 1 end) = 0 then 'No Outstanding Loans'
    end as Borrower_Categories
from borrowers as b
left join loans as l
	on b.borrower_id = l.borrower_id
group by b.borrower_id, first_name, last_name;

-- ======================================================== WINDOW FUNCTION ===================================================================

-- Query-4) For each book, list its title, author, publication_year, and the average_publication_year_by_genre for that book's genre.
select
	book_id,
    title,
    author,
    publication_year,
    avg(publication_year) over (partition by genre) as average_publication_year_by_genre
from books as b
order by book_id;

-- Query-5) Retrieve the loan_id, book_id, borrower_id, and loan_date for each loan. Also, include a column that shows the previous_loan_date for the same book, ordered by loan_date. If it's the first loan for that book, this column should be NULL.
select
	loan_id,
    book_id,
    borrower_id,
    loan_date,
    lag(loan_date) over (partition by book_id order by loan_date) as Previous_Issued_Date
from loans;

-- Query-6) Find the top 3 most frequently borrowed books for each genre. The result should include genre, book_id, title, and borrow_count, ordered by genre and then borrow_count in descending order.
select 
	genre,
    book_id,
    title,
    borrower_count
from(
	select 
		b.book_id,
		b.title,
		b.genre,
		count(l.borrower_id) as borrower_count,
		rank() over (partition by genre order by count(l.borrower_id) desc) as RNK
	from books as b
	join loans as l
		on b.book_id = l.book_id
	group by b.book_id, b.title, b.genre
) as most_borrowed_book
where RNK <= 3;


-- Query-7) Calculate the running_total_loans for each borrower_id over time, ordered by loan_date. The result should include borrower_id, loan_date, and the running_total_loans.
select 
	b.Borrower_id,
    b.first_name,
    b.last_name,
    l.loan_date,
    sum(1) over (partition by b.borrower_id order by l.loan_date ROWS unbounded preceding) as running_total_loans
from borrowers as b
left join loans as l
	on b.borrower_id = l.borrower_id;

-- ======================================================== Common Table Expressions ===================================================================
-- Query-9) Using a CTE, find all borrowers who have borrowed more than 2 distinct books. Display their borrower_id, first_name, and last_name.
with boorwers_with_more_than_2_book as
(
select 
	b.borrower_id,
    first_name,
    last_name,
    count(distinct l.book_id) as distinct_book_count
from borrowers as b
join loans as l
	on b.borrower_id = l.borrower_id
group by b.borrower_id, first_name, last_name
)
select
	borrower_id,
    first_name,
    last_name
from boorwers_with_more_than_2_book
where distinct_book_count > 2;
    

-- Query-10) Write a query using a CTE to determine the longest duration any book has been on loan. The result should show book_id, title, and loan_duration_days.
with cte as
(
select 
	b.book_id,
    b.title,
    (l.return_date - l.loan_Date) as loan_duration_Days
from books as b
join loans as l
	on b.book_id = l.book_id
    where l.return_Date is NOT NULL
)
select
	book_id,
    title,
    loan_duration_Days
from cte
order by loan_duration_Days desc
limit 1;



-- Query-11) Create a CTE that lists all books that have never been borrowed. Then, write a query to display the title and author of these books.
with cte as
(
select 
	b.*
from books as b
left join loans as l
	on b.book_id = l.book_id
where l.book_id is NULL
)
select
	title,
    author
from cte;

-- Query-12) Using CTEs, find the top 5 borrowers who have borrowed the most books in total, along with the count of books they've borrowed.
with borrower_book_count as
(
select 
	b.borrower_id,
    b.first_name,
    b.last_name,
    b.email,
    count(l.book_id) as borrowed_book_count
from borrowers as b
join loans as l
	on b.borrower_id = l.borrower_id
group by b.borrower_id, b.first_name, b.last_name,b.email
)
select
	borrower_id,
    first_name,
    last_name,
    borrowed_book_count
from borrower_book_count
order by borrowed_book_count desc
limit 5;

-- ======================================================== VIEWS ===================================================================

-- Query-13) Create a VIEW named Current_Outstanding_Loans that shows book_id, title, borrower_id, first_name, last_name, and loan_date for all books that are currently not returned.
create or replace view current_outstanding_loans as
(
select 
	b.book_id,
    br.borrower_id,
    b.title,
    br.first_name,
    br.last_name,
    l.loan_date
from books as b
join loans as l
	on b.book_id = l.book_id
join borrowers as br
	on br.borrower_id = l.borrower_id
where l.return_date is NULL
);
select * from current_outstanding_loans;


-- Query-14) Create a VIEW named Genre_Loan_Counts that displays each genre and the total number of loans for that genre.
create or replace view genre_loan_counts as
(
select 
	b.genre,
    count(l.loan_id) as total_number_of_loans
from books as b
join loans as l	
	on b.book_id = l.book_id
group by b.genre
order by total_number_of_loans desc
);

select * from genre_loan_counts;

-- ======================================================== OTHER ADVANCED SQL QUERIES ===================================================================

-- Query-15) Find the titles of all books that have been borrowed by a borrower whose first_name starts with 'A'.
select 
	distinct b.book_id,
	b.title,
    br.first_name
from books as b
join loans as l
	on b.book_id = l.book_id
join borrowers as br
	on br.borrower_id = l.borrower_id
where br.first_name like 'A%'
order by b.book_id;


-- Query-16) Date Functions: Write a query to list all books that were borrowed in the first quarter of 2024 (January 1 to March 31). Include title, borrower_id, and loan_date.
select 
	b.title,
    br.borrower_id,
    l.loan_Date
from books as b
join loans as l
	on b.book_id = l.book_id
join borrowers as br
	on br.borrower_id = l.borrower_id
where l.loan_Date between '2024-01-01' and '2024-03-31';



-- Query-17) Handling Duplicates: Imagine a scenario where the Loans table might accidentally have duplicate entries for the same loan_id. How would you write a query to identify and then delete only the duplicate rows, keeping one instance of each unique loan_id?
select * from books;
select * from borrowers;
select * from loans;

with dupilicate_loan_data as
(
select 
	*,
    row_number() over (partition by loan_id order by loan_Date) as rn
from loans 
)
delete from loans
where loan_id in(
				select loan_id
				from dupilicate_loan_data
                where rn > 1);

