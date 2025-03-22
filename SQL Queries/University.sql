select * from courses;
select * from departments;
select * from Enrollments;
select * from Professors;
select * from students;

-- --------------------------------------------------------- PART-1 (EASY) ---------------------------------------------------------------------
-- Query-1) Retrieve the names and emails of all students from the Students table who belong to the 'Computer Science' department.
select
	s.name,
    s.email,
    d.department_name
from departments as d
join students as s
	on d.department_id = s.department_id
where d.department_name = 'Computer Science';


-- Query-2) Count the total number of students in each department and display the department name along with the count.
select
	s.department_id,
    d.department_name,
	count(s.student_id) as student_count
from departments as d
join students as s
	on d.department_id = s.department_id
group by s.department_id, d.department_name
order by s.department_id asc;


-- Query-3) List all courses that have more than 3 credits.
select
	course_id,
    course_name,
    credits
from courses
where credits > 3;


-- Query-4) Find the students who enrolled in the course 'Database Systems'.
select
	e.student_id,
    s.name,
    c.course_name
from courses as c
join enrollments as e
	on c.course_id = e.course_id
join students as s
	on e.student_id = s.student_id
where c.course_name = 'Database Systems';


-- Query-5) Retrieve all unique departments from the Professors table.
select
	distinct d.department_name
from departments as d
join professors as p
	on d.department_id = p.department_id;


-- ------------------------------------------------------- PART-2 (MEDIUM) ---------------------------------------------------------------------

-- Query-1) Find the average grade for each course from the Enrollments table.
select
	c.course_name,
	e.course_id,
    round(avg
		(
			case 
				when e.grade = 'A' then 3.8
				when e.grade = 'A+' then 4.0
				when e.grade = 'B+' then 3.5
				when e.grade = 'B' then 3.0
                else null
			End
		),2) as average_grades
from enrollments as e
join courses as c
	on e.course_id = c.course_id
group by c.course_name,e.course_id;


-- Query-2) Retrieve the student name, course name, and grade for all students who scored an 'A'.
select 
	s.name,
    c.course_name,
    e.grade
from students as s
join enrollments as e
	on s.student_id = e.student_id
join courses as c
	on e.course_id = c.course_id
where grade = 'A';


-- Query-3) Get the top 3 highest-paid professors along with their department names.
select
	p.name,
    p.salary,
    d.department_name
from professors as p
join departments as d
on p.department_id = d.department_id
order by p.salary desc
limit 3;


-- Query-4) Find the number of students enrolled in each course, ordered in descending order.
select 
	count(e.student_id) as student_count,
    e.course_id,
    c.course_name
from students as s
join enrollments as e
	on s.student_id = e.student_id
join courses as c
	on e.course_id = c.course_id
group by e.course_id, c.course_name
order by student_count desc;

-- Query-5) Retrieve the professor name and course name they are teaching by performing a JOIN between Professors,
-- and Courses (Assume there's a Teaches table).
select
	c.course_name,
    p.name
from courses as c
join professors as p
	on c.department_id = p.department_id;

-- Query-6) Find all students who have enrolled in more than 2 courses.
select *
from 
(
select
	s.name,
	count(e.student_id) as studnet_count
from students as s
join enrollments as e
	on s.student_id = e.student_id
    group by s.name
    ) as student_enrollments_count
where studnet_count > 2;



-- Query-7) Retrieve students who have the same birth_date as another student (without using self-joins).
select
	s.student_id,
    s.name,
    s.birth_date
from students as s
where s.birth_date in 
(
	select birth_date
    from students 
    group by birth_date
    having count(*) > 1
);



-- Query-8) Find the total salary paid to professors in each department.
select
    sum(p.salary) as total_salry,
    d.department_name
from professors as p
join departments as d
on p.department_id = d.department_id
group by d.department_name;

-- Query-9) List all courses that have at least one student enrolled using an INNER JOIN.

select
	c.course_name,
    count(e.student_id) as student_count
from courses as c
inner join Enrollments as e
on c.course_id = e.course_id
group by c.course_name
having count(student_id) >= 1;

-- Query-10) Retrieve all students who have not enrolled in any course using a LEFT JOIN.
select
	s.name
from students as s
inner join Enrollments as e
on s.student_id = e.student_id
where e.course_id is NULL;

-- ------------------------------------------------------- PART-3 (HARD) ----------------------------------------------------------------------

-- Query-1) Find the student(s) who enrolled in the most number of courses.
select 
	s.name,
    count(course_id) as Student_Enrollment
from students as s
join Enrollments as e
on s.student_id = e.student_id
group by s.name
order by Student_Enrollment desc;


-- Query-2) Retrieve the top 2 departments with the highest number of students.
select 
	d.department_name,
    count(student_id) as number_of_students
from departments as d
join students as s
on d.department_id = s.department_id
group by d.department_name
order by number_of_students desc
limit 2;

-- Query-3) Find the student(s) with the second-highest total grades across all courses.
select 
	s.name,
	avg
    (
    case
		when grade = 'A' then '4.0'
        when grade = 'A-' then '3.8'
        when grade = 'B+' then '3.5'
        when grade = 'B-' then '3.0'
	end
    ) as grade
from students as s
join Enrollments as e
on s.student_id = e.student_id
group by s.name;



-- Query-4) Retrieve professors whose salary is above the department’s average salary.
select p.*
from professors as p
join
(
	select
		p.department_id,
		round(avg(p.salary),0) as averge_salary
	from professors as p
	join departments as d
	on p.department_id = d.department_id
	group by p.department_id
) as dept_avg 
on p.department_id = dept_avg.department_id
where p.salary > dept_avg.averge_salary;


-- Query-5) List all departments that have more than 5 students enrolled in at least 3 different courses.
select
	d.department_name,
    count(course_id) as course_count
from departments as d
join students as s
on d.department_id = s.department_id
join enrollments as e
on e.student_id = s.student_id
group by d.department_name
having count(distinct e.course_id) >= 3 and count(e.student_id) > 5;

-- Query-6) Retrieve the student(s) who are enrolled in all courses offered by their department.
select 
	s.student_id
from students as s
join enrollments as e
on s.student_id = e.student_id
join departments as d
on d.department_id = s.department_id
group by s.student_id
having count(distinct e.course_id) = (
select count(distinct c2.course_id)
from courses as c2
where c2.department_id = d.department_id
);



