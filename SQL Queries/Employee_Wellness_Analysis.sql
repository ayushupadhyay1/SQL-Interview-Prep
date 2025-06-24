use employee_engagement;

-- ====================================================== BEGINNER =========================================================================

-- Query-1) Write a query to categorize employees into 'Senior', 'Mid-level', or 'Junior' based on their years of experience using CASE.
select
	emp_id,
    emp_name,
    year(current_date()) - year(hire_Date) as Hire_Year,
    case
		when year(current_date()) - year(hire_Date) < 2 then 'Junior'
        when year(current_date()) - year(hire_Date) between 2 and 4 then 'Mid-Level'
        Else 'Senior'
    end as Employee_Position
from employees;


-- Query-2) Use CASE to return a new column called attendance_remark that says 'On Time', 'Remote', or 'No Show' based on status and check-in time.
select 
	*,
    case
		when status in ('Present', 'Remote') and check_in = '09:00:00' then 'On-Time'
        when status in ('Present', 'Remote') and check_in < '09:00:00' then 'Early'
        when status in ('Present', 'Remote') and check_in > '09:00:00' then 'Late'
        when check_in is NULL then 'No Show'
    end as Attendance_Remark
from Attendance;

-- Query-3) Find names of employees whose salary is greater than the average salary in their department.
select
	e.emp_id,
    e.emp_name,
    e.salary
from employees as e
where e.salary > (
					select
						avg(e1.salary)
                    from employees as e1
                    where e.dept_id = e1.dept_id
                    );

-- Query-4) List employees who have enrolled in the wellness program with the highest average feedback score.
select 
	e.emp_id,
    e.emp_name,
	ew.feedback_score 
from employees as e
join employee_wellness as ew
	on e.emp_id = ew.emp_id
where ew.program_id = (
	select
		program_id
    from employee_wellness
    group by program_id
    order by avg(feedback_score) desc
    limit 1
);
-- ====================================================== INTERMEDIATE =========================================================================

-- Query-5) Use a CTE to calculate each employee’s average check-in time for the first week of June 2025.
with average_checkin_time as
(
select
	e.emp_id,
    e.emp_name,
    a.check_in
from employees as e
join attendance as a
	on e.emp_id = a.emp_id
where a.date between '2025-06-01' and '2025-06-07'
)
select
	emp_id,
    emp_name,
    sec_to_time(round(avg(time_to_sec(check_in)))) as average_check_in_time
from average_checkin_time
group by emp_id, emp_name;


-- Query-6) Write a CTE to list departments with more than one employee enrolled in wellness programs.
with department_employee_wellness as
(
select 	
    d.dept_id,
    d.dept_name,
    count(ew.emp_id) as Registed_employee_count
from employees as e
join Departments as d
	on e.dept_id = d.dept_id
join employee_wellness as ew
	on ew.emp_id = e.emp_id
group by  d.dept_id, d.dept_name
)
select
	dept_id,
    dept_name,
    Registed_employee_count
from department_employee_wellness
where Registed_employee_count > 1;

-- Query-7) For each employee, show their salary and the average salary in their department using a window function.
with employee_attandance as
(
select 
	e.emp_id,
    e.emp_name,
    d.dept_id,
    d.dept_name,
    salary
from Departments as d
join employees as e
	on d.dept_id = e.dept_id
)
select 
	emp_id,
    emp_name,
    dept_name,
    salary,
    round(avg(salary) over (partition by dept_id),2) as average_department_salary
from employee_attandance;
    
-- Query-8) Rank employees by feedback score within each wellness program.
select 
	e.emp_id,
    e.emp_name,
	wp.program_name,
    ew.feedback_score,
    rank() over (partition by ew.program_id order by ew.feedback_score desc) as RNK
from employees as e
join employee_wellness as ew
	on e.emp_id = ew.emp_id
join Wellness_Programs as wp
	on wp.program_id = ew.program_id;
    

