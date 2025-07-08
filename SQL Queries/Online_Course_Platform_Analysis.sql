create database Online_Course_Platform;

use Online_Course_Platform;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    signup_date DATE,
    country VARCHAR(50)
);

INSERT INTO users (user_id, name, signup_date, country) VALUES
(1, 'Alice', '2023-01-01', 'USA'),
(2, 'Bob', '2023-01-10', 'India'),
(3, 'Charlie', '2023-02-15', 'UK'),
(4, 'David', '2023-03-20', 'Canada'),
(5, 'Eva', '2023-04-05', 'USA');

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    instructor_name VARCHAR(100),
    difficulty VARCHAR(20)
);

INSERT INTO courses (course_id, course_name, instructor_name, difficulty) VALUES
(101, 'SQL for Beginners', 'Jane Smith', 'Beginner'),
(102, 'Advanced Python', 'John Doe', 'Advanced'),
(103, 'Data Visualization', 'Emily Clark', 'Intermediate'),
(104, 'Machine Learning', 'David Brown', 'Advanced');

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    user_id INT,
    course_id INT,
    enrollment_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO enrollments (enrollment_id, user_id, course_id, enrollment_date, status) VALUES
(1, 1, 101, '2023-01-05', 'completed'),
(2, 2, 102, '2023-01-12', 'in_progress'),
(3, 3, 103, '2023-02-20', 'completed'),
(4, 4, 104, '2023-03-25', 'in_progress'),
(5, 5, 101, '2023-04-06', 'completed'),
(6, 1, 102, '2023-05-01', 'dropped'),
(7, 3, 104, '2023-06-01', 'in_progress');


CREATE TABLE course_reviews (
    review_id INT PRIMARY KEY,
    user_id INT,
    course_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO course_reviews (review_id, user_id, course_id, rating, review_date) VALUES
(1, 1, 101, 5, '2023-01-10'),
(2, 3, 103, 4, '2023-02-25'),
(3, 5, 101, 3, '2023-04-10'),
(4, 2, 102, 4, '2023-01-15'),
(5, 4, 104, 2, '2023-04-01');

-- =========================================================== BEGINNER ======================================================================

-- Query-1) Get the names of users who signed up after February 1, 2023.
select
	user_id,
    name
from users 
where signup_date > '2023-02-01';

-- Query-2) List course names along with the names of users who are enrolled in them.
select 
	e.user_id,
    u.name,
    c.course_name
from courses as c
join enrollments as e
	on c.course_id = e.course_id
join users as u
	on u.user_id = e.user_id
order by e.user_id;

-- Query-3) Find the number of enrollments for each course.
select
	e.course_id,
    c.course_name,
    count(e.enrollment_id) as enrollment_count
from courses as c
join enrollments as e
	on c.course_id = e.course_id
group by e.course_id, c.course_name
order by enrollment_count desc;

-- Query-4) Show the top 3 users based on the number of enrollments.
select 
	e.user_id,
    u.name,
    count(e.enrollment_id) as enrollment_count
from enrollments as e
join users as u
	on e.user_id = u.user_id
group by e.user_id, u.name
order by enrollment_count desc
limit 3;

-- =========================================================== INTERMEDIATE ======================================================================
    
-- Query-5) List all courses and show how many users reviewed them (0 if none).
select 
	c.course_id,
    c.course_name,
    count(cr.review_id) as Reviewer_count
from courses as c
left join course_reviews as cr
	on c.course_id = cr.course_id
group by c.course_id, c.course_name;


-- Query-6) Find instructors who have an average course rating above 3.5.
select 
	c.instructor_name,
    round(avg(cr.rating),2) as average_rating
from courses as c
join course_reviews as cr
	on c.course_id = cr.course_id
group by c.instructor_name
having avg(cr.rating) > 3.5;


-- Query-7) Find users who have completed all the courses they enrolled in.
select 
	u.user_id,
    u.name
from users as u
join enrollments as e
	on u.user_id = e.user_id
group by u.user_id, u.name
Having count(*) = sum(case when lower(e.status)='completed' then 1 else 0 end);

-- Query-8) Use a CTE to calculate average rating per course and filter those with avg rating ≥ 4.
with course_with_average_rating as
(
select 
	c.course_id,
    c.course_name,
    round(avg(cr.rating),2) as average_rating
from courses as c
join course_reviews as cr
	on c.course_id = cr.course_id
group by c.course_id, c.course_name
)
select
	course_id,
    course_name,
    average_rating
from course_with_average_rating
where average_rating >= 4;


-- Query-9) Rank users based on the number of completed courses.
with completed_courses as
(
select 
	u.user_id,
    u.name,
	sum(case when lower(e.status) = 'completed' then 1 else 0 end) as completed_courses_count
from users as u
join enrollments as e
	on u.user_id = e.user_id
group by u.user_id, u.name
)
select
	user_id,
    name,
    completed_courses_count,
    rank() over (order by completed_courses_count desc) as RNK
from completed_courses;


-- =========================================================== ADVANCED ======================================================================

-- Query-10) For each user, show the date of their first and most recent enrollment.
select 
	u.user_id,
    u.name,
    min(e.enrollment_date) as first_Enrollment_Date,
    max(e.enrollment_date) as first_Enrollment_Date
from users as u
join enrollments as e
	on u.user_id = e.user_id
group by u.user_id, u.name;

-- Query-11) For each course, calculate the average rating in rolling order of review date.
select 
	c.course_id,
    c.course_name,
    round(avg(cr.rating) over (partition by c.course_id order by cr.review_date),2) as rolling_average
from courses as c
join course_reviews as cr
	on c.course_id = cr.course_id
order by c.course_id, cr.review_date;


-- Query-12) Find users who have only taken beginner-level courses and completed all of them.
select 
	u.user_id,
    u.name
from users as u
join enrollments as e
	on u.user_id = e.user_id
join courses as c
	on c.course_id = e.course_id
group by u.user_id, u.name
having 
	sum(case when c.difficulty <> 'Beginner' then 1 else 0 end) = 0
    and sum(case when e.status <> 'Completed' then 1 else 0 end) = 0;

-- Query-13) Create a view that labels users as 'New', 'Active', or 'Dormant' based on their signup date and enrollment activity.
SELECT 
    u.user_id,
    u.name,
    CASE
        WHEN u.signup_date >= CURDATE() - INTERVAL 30 DAY THEN 'New'
        WHEN EXISTS (
            SELECT 1
            FROM enrollments e
            WHERE e.user_id = u.user_id
              AND e.enrollment_date >= CURDATE() - INTERVAL 60 DAY
        ) THEN 'Active'
        ELSE 'Dormant'
    END AS status
FROM users u;

-- Query-14) For each user, show their highest-rated course (based on rating) using ROW_NUMBER().
with highest_rated_course as
(
select 
	u.user_id,
    u.name,
    cr.rating,
    row_number() over (partition by u.user_id order by cr.rating desc) as Course_Rating
from users as u
join enrollments as e
	on u.user_id = e.user_id
join course_reviews as cr
	on cr.course_id = e.course_id
)
select
	user_id,
    name,
    rating
from highest_rated_course
where Course_Rating = 1;




select * from course_reviews;
select * from courses;
select * from enrollments;
select * from users;
