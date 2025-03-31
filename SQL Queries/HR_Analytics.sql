create database HR_Analytics;

use HR_Analytics;

-- Table Creation
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DepartmentID INT,
    JobTitle VARCHAR(100),
    Salary DECIMAL(10,2),
    HireDate DATE
);

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100),
    ManagerID INT
);

CREATE TABLE Salaries (
    SalaryID INT PRIMARY KEY,
    EmployeeID INT,
    SalaryAmount DECIMAL(10,2),
    Bonus DECIMAL(10,2),
    EffectiveDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY,
    EmployeeID INT,
    AttendanceDate DATE,
    Status VARCHAR(10),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE PerformanceReviews (
    ReviewID INT PRIMARY KEY,
    EmployeeID INT,
    ReviewDate DATE,
    PerformanceScore INT,
    Comments TEXT,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Insertion of Recrods

INSERT INTO Employees VALUES
(11, 'John', 'Doe', 102, 'Front-End Developer', 95000, '2022-06-15');

INSERT INTO Departments VALUES
(101, 'IT', 4),
(102, 'Data Science', 5),
(103, 'Human Resources', 7);

INSERT INTO Salaries VALUES
(1, 1, 85000, 5000, '2023-01-01'),
(2, 2, 75000, 4000, '2023-01-01'),
(3, 3, 85000, 5000, '2023-01-01'),
(4, 4, 90000, 6000, '2023-01-01'),
(5, 5, 95000, 7000, '2023-01-01'),
(6, 6, 85000, 5000, '2023-01-01'),
(7, 7, 60000, 3000, '2023-01-01'),
(8, 8, 85000, 5000, '2023-01-01'),
(9, 9, 75000, 4000, '2023-01-01'),
(10, 10, 50000, 2000, '2023-01-01');

INSERT INTO Attendance VALUES
(1, 1, '2024-03-01', 'Present'),
(2, 2, '2024-03-01', 'Absent'),
(3, 3, '2024-03-01', 'Present'),
(4, 4, '2024-03-01', 'Late'),
(5, 5, '2024-03-01', 'Present'),
(6, 6, '2024-03-01', 'Absent'),
(7, 7, '2024-03-01', 'Present'),
(8, 8, '2024-03-01', 'Present'),
(9, 9, '2024-03-01', 'Late'),
(10, 10, '2024-03-01', 'Absent');

INSERT INTO PerformanceReviews VALUES
(1, 1, '2023-12-10', 4, 'Great performance'),
(2, 2, '2023-12-15', 3, 'Needs improvement'),
(3, 3, '2023-12-20', 4, 'Good work'),
(4, 4, '2023-12-25', 5, 'Excellent leadership'),
(5, 5, '2023-12-30', 4, 'Strong technical skills'),
(6, 6, '2023-12-10', 4, 'Consistent performance'),
(7, 7, '2023-12-15', 3, 'Can improve in communication'),
(8, 8, '2023-12-20', 4, 'Good coding skills'),
(9, 9, '2023-12-25', 3, 'Average work'),
(10, 10, '2023-12-30', 2, 'Needs better teamwork');

-- ------------------------------------------------------- PART-1 (EASY) -----------------------------------------------------------------------

-- Query-1) Retrieve all employees with their department names.
select
	e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
from employees as e
join departments as d
	on e.departmentID = d.departmentID;


-- Query-2) Find all employees who were absent on '2024-03-01'.
select
	e.FirstName,
    e.LastName
from employees as e
join attendance as a
	on e.EmployeeID = a.EmployeeID
where a.AttendanceDate = '2024-03-01' and a.status = 'Absent';

-- Query-3) Count the number of employees in each department.
select 
	count(e.EmployeeID) as Employee_Count,
    d.DepartmentName
from employees as e
join departments as d
	on e.DepartmentId = d.DepartmentId
group by d.DepartmentName;


-- Query-4) Retrieve the top 3 highest-paid employees.
select 
	e.FirstName,
    e.lastName,
    s.SalaryAmount
from employees as e
join salaries as s
	on e.employeeId = s.employeeId
order by s.SalaryAmount DESC
limit 3;

-- Query-5) Find employees who have the same salary.
select
	salary,
    count(*) as salary_count
from employees
group by salary
having count(*) > 1;

