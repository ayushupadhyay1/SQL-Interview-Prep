use library_management_system;

-- ========================================================== EASY =============================================================================
-- Query-1) Use window functions to rank borrowers based on the total number of books borrowed.
select 
	b.borrower_id,
    b.borrower_name, 
    count(br.book_id) as borrowed_book_count,
    rank() over (order by  count(br.book_id)  desc) as RNK
from borrowingrecords as br
join borrowers as b
	on br.borrower_id = b.borrower_id
group by b.borrower_id, b.borrower_name;


-- Query-2) Find the median borrowing duration of all returned books.
select
	avg(duration) as average_duration
from
(
select
	datediff(return_date, borrow_date) as duration
from borrowingrecords as br
where return_date is NOT NULL
order by duration
limit 2 offset 1
) as median_set;


-- Query-3) Identify borrowers who have overdue books (borrowed more than 30 days ago and not returned).
select 
	b.borrower_id,
    b.borrower_name,
    datediff(current_date(), br.borrow_date) as duration
from borrowers as b
join borrowingrecords as br
	on b.borrower_id = br.borrower_id
where br.return_date is NULL
and datediff(current_date(), br.borrow_date) > 30;

-- Query-4) Create a CTE to get the last borrow date per book and join it with the Library table.
with last_borrow_date as 
(
select 
	l.book_id,
    l.title,
    br.borrow_date,
    rank() over (partition by l.book_id order by  br.borrow_date desc) as RNK
from borrowingrecords as br
join library as l
	on br.book_id = l.book_id
)
select
	book_id,
    title,
    borrow_date
from last_borrow_date
where RNK = 1;

-- Query-5) Use a recursive CTE to generate a sequence of dates between the earliest borrow date and the latest return date in the records.

-- Query-6) Find authors whose books have never been borrowed.
select 	
	l.Author
from library as l
left join borrowingrecords as br
	on l.book_id = br.book_id
where br.book_id is NULL;


-- Query-7) Calculate the percentage of books borrowed per genre relative to the total number of books.
with total_borrowed_books as 
(
select
	count(br.book_id) as total_books
from borrowingrecords as br
),
borrowed_books_by_genre as 
(
select
	l.genre,
    count(br.book_id) as book_count
from borrowingrecords as br
join library as l
	on br.book_id = l.book_id
group by l.genre
)
select
	genre_.genre,
    genre_.book_count,
    (genre_.book_count / total_.total_books) * 100 as percentage
from total_borrowed_books as total_, borrowed_books_by_genre as genre_;

-- Query-8) Pivot the borrowing count per month for each borrower for the year 2023.
select 
	b.borrower_id,
    b.borrower_name,
    count(case when month(br.borrow_date) = 1 then 1 end) as Jan,
    count(case when month(br.borrow_date) = 2 then 1 end) as Feb,
    count(case when month(br.borrow_date) = 3 then 1 end) as Mar,
    count(case when month(br.borrow_date) = 4 then 1 end) as Apr,
    count(case when month(br.borrow_date) = 5 then 1 end) as May,
    count(case when month(br.borrow_date) = 6 then 1 end) as Jun,
    count(case when month(br.borrow_date) = 7 then 1 end) as Jul,
    count(case when month(br.borrow_date) = 8 then 1 end) as Aug,
    count(case when month(br.borrow_date) = 9 then 1 end) as Sep,
    count(case when month(br.borrow_date) = 10 then 1 end) as Oct_,
    count(case when month(br.borrow_date) = 11 then 1 end) as Nov,
    count(case when month(br.borrow_date) = 12 then 1 end) as Dec_
from borrowers as b
join borrowingrecords as br
	on b.borrower_id = br.borrower_id
where year(br.borrow_date) = 2023
group by b.borrower_id, b.borrower_name, month(br.borrow_date);


-- ========================================================== INTERMEDIATE =============================================================================

-- Query-9) Find the average borrowing duration for each book (consider only returned books).
select 
	l.book_id,
    l.title,
   round(avg(datediff(br.return_date, br.borrow_date)),2) as average_duration
from library as l
join borrowingrecords as br
	on l.book_id = br.book_id
where br.return_date is not null
group by l.book_id, l.title;

-- Query-10) Find the top 3 borrowers who have borrowed the most books.
select 
	b.borrower_id,
    b.borrower_name,
    count(br.book_id) as book_count
from borrowers as b
join borrowingrecords as br
	on b.borrower_id = br.borrower_id
group by b.borrower_id, b.borrower_name
order by book_count desc
limit 3;

-- Query-11) Retrieve the list of books that have been borrowed more than once.
select 	
	l.book_id,
    l.title,
    count(br.borrower_id) as borrow_count
from library as l
join borrowingrecords as br
	on l.book_id = br.book_id
group by l.book_id, l.title
having count(br.borrower_id) > 1;

-- Query-12) Find books that have never been borrowed.
select 	
	l.book_id,
    l.title
from library as l
left join borrowingrecords as br
	on l.book_id = br.book_id
where br.book_id is NULL;


-- Query-14) Display the borrower who borrowed the oldest published book.
select 
	b.borrower_id,
    b.borrower_name,
    l.publish_year as Oldest_borrowed_book,
    l.title
from borrowers as b
join borrowingrecords as br
	on b.borrower_id = br.borrower_id
join library as l
	on l.book_id = br.book_id
order by l.publish_year
limit 1;

-- Query-15) List all books with their current borrowing status (borrowed or available).
select 
	l.book_id,
    l.title,
    case 
		when br.return_Date is NULL then 'Not Avaiable' 
		when br.return_Date is NOT NULL then 'Avaiable'
    end as Borrowing_Status
from library as l
join borrowingrecords as br
	on l.book_id = br.book_id;




