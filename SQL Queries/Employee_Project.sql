-- Database and table creation.
create database interview_prep;
use interview_prep;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT,
    hire_date DATE,
    salary DECIMAL(10, 2),
    email VARCHAR(100)
);

INSERT INTO employees (employee_id, first_name, last_name, department_id, hire_date, salary, email) VALUES
(1, 'John', 'Doe', 1, '2020-03-15', 60000, 'john.doe@example.com'),
(2, 'Jane', 'Smith', 2, '2019-07-22', 75000, 'jane.smith@example.com'),
(3, 'Michael', 'Johnson', 1, '2018-09-12', 80000, 'michael.johnson@example.com'),
(4, 'Emily', 'Davis', 3, '2021-01-30', 55000, 'emily.davis@example.com'),
(5, 'David', 'Martinez', 2, '2022-02-10', 65000, 'david.martinez@example.com'),
(6, 'Sarah', 'Wilson', 3, '2017-04-25', 70000, 'sarah.wilson@example.com'),
(7, 'Daniel', 'Taylor', 2, '2023-06-05', 72000, 'daniel.taylor@example.com'),
(8, 'John', 'Doe', 1, '2020-03-15', 60000, 'john.doe@example.com'),  -- Duplicate entry for John Doe
(9, 'Anna', 'Brown', 4, '2022-11-10', 85000, 'anna.brown@example.com'),
(10, 'Olivia', 'Lee', 2, '2021-04-20', 74000, 'olivia.lee@example.com'),
(11, 'Sophia', 'Clark', 3, '2020-01-05', 68000, 'sophia.clark@example.com'),
(12, 'Liam', 'Walker', 2, '2018-05-11', 71000, 'liam.walker@example.com'),
(13, 'Ethan', 'Allen', 1, '2020-09-13', 75000, 'ethan.allen@example.com'),
(14, 'Mason', 'Scott', 3, '2021-08-14', 60000, 'mason.scott@example.com'),
(15, 'Isabella', 'Adams', 1, '2021-06-30', 67000, 'isabella.adams@example.com'),
(16, 'James', 'Harris', 2, '2022-03-22', 76000, 'james.harris@example.com'),
(17, 'Charlotte', 'Nelson', 4, '2020-12-14', 81000, 'charlotte.nelson@example.com'),
(18, 'Amelia', 'Carter', 3, '2019-10-25', 68000, 'amelia.carter@example.com');

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(15, 2),
    status VARCHAR(50)
);

INSERT INTO projects (project_id, project_name, start_date, end_date, budget, status) VALUES
(1, 'Project Alpha', '2022-03-01', '2023-03-01', 500000, 'Completed'),
(2, 'Project Beta', '2021-05-15', '2022-11-30', 750000, 'Completed'),
(3, 'Project Gamma', '2022-07-10', '2023-07-10', 1200000, 'In Progress'),
(4, 'Project Delta', '2023-01-01', '2023-12-31', 800000, 'In Progress'),
(5, 'Project Epsilon', '2020-06-01', '2021-12-01', 600000, 'Completed'),
(6, 'Project Zeta', '2022-04-20', '2023-04-20', 950000, 'In Progress'),
(7, 'Project Eta', '2022-09-01', '2023-09-01', 450000, 'Completed'),
(8, 'Project Theta', '2021-10-05', '2022-04-05', 550000, 'Completed'),
(9, 'Project Iota', '2023-02-15', '2024-02-15', 750000, 'In Progress'),
(10, 'Project Kappa', '2023-03-01', '2024-03-01', 600000, 'Planned'),
(11, 'Project Lambda', '2020-07-15', '2021-07-15', 300000, 'Completed'),
(12, 'Project Mu', '2021-08-01', '2022-08-01', 800000, 'Completed'),
(13, 'Project Nu', '2023-04-01', '2024-04-01', 700000, 'Planned'),
(14, 'Project Xi', '2022-12-15', '2023-12-15', 1000000, 'In Progress'),
(15, 'Project Omicron', '2021-01-10', '2021-07-10', 200000, 'Completed');


CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    role VARCHAR(50),
    assignment_date DATE,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

INSERT INTO employee_projects (employee_id, project_id, role, assignment_date) VALUES
(1, 1, 'Project Manager', '2022-03-01'),
(2, 2, 'Marketing Lead', '2021-05-15'),
(3, 3, 'HR Consultant', '2022-07-10'),
(4, 4, 'Project Coordinator', '2023-01-01'),
(5, 5, 'Finance Analyst', '2020-06-01'),
(6, 6, 'Senior Developer', '2022-04-20'),
(7, 7, 'Sales Representative', '2022-09-01'),
(8, 8, 'Data Analyst', '2021-10-05'),
(9, 9, 'Product Manager', '2023-02-15'),
(10, 10, 'Marketing Analyst', '2023-03-01'),
(11, 11, 'HR Manager', '2020-07-15'),
(12, 12, 'Software Engineer', '2021-08-01'),
(13, 13, 'Business Analyst', '2023-04-01'),
(14, 14, 'Team Lead', '2022-12-15'),
(15, 15, 'Project Assistant', '2021-01-10'),
(16, 1, 'Data Analyst', '2022-05-01');