-- Query-6) Retrieve the first and last names of all employees who work in the "IT" department.
select 
	e.FirstName,
    e.LastName,
    d.Departmentname
from Employees as e
join Departments as d
	on e.DepartmentID = d.DepartmentID
where d.DepartmentName = 'IT';

-- Query-7) List the names of employees who have received a performance score above 3.
select
	e.FirstName,
    e.LastName,
    pr.PerformanceScore
from employees as e
join performanceReviews as pr
	on e.EMployeeId = pr.EmployeeID
where pr.PerformanceScore > 3;

-- Query-8) Find the total number of employees in each department.
select
	d.DepartmentName,
	count(EmployeeId) as Employee_Count
from employees as e
join departments as d
on e.DepartmentID = d.DepartmentID
group by d.DepartmentName;

-- Query-9) Display the employee details who joined after January 1, 2022.
select
	FirstName,
    LastName,
    HireDate
from employees
where HireDate > '2022-01-01';

-- Query-10) Get a list of employees who were hired on any date in May 2021 and find the job title.
select *
from
(
select
	e.FirstName,
    e.LastName,
    date_format(e.HireDate, '%M-%Y') as updated_Date,
    e.JobTitle
from employees as e
) as date_format
where updated_date = 'May-2021';

-- ------------------------------------------------------- PART-2 (MEDIUM) -----------------------------------------------------------------------
-- Query-1) Find employees who earn above the department average salary.
select
	e.firstName,
    e.lastname,
    e.salary
from employees as e
where e.salary > 
(
	select
		avg(salary) as average_Salary
        from employees
);


-- Query-2) Find employees who received a bonus greater than 5000.
select
	e.firstname,
    e.lastname,
    s.bonus
from employees as e
join salaries as s
	on e.employeeId = s.EmployeeId
where s.bonus > 5000;

-- Query-3) Identify employees who have duplicate names.
select
	FirstName,
    LastName,
    count(*) as duplicates
from employees
group by FirstName, LastName
having count(*) > 1;

-- Query-4) Show all employees who have never been absent.
select 
	e.FirstName,
    e.LastName
from employees as e
left join attendance as a
	on e.EmployeeId = a.EmployeeId and a.status = 'Absent'
where a.EmployeeID is null;


-- Query-5) List employees who joined in the last 3 years.
select
	firstName,
    LastName,
    HireDate
from employees
where HireDate >= current_date() - interval 3 year;


-- Query-6) Get the employee with the highest performance score.
select
	e.FirstName,
    e.LastName,
    pr.PerformanceScore
from employees as e
join PerformanceReviews pr
	on e.EmployeeId = pr.EmployeeID
order by pr.PerformanceScore desc
limit 1;

-- Query-7) List employees with no performance reviews.
select
	e.FirstName,
    e.LastName
from employees as e
left join PerformanceReviews as pr
	on e.EmployeeId = pr.EmployeeId
where pr.employeeId is NULL;

-- Query-8) Calculate the total salary expense per department.
select
	d.DepartmentName,
    round(sum(SalaryAmount),0) as Total_Salary
from departments as d
join employees as e
	on d.DepartmentID = e.DepartmentID
join salaries as s
	on e.EmployeeId = s.EmployeeId
group by d.DepartmentName
order by Total_Salary desc;

-- Query-9)Find employees who received at least 2 performance reviews.
select 
	e.FirstName,
    e.LastName,
    count(pr.PerformanceScore) as PerformanceScore_Count
from employees as e
join PerformanceReviews as pr
on e.employeeID = pr.employeeID
group by e.FirstName, e.Lastname
having count(pr.PerformanceScore) >= 2;

-- Query-10) Get employees who have had salary changes over time.
select * from employees;
select * from departments;
select * from salaries;
select * from attendance;
select * from PerformanceReviews;

-- Query-11) Show employees who work in 'Data Science' and have a performance score above 3.
select 
	e.FirstName,
    e.LastName,
    d.DepartmentName,
    pr.PerformanceScore
from employees as e
join departments as d
	on e.DepartmentId = d.DepartmentID
join PerformanceReviews pr
	on e.EmployeeId = pr.EmployeeID
where d.DepartmentName = 'Data Science' and pr.PerformanceScore > 3;

-- Query-12) Find departments with more than 3 employees.
select
	d.DepartmentName,
    count(EmployeeID) as Employee_Count
from employees as e
join departments as d
	on e.DepartmentID = d.DepartmentID