-- Query-9) Identify employees who have never participated in any wellness program.
select 
	e.emp_id,
    e.emp_name
from employees as e
left join employee_wellness as ew
	on e.emp_id = ew.emp_id
where ew.emp_id is NULL;

-- Query-10) Find employees who attended a mental wellness program but not any physical program.
SELECT 
    e.emp_id,
    e.emp_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM employee_wellness ew
    JOIN wellness_programs wp ON ew.program_id = wp.program_id
    WHERE ew.emp_id = e.emp_id
      AND wp.category = 'Mental'
)
AND NOT EXISTS (
    SELECT 1
    FROM employee_wellness ew
    JOIN wellness_programs wp ON ew.program_id = wp.program_id
    WHERE ew.emp_id = e.emp_id
      AND wp.category = 'Physical'
);

-- ====================================================== ADVANCED ===============================================================

-- Query-11) For each department, list employees and classify them as 'Top Earner', 'Average', or 'Low Earner' using CASE and RANK().
with ranked_employee as 
(
select 
	e.emp_id,
    e.emp_name,
    d.dept_name,
    salary,
    rank() over (partition by d.dept_id order by salary desc) as RNK,
	count(*) over (partition by d.dept_id) as dept_size
from employees as e 
join departments as d
	on e.dept_id = d.dept_id
)
select
	emp_id,
    emp_name,
    dept_name,
    salary,
    RNK,
    case
		when RNK = 1 then 'Top Earner'
        when RNK = dept_size then 'Low Earner'
        else 'Average Earner'
    end as salary_clssification
from ranked_employee;



-- Query-12) Write a query that shows employees' engagement level based on the number of wellness programs attended and average feedback score, classified as 'High', 'Medium', 'Low'.
select 
	e.emp_id,
    e.emp_name,
    count(ew.program_id) as Joined_Program,
    round(avg(ew.feedback_score),2) as average_feedback_score,
    case
		when count(ew.program_id) > 1 and round(avg(ew.feedback_score),2) >= 7.5 then 'High Engagement with Good Score'
        when count(ew.program_id) > 1 and round(avg(ew.feedback_score),2) < 7.5 then 'High Engagement with average Score'
        when count(ew.program_id) = 1 and round(avg(ew.feedback_score),2) >= 7.5 then 'Low Engagement with Good Score'
        when count(ew.program_id) = 1 and round(avg(ew.feedback_score),2) < 7.5 then 'Low Engagement with average Score'
        else 'No Engagement'
    end as employee_performance
from employees as e
left join employee_wellness as ew
	on e.emp_id = ew.emp_id
group by e.emp_id, e.emp_name;

-- Query-13) Create a view named active_wellness_participants showing employee name, department, total programs joined, and average feedback score.
create or replace view active_wellness_participants as
(
select 
	e.emp_name,
    d.dept_name,
    count(ew.program_id) as total_program,
    round(avg(feedback_score),2) as average_feedback_score
from employees as e
join departments as d
	on e.dept_id = d.dept_id
join employee_wellness as ew
	on ew.emp_id = e.emp_id
group by e.emp_name, d.dept_name
);

select * from active_wellness_participants;

-- Query-14) Create a view to track daily remote attendance count by department.
create or replace view remote_attendance as
(
select 	
	a.date as attendance_date,
	d.dept_name,
    count(e.emp_id) as remote_employee_count
from employees as e
join departments as d
	on e.dept_id = d.dept_id
join attendance as a
	on a.emp_id = e.emp_id
where a.status = 'Remote'
group by a.date, d.dept_name
);

select * from remote_attendance;

-- Query-15) Find the name of the department with the highest average wellness feedback score.
select 
	d.dept_id,
    d.dept_name,
    round(avg(ew.feedback_score),2) as average_feedbackscore
from departments as d
join employees as e
	on d.dept_id = e.dept_id
join employee_wellness as ew
	on ew.emp_id = e.emp_id
group by d.dept_id, d.dept_name
order by average_feedbackscore desc
limit 1;


