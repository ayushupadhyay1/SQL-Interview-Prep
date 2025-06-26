use course_review_analysis;
-- ========================================================= Window Functions ==================================================================

-- Query-1) Find each user's average rating and their rank among all users by average rating.
select 
	u.user_id,
    u.username,
    round(avg(r.rating),2) as average_rating,
    rank() over (order by round(avg(r.rating),2) desc) as RNK
from users as u
join enrollments as e
	on u.user_id = e.user_id
join reviews as r
	on r.enrollment_id = e.enrollment_id
group by u.user_id, u.username;


-- Query-2) For each course, show users and their progress with a row_number based on enrollment date.
select 
	c.course_id,
    c.course_name,
    u.username,
    e.progress_percent,
    row_number() over (partition by c.course_id order by e.enrollment_date) as enrollment_order
from courses as c
join enrollments as e
	on c.course_id = e.course_id
join users as u
	on u.user_id = e.user_id;

-- Query-3) For each user, show total completed courses and a running total using window function.
select 
	u.user_id, 
    u.username,
    sum(e.completed) as total_completed_course,
    sum(e.completed) over (order by u.user_id) as Running_total
from users as u
join enrollments as e
	on u.user_id = e.user_id
where e.completed = 1
group by u.user_id, u.username;

-- Query-4) List the top 2 most recent reviews per course using dense_rank.
select 
	course_id,
    course_name,
    review_id,
    review_text
from
(
select 
	c.course_id,
    c.course_name,
    r.review_id,
    r.review_text,
    dense_rank() over (partition by c.course_id order by r.review_date desc) as RNK
from courses as c 
join enrollments as e
	on c.course_id = e.course_id
join reviews as r
	on r.enrollment_id = e.enrollment_id
) as top_2_reviews
where RNK <= 2;

-- ============================================================= CTE's ==========================================================================

-- Query-5) Use a CTE to find users who enrolled in more than one course.
with students_with_more_than_1_course as
(
select
	u.user_id,
    u.username,
    count(e.course_id) as Registered_Courses
from users as u
join enrollments as e
	on u.user_id = e.user_id
group by u.user_id, u.username
)
select
	user_id,
    username,
    Registered_Courses
from students_with_more_than_1_course
where Registered_Courses > 1;


-- Query-6) With a CTE, show average progress by course level, and filter only levels with avg progress > 70.
with course_more_than_70_percent_progress as
(
select 
	c.level,
    round(avg(e.progress_percent),2) as average_progress
from courses as c
join enrollments as e
	on c.course_id = e.course_id
group by c.level
)
select
	level,
    average_progress
from course_more_than_70_percent_progress
where average_progress > 70.00;

-- ============================================================= VIEWS ==========================================================================
-- Query-7) Create a view showing users with their completed course count and average rating.
create or replace view completed_courses_rating as
(
select 
	u.user_id,
    u.username,
    count(e.course_id) as course_count,
    round(avg(r.rating),2) as average_rating
from users as u 
join enrollments as e
	on u.user_id = e.user_id
join reviews as r
	on r.enrollment_id = e.enrollment_id
where e.completed = 1
group by u.user_id, u.username
order by u.user_id
);

select * from completed_courses_rating;

-- Query-8) Create a view that includes each course, total enrollments, and completion rate.
create or replace view course_completion_stats as 
select 
	c.course_id,
    c.course_name,
    count(e.enrollment_id) as total_enrollments,
    round(sum(case when e.completed = true then 1 else 0 end) * 100.0 / count(e.enrollment_id),2) as completion_rate
from courses as c
left join enrollments as e
	on c.course_id = e.course_id
group by c.course_id, c.course_name
order by c.course_id;

select * from course_completion_stats;

-- ============================================================= SUB-QUEREIS ==========================================================================

-- Query-9) Show all users who have given a rating higher than the average rating.
select 
	u.user_id,
    u.username,
    r.rating
from users as u
join enrollments as e
	on u.user_id = e.user_id
join reviews as r
	on r.enrollment_id = e.enrollment_id
where r.rating > 
(select
	avg(e1.rating) 
from reviews as e1
);


-- Query-10) List courses that have never been reviewed.
 select 
	c.course_id,
    c.course_name
 from courses as c
 join enrollments as e
	on c.course_id = e.course_id
left join reviews as r
	on r.enrollment_id = e.enrollment_id
where r.review_id is NULL;
 
 
-- Query-11) Get users who have enrolled in all beginner-level courses.
SELECT u.user_id, u.username
FROM users u
JOIN enrollments e ON u.user_id = e.user_id
JOIN courses c ON c.course_id = e.course_id
WHERE c.level = 'beginner'
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT c.course_id) = (
    SELECT COUNT(*) FROM courses WHERE level = 'beginner'
);


-- Query-12)  Find the course with the highest average rating.
select 
	c.course_id,
    c.course_name,
    round(avg(r.rating),2) as average_rating
from courses as c
join enrollments as e
	on c.course_id = e.course_id
join reviews as r
	on r.enrollment_id = e.enrollment_id
group by c.course_id, c.course_name
order by average_rating desc
limit 1;



