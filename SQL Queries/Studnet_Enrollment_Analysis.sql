-- ====================================================== DATASET ==============================================================

CREATE TABLE Students (
    StudentID INTEGER PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    DateOfBirth DATE,
    Major TEXT,
    EnrollmentDate DATE
);

INSERT INTO Students (StudentID, FirstName, LastName, DateOfBirth, Major, EnrollmentDate) VALUES
(101, 'Alice', 'Smith', '2000-01-15', 'Computer Science', '2018-09-01'),
(102, 'Bob', 'Johnson', '1999-05-20', 'Mathematics', '2018-09-01'),
(103, 'Charlie', 'Brown', '2001-11-10', 'Physics', '2019-09-01'),
(104, 'Diana', 'Prince', '2000-03-01', 'Computer Science', '2019-09-01'),
(105, 'Eve', 'Davis', '1998-07-25', 'Mathematics', '2017-09-01'),
(106, 'Frank', 'White', '2002-02-14', 'Chemistry', '2020-09-01'),
(107, 'Grace', 'Lee', '2000-09-05', 'Computer Science', '2018-09-01'),
(108, 'Henry', 'Clark', '1999-12-30', 'Physics', '2018-09-01'),
(109, 'Ivy', 'Garcia', '2001-04-18', 'History', '2019-09-01'),
(110, 'Jack', 'Miller', '2000-08-08', 'Mathematics', '2019-09-01');


CREATE TABLE Courses (
    CourseID INTEGER PRIMARY KEY,
    CourseName TEXT NOT NULL,
    Credits INTEGER NOT NULL,
    Department TEXT NOT NULL
);

INSERT INTO Courses (CourseID, CourseName, Credits, Department) VALUES
(201, 'Introduction to Programming', 3, 'Computer Science'),
(202, 'Calculus I', 4, 'Mathematics'),
(203, 'Classical Mechanics', 3, 'Physics'),
(204, 'Data Structures', 3, 'Computer Science'),
(205, 'Linear Algebra', 3, 'Mathematics'),
(206, 'Organic Chemistry', 4, 'Chemistry'),
(207, 'Database Systems', 3, 'Computer Science'),
(208, 'Thermodynamics', 3, 'Physics'),
(209, 'World History I', 3, 'History'),
(210, 'Differential Equations', 3, 'Mathematics');

CREATE TABLE Enrollments (
    EnrollmentID INTEGER PRIMARY KEY,
    StudentID INTEGER NOT NULL,
    CourseID INTEGER NOT NULL,
    Grade REAL, -- Grade can be a decimal (e.g., 3.5 for B+)
    Semester TEXT NOT NULL,
    EnrollmentYear INTEGER NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, Grade, Semester, EnrollmentYear) VALUES
(1, 101, 201, 3.8, 'Fall', 2018),
(2, 101, 204, 3.5, 'Spring', 2019),
(3, 102, 202, 3.0, 'Fall', 2018),
(4, 102, 205, 3.2, 'Spring', 2019),
(5, 103, 203, 4.0, 'Fall', 2019),
(6, 104, 201, 3.9, 'Fall', 2019),
(7, 104, 207, 3.7, 'Spring', 2020),
(8, 105, 202, 2.8, 'Fall', 2017),
(9, 105, 210, 3.1, 'Fall', 2018),
(10, 106, 206, 3.6, 'Fall', 2020),
(11, 107, 201, 3.7, 'Fall', 2018),
(12, 107, 204, 3.9, 'Spring', 2019),
(13, 108, 203, 3.5, 'Fall', 2018),
(14, 109, 209, 3.3, 'Fall', 2019),
(15, 110, 205, 3.0, 'Spring', 2020),
(16, 101, 207, 3.6, 'Fall', 2019),
(17, 102, 201, 3.1, 'Spring', 2020),
(18, 103, 208, 3.8, 'Spring', 2020),
(19, 104, 204, 3.8, 'Fall', 2020),
(20, 105, 205, 2.9, 'Spring', 2018);



use	student_enrollment_info;

-- ------------------------------------------------- WINDOW FUNCTION -----------------------------------------------------------

-- Query-1) For each course in the 'Fall' 2018 semester, rank students by their grade in descending order. Include the student's first name, last name, course name, grade, semester, and enrollment year.
select 
	s.FirstName,
    s.LastName,
    c.courseName,
    e.grade,
    e.semester,
    e.EnrollmentYear,
    rank() over (partition by c.courseName order by e.grade desc) as RNK
from students as s
join Enrollments as e
	on e.studentId = s.studentId
join courses as c
	on c.courseId = e.CourseId
where e.semester = 'Fall' and e.EnrollmentYear = 2018;


-- Query-2) Calculate the cumulative sum of credits for each student, ordered by their enrollment year and then by semester (Fall before Spring). Include the student's first name, last name, course name, and credits.
select 
	s.firstName,
    s.lastname,
    c.courseName,
    c.credits,
    sum(c.credits) over (
		partition by s.studentId 
        order by e.enrollmentyear, 
        case e.semester 
			when 'Fall' then 1 
            when 'spring' then 2 
            else 3 
            end) as cumulative_sum_of_credits
from courses as c
join enrollments as e
	on c.courseId = e.courseId
join students as s
	on s.studentId = e.studentID;


-- Query-3) Identify the student(s) who achieved the highest grade in each department during the 'Fall' 2019 semester. Display the department, course name, student's first name, last name, and their grade.
select *
from
(
select 
	c.department,
    c.courseName,
    s.firstname,
    s.lastname,
    e.grade,
    row_number() over (partition by c.department order by e.grade desc) as RNK
from students as s
join enrollments as e
	on s.studentId = e.studentId
join courses as c
	on c.courseID = e.courseID
where e.semester = 'Fall' and e.EnrollmentYear = '2019'
) as students_with_highest_grades
where RNK = 1;