select * from employees;
select * from projects;
select * from employee_projects;


use interview_prep;

-- --------------------------------------------------------- EASY -----------------------------------------------------------------------------

-- Query-1) Find all employees' first and last names from the employees table.
select 
	first_name,
    last_name
from employees;

-- Query-2) Retrieve the project names from the projects table.
select
	distinct project_name
from projects;


-- Query-3) List all employees who have the role of 'HR Consultant' in the employee_projects table.
select *
from employee_projects
where role = 'HR Consultant';

-- Query-4) Find the total number of projects in the projects table.
select
	count(project_id) as project_count
from projects;


-- Query-5) Get the names of all employees assigned to 'Project Beta'.
select
	e.first_name,
    e.last_name,
    p.project_name
from employees as e
join employee_projects as ep
on e.employee_id = ep.employee_id
join projects as p
on ep.project_id = p.project_id
where p.project_name = 'Project Beta';


-- ----------------------------------------------------------- MEDIUM --------------------------------------------------------------------------

-- Query-1) Find all employees who have worked on a project with a budget greater than $500,000.
select
	e.First_name,
    e.last_name,
    round(p.budget,0) as budget
from employees as e
join employee_projects as ep
on e.employee_id = ep.employee_id
join projects as p
on ep.project_id = p.project_id
where p.budget > '500000';

-- Query-2) Retrieve the project name, start date, and end date for all projects that are 'In Progress' from the projects table.
select
	Project_id,
    project_name,
    start_date,
    end_date,
    status
from projects
where status = 'In Progress';

-- Query-3) Get the number of employees working on each project from the employee_projects table.
select
	count(distinct employee_id) as employee_count,
    count(distinct project_id) as project_count
from employee_projects;

-- Query-4) Find the average budget of all projects in the projects table.
select 
	project_id,
    round(avg(budget),0)as average_budget
from projects
group by project_id;

-- Query-5) Find all employees who have been assigned to 'Project Alpha' and are not in the 'Project Manager' role.
select 
	e.employee_id,
    e.first_name,
    e.last_name,
    ep.role,
    p.project_name
from employees as e
join employee_projects as ep
on e.employee_id = ep.employee_id
join projects as p
on p.project_id = ep.project_id
where p.project_name = 'Project Alpha' 
and ep.role <> 'Project Manager';

-- Query-6) Get the total budget of all projects each employee has worked on.
select
	ep.employee_id,
    sum(p.budget) as total_budget,
    p.project_id
from employee_projects as ep
join projects as p
on ep.project_id = p.project_id
group by ep.employee_id, p.project_id;

-- Query-7) Find employees who have worked on 'In Progress' projects for more than 6 months.
select
	e.employee_id,
    e.first_name,
    e.last_name,
    p.project_id,
    p.start_date,
    datediff(p.end_date, p.start_date)/30.44 as duration_in_months,
    p.end_date,
    p.status 
from employees as e
join employee_projects as ep
on e.employee_id = ep.employee_id
join projects as p
on p.project_id = ep.project_id
where p.status = 'In Progress';




-- Query-8) Retrieve the project name and status for all projects with a budget of more than $800,000.
select
	project_name,
    status,
    round(budget,0) as budget
from projects
where budget > '800000';


-- ----------------------------------------------------------- HARD ------------------------------------------------------------------------

-- Query-1) Find the project(s) with the highest budget and the number of employees working on them.
select
	count(ep.employee_id) as employee_count,
    ep.project_id,
    round(max(p.budget),0) as budget_highest_to_lowest
from projects as p
join employee_projects as ep
on p.project_id = ep.project_id
group by ep.project_id
order by p.budget desc;



-- Query-2) Retrieve the list of employees who have worked on projects that started in 2022 and are still ongoing.
select
	e.employee_id,
    e.first_name,
    e.last_name,
    p.project_id,
    year(p.start_date) as start_year,
    year(p.end_date) as end_year,
    p.status
from employees as e
join employee_projects as ep
on e.employee_id = ep.employee_id
join projects as p
on p.project_id = ep.project_id
where p.status = 'In Progress'
and year(p.start_date) = 2022
and year(current_date());





-- Query-3) Find the total number of employees who have worked on completed projects in the last two years.
select 
	count(ep.employee_id) as employee_count,
    p.project_id,
    p.status,
    year(p.start_date) as start_year,
    year(p.end_date) as end_year,
    year(p.end_date) - year(p.start_date) as diff
from projects as p
join employee_projects as ep
on p.project_id = ep.project_id
where p.status = 'completed'
and year(p.end_date) - year(p.start_date) = 2
group by p.project_id, p.status, year(p.start_date), year(p.end_date);


-- Query-4) Find the total project budget for employees who have worked on projects with a budget greater than $700,000 and whose role is 'Project Manager'.
select
	ep.project_id,
    ep.employee_id,
    sum(p.budget) as total_budget,
    ep.role
from projects as p
join employee_projects as ep
on p.project_id = ep.project_id
where p.budget = 70000
and ep.role = 'Project Manager'
group by ep.project_id, ep.role, ep.employee_id;



