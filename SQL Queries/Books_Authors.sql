-- Create Database
create database Books_Author;

use Books_Author;
-- Authors Table
CREATE TABLE Authors (
    author_id INT PRIMARY KEY,
    name VARCHAR(100),
    country VARCHAR(50),
    birth_year INT
);

INSERT INTO Authors (author_id, name, country, birth_year) VALUES
(1, 'George Orwell', 'United Kingdom', 1903),
(2, 'Haruki Murakami', 'Japan', 1949),
(3, 'J.K. Rowling', 'United Kingdom', 1965),
(4, 'Gabriel Garcia Marquez', 'Colombia', 1927),
(5, 'Jane Austen', 'United Kingdom', 1775);

-- Books Table
CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200),
    author_id INT,
    genre VARCHAR(50),
    publication_year INT,
    available_copies INT,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

INSERT INTO Books (book_id, title, author_id, genre, publication_year, available_copies) VALUES
(1, '1984', 1, 'Dystopian', 1949, 4),
(2, 'Kafka on the Shore', 2, 'Magical Realism', 2002, 2),
(3, 'Harry Potter and the Sorcerer''s Stone', 3, 'Fantasy', 1997, 5),
(4, 'One Hundred Years of Solitude', 4, 'Magical Realism', 1967, 3),
(5, 'Pride and Prejudice', 5, 'Romance', 1813, 1);

-- BorrowRecords Table
CREATE TABLE BorrowRecords (
    record_id INT PRIMARY KEY,
    book_id INT,
    borrower_name VARCHAR(100),
    borrow_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

INSERT INTO BorrowRecords (record_id, book_id, borrower_name, borrow_date, return_date) VALUES
(1, 1, 'Emma Wilson', '2024-02-01', '2024-02-10'),
(2, 3, 'Liam Johnson', '2024-03-05', NULL),
(3, 2, 'Sophia Martinez', '2024-03-10', '2024-03-20'),
(4, 5, 'Noah Davis', '2024-03-15', NULL),
(5, 4, 'Olivia Brown', '2024-03-18', '2024-03-25');



use books_author;

-- ------------------------------------------------ PART-1 (EASY) ----------------------------------------------------

-- Query-1) Retrieve the list of all books along with their genres.
select
    title,
    genre
from books;


-- Query-2) Find the total number of books available in the library.
select 
	sum(available_copies) as books_avaiable_in_library
from books;

-- Query-3) Get the names of all authors from the United Kingdom.
select
	name
from authors
where country = 'United Kingdom';

-- Query-4) Show the details of books that were borrowed but not yet returned.
select 
	br.book_id,
    b.title,
    br.borrower_name,
    br.borrow_date,
    br.return_date
from borrowrecords as br
join books as b
on b.book_id = br.book_id
where return_date is null;

-- Query-5) Count how many times each book has been borrowed.
select
    br.book_id,
    b.title,
    br.borrower_name,
    count(br.record_id) as borrow_count
from borrowrecords as br
join books as b
on br.book_id = b.Book_id
group by br.book_id, b.title, br.borrower_name;


-- ------------------------------------------------ PART-2 (MEDIUM) ---------------------------------------------------

-- Query-1) Retrieve the names of borrowers who have borrowed books written by "Haruki Murakami".
select
	a.author_id,
    a.name,
	br.borrower_name,
    b.title
from authors as a
join books as b
on a.author_id = b.author_id
join borrowrecords as br
on b.book_id = br.book_id
where a.name = 'Haruki Murakami';


-- Query-2) List all books along with their authors’ names
select
	a.name as author_name,
    b.title as book_name
from authors as a
join books as b
on a.author_id = b.author_id;


-- Query-3) Find the author who has written the most books in the library.
select
	a.author_id,
    a.name as author_name,
    count(b.book_id) as Most_books_written
from authors as a
join books as b
on a.author_id = b.author_id
group by a.author_id, a.name
order by Most_books_written desc
limit 1;

-- Query-4) Get the name of the borrower who borrowed the most books.
select 
	count(book_id) as borrow_count,
    borrower_name
from borrowrecords
group by borrower_name
limit 1;

-- Query-5) Retrieve the most recent book borrow record from the BorrowRecords table
select
	book_id,
    borrower_name,
    borrow_date
from borrowrecords
order by borrow_date desc
limit 1;
-- ------------------------------------------------ PART-3 (HARD) ---------------------------------------------------
-- Query-1) List the top 2 most frequently borrowed books along with the number of times they were borrowed
select 
	b.title,
    count(br.book_id) as most_frequent_borrowed_book
from books as b
join borrowrecords as br
on b.book_id = br.book_id
group by b.title
order by most_frequent_borrowed_book desc
limit 2;

-- Query-2) Show books that have never been borrowed.
select
	b.book_id,
    b.title,
    b.genre
from books as b
left join borrowrecords as br
on b.book_id = br.book_id
where br.book_id is NULL;

-- Query-3) Retrieve the details of the book that was borrowed for the longest duration
select
	book_id,
    borrower_name,
    borrow_date,
    return_Date,
    datediff(return_date, borrow_date) as duration
from borrowrecords
where return_date is not null
order by duration desc
limit 1;

-- Query-4) Get the author(s) whose books are available in the maximum number of copies.
select
	a.author_id,
    a.name,
    sum(b.available_copies) as available_books_at_library
from authors as a
join books as b
on a.author_id = b.author_id
group by a.author_id, a.name
order by available_books_at_library desc;


-- Query-5) Retrieve books where the number of available copies is below the average number of available copies across all books
select 
    title,
    genre,
	available_copies
from books as b
where b.available_copies < (select round(avg(available_copies), 2)from books);