-- ------------------------------------------------------ CTE's ----------------------------------------------------------------

-- Query-4) Find the first name, last name, and the count of courses for students who are enrolled in more than one course in the 'Fall' 2019 semester.
with students_with_more_than_one_courses as
(
select 
	s.firstname,
    s.lastName,
    count(e.courseId) as course_count
from students as s
join enrollments as e
	on s.studentId = e.studentId
where e.semester = 'Fall' and e.enrollmentYear = 2019
group by s.firstname, s.lastname
)
select
	firstname,
    lastName,
    course_count
from students_with_more_than_one_courses
where course_count > 1;

-- Query-5) Determine the average grade for each major. Display only those majors where the average grade is greater than 3.5.
with majors_with_higer_grades as
(
select 	
	s.major,
    round(avg(e.grade),2) as average_grade
from courses as c
join enrollments as e
	on c.courseId = e.CourseId
join students as s
	on s.studentID = e.StudentId
group by s.major
)
select
	major,
    average_grade
from majors_with_higer_grades
where average_grade > 3.5
order by average_grade desc;

-- Query-6) List the names of courses that have no enrollments in any semester.
with course_with_no_enrollments as
(
select 
	c.Coursename
from courses as c
left join enrollments as e
	on c.courseId = e.courseId
where e.courseId is NULL
)
select
	Coursename
from course_with_no_enrollments;
-- ------------------------------------------------------- VIEWS ---------------------------------------------------------------

-- Query-7) Create a logical structure (similar to a view) that combines detailed student enrollment information. This structure should include the student's first name, last name, major, course name, department, grade, semester, and enrollment year.
create or replace view student_enrollment_info as
(
select 
	s.firstname,
    s.lastname,
    s.major,
    c.coursename,
    c.department,
    e.grade,
    e.semester,
    e.enrollmentyear
from courses as c
join enrollments as e
	on c.courseId = e.courseId
join students as s
	on s.studentId = e.studentid
);

select * from student_enrollment_info;


-- Query-8) Create a logical structure (similar to a view) that summarizes the total number of courses offered by each department. Display the department name and the count of courses.
create or replace view courses_offered_by_each_department as
(
select
	Department,
    count(courseid) as course_count
from courses
group by department
);

select * from courses_offered_by_each_department;
-- ------------------------------------------------------- ADVANCED JOINS ---------------------------------------------------------------
-- Query-9) Retrieve a list of all students and any courses they are enrolled in. Ensure that students who are not enrolled in any courses are also included in the result. Display student first name, last name, course name, and grade.
select 
	s.firstname,
    s.lastname,
    c.coursename,
    e.grade
from students as s
left join enrollments as e
	on s.studentId = e.studentid
left join courses as c
	on c.courseid = e.courseid;

-- Query-10) Retrieve a list of all courses and any students enrolled in them. Ensure that courses with no enrollments are also included in the result. Display course name, student first name, last name, and grade.
select 
	c.courseName,
    s.Firstname,
    s.lastname,
    e.grade
from courses as c
left join enrollments as e
	on c.courseid = e.courseid
left join students as s
	on s.studentid = e.studentid
order by c.courseName;

-- ------------------------------------------------------- SUB QUERIES ---------------------------------------------------------------
-- Query-12) List the first name, last name, major, and grade of students whose grade in a course 
-- is higher than the average grade of all students within their respective major.
select 
	s.Firstname,
    s.Lastname,
    s.Major,
    e.Grade
from students as s
join enrollments as e
	on s.studentId = e.StudentId
where e.grade > (
				select
					avg(e.grade) as average_grades
                from enrollments as e1
                join students as s2
                on s2.studentid = e1.studentid
                where s2.major = s.major
                );
 
-- Query-13) Find the names of courses that have been taken by at least one student whose major is 'Computer Science'.
select 
	c.CourseName,
    count(e.studentId) as studnet_count
from students as s
join enrollments as e
	on s.studentId = e.studentId
join courses as c
	on c.courseid = e.courseId
where s.major = 'Computer Science'
group by c.coursename
Having count(e.studentId) >= 1;


-- Query-14) Identify the student(s) (first name, last name) who have taken the maximum number of courses across all semesters.
--  Include the count of courses they have taken.
with students_with_maximum_numbers_of_courses as
(
select 
	s.FirstName,
    s.LastName,
    count(e.courseId) as course_count
from courses as c
join enrollments as e
	on c.courseid = e.CourseId
join students as s
	on s.studentid = e.StudentId
group by s.Firstname, s.Lastname
order by course_count desc
)
select
	FirstName,
    LastName,
    course_count
from students_with_maximum_numbers_of_courses
where course_count = 3;



-- Query-15) List the first name and last name of students who are enrolled in more courses than 'Alice Smith'.
with courses_taken_by_alice as
(
select 
	s.studentId,
	s.firstname,
    s.lastname,
    count(e.courseid) as course_taken_by_alice 
from students as s
join enrollments as e
	on s.studentId = e.studentId
where s.firstname like 'Alice' and s.lastname like 'Smith'
group by s.firstname, s.lastname, s.studentid
), course_taken_by_other_student as
(
select
	s.studentid,
    s.firstname,
    s.lastname,
    count(e.courseid) as course_taken_by_other_students
from students as s
left join enrollments as e	
	on s.studentid = e.studentId
where not (s.firstname = 'Alice' and s.lastname = 'Smith')
group by s.studentId, s.firstname, s.lastname
)
select 
	cto.firstname,
    cto.lastname
from course_taken_by_other_student as cto, courses_taken_by_alice as cta
where cta.course_taken_by_alice < cto.course_taken_by_other_students;