group by d.DepartmentName
having count(*) > 3;

-- Query-13) Get employees who are in Data Science but are not data engineers.
select
	e.FirstName,
    e.LastName,
    e.JobTitle,
    d.DepartmentName
from employees as e
join departments as d
	on e.departmentId = d.departmentID
where d.DepartmentName = 'Data Science'
and JobTitle <> 'Data Engineer';

-- Query-14) Retrieve employee names and their respective department names.
select
	e.Firstname,
    e.lastName,
    d.departmentName
from employees as e
join departments as d
	on e.DepartmentId = d.DepartmentId;

-- Query-15) Find employees with a salary higher than the average salary in their department.
select
	e.FirstName,
    e.LastName,
	e.Salary,
    e.DepartmentID
from employees as e
where e.salary > 
(
	select
		avg(salary) as avg_saalry
    from employees
   where DepartmentId = e.DepartmentId
);

-- Query-16) List employees who received a bonus higher than 5% of their salary.
select * 
from
(
select
	e.FirstName,
    e.lastName,
    s.SalaryAmount,
    round(s.Bonus) as bonus,
    round(s.SalaryAmount * 0.05,0) as bonus_percentage
from employees as e
join salaries as s
	on e.EmployeeId = s.EmployeeID
) as bonus_calculator
where bonus > bonus_percentage;

-- Query-17) Display department names along with the total salary expense for each department.
select
	d.DepartmentName,
    round(sum(e.Salary),2) as total_salary
from departments as d
join employees as e
on d.DepartmentID = e.DepartmentId
group by d.DepartmentName;

-- Query-18) List employees who haven’t received a performance review in the last year.
select * from departments;
select * from employees;
select * from salaries;
select * from PerformanceReviews;
select * from attendance;

-- Query-19) Retrieve employees who have been consistently present in the past 30 days.
select
	e.FirstName,
    e.lastName
from attendance as a
join employees as e
	on a.EmployeeId = e.EmployeeID
where a.status = 'Present' 
and a.AttendanceDate >= current_date() - interval 30 day;


-- ------------------------------------------------------- PART-3 (HARD) -----------------------------------------------------------------------


-- Query-1) Find employees with the same first and last name.
select
	e.firstName,
    e.LastName,
    count(*) as DuplicateNames
from employees as e
group by e.firstName, e.lastname
having count(*) > 1;

-- Query-2) Find employees with the longest tenure.
select
	e.FirstName,
    e.lastName,
    e.HireDate,
    datediff(CURDate(), e.HireDate) as Tenure
from employees as e
order by Tenure desc
limit 1;


-- Query-3) Rank employees based on their salaries within each department.
select 
	e.FirstName,
    e.LastName,
    e.Salary,
    d.DepartmentName,
    rank() over (partition by d.DepartmentName order by e.Salary desc) as Salary_rank
from employees as e
join departments as d
on e.departmentId = d.DepartmentID;

-- Query-4) Get employees who were absent more than twice in the last 3 months.
select 
	e.FirstName,
    e.LastName,
    count(a.status) as absent_status
from employees as e
join attendance as a
on e.EmployeeID = a.EmployeeID
where a.status = 'Absent' 
	and a.AttendanceDate >= current_date() - interval 3 month
group by e.FirstName, e.LastName
having count(a.status) > 2;

-- Query-5) Identify departments where the average salary is below 75,000.
select *
from
(
select
	d.DepartmentName,
    round(avg(s.salaryamount),0) as average_salary
from employees as e
join departments as d
	on e.departmentID = d.departmentId
join salaries as s
	on s.EmployeeId = e.EmployeeID
group by d.DepartmentName
) as avg_salary
where average_salary < 75000;

-- Query-6) Rank employees based on their salary within each department.
select
	e.Firstname,
    e.lastName,
	RANK() over (partition by e.departmentID order by e.salary desc),
    e.salary,
    d.DepartmentName
from employees as e
join salaries as s
	on e.EmployeeID = s.EmployeeID
join departments as d
	on d.DepartmentID = e.DepartmentID;

-- Query-7) Identify employees with the top 3 highest bonuses in the company.
select
	e.FirstName,
    e.lastname,
    s.Bonus
from salaries as s
join employees as e
	on s.EmployeeID = e.EmployeeID
order by s.bonus desc
limit 3;
