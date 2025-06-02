use EmployeeProjectAssesment;

-- =================================================== DATA DUPLICATION & DELETION ===========================================================

-- Query-1) Write a SQL query to identify all duplicate rows in the Tasks table based on ProjectID, TaskName, AssignedToEmployeeID, and DueDate. Your result should show the TaskID of the duplicate entries.
select
	taskId
from Tasks
where (ProjectId, Taskname, AssignedToEmployeeID, DueDate) IN (
		select ProjectId, Taskname, AssignedToEmployeeID, DueDate
        from Tasks
        group by ProjectId, Taskname, AssignedToEmployeeID, DueDate
        having count(*) > 1);

-- Query-2) Remove Duplicates (Tasks): Write a SQL query to delete all duplicate rows from the Tasks table, keeping only one instance of each unique task (based on ProjectID, TaskName, AssignedToEmployeeID, and DueDate).
with duplicate_date as
(
select
	TaskID,
    row_number() over (partition by ProjectId, Taskname, AssignedToEmployeeID, DueDate order by taskID) as RNK
from Tasks
)
delete	
from tasks
where TaskID in (select taskid from duplicate_date where RNK > 1);


-- =================================================== Advanced Window Functions ===========================================================
-- Query-3) Employee Salary Rank: For each department, list employees along with their Salary, and their rank within that department based on Salary (highest salary gets rank 1). Handle ties by assigning the same rank.
with cte as
(
select
	employeeid,
    Firstname,
    Lastname,
    Department,
    salary,
    rank() over (partition by department order by salary desc) as RNK
from employees
)
select
    Firstname,
    Lastname,
    Department,
    salary,
    RNK
from cte;

-- Query-4) Task Completion Time: For each ProjectID, calculate the average number of days it took to complete a task (CompletionDate - DueDate). If a task isn't completed, exclude it from the average.
select
	ProjectId,
    avg(datediff(CompletionDate, duedate )) as average_task_completion_time
from Tasks
where completiondate is NOT NULL
group by projectId;

-- Query-5) Departmental Salary Comparison: For each employee, show their FirstName, LastName, Department, Salary, and the average salary of their department.
select
	FirstName,
    lastName,
    Department,
    salary,
    round(avg(salary) over (partition by department),2) as Average_Department_Salary
from employees;

-- Query-6) Previous Task Completion Date: For each task, show the TaskID, TaskName, ProjectID, and the CompletionDate of the previous task completed within the same ProjectID, ordered by DueDate.If it's the first completed task, show NULL.
select
	TaskId, 
    TaskName,
    ProjectId,
    completionDate,
    lag(completionDate) over (partition by projectId order by DueDate) as Past_Task_Completion_Date
from tasks
order by taskID;

-- Query-7) Running Total of Project Budget: For each project, list the ProjectID, ProjectName, Budget, and a running total of the Budget for all projects started on or before that project's StartDate, ordered by StartDate.
select
	projectId,
    ProjectName,
    budget,
    sum(Budget) over (order by startDate, ProjectId) as running_budget
from projects;

-- Query-8) N-Tile Distribution of Salaries: Divide all employees into 4 salary groups (quartiles) and display which quartile each employee belongs to.
select
	EmployeeId,
    FirstName,
    LastName,
    Department,
    Salary,
    NTILE(4) over (order by salary desc) as Salary_distribution
from employees;


-- ============================================================= CTE's ======================================================================

-- Query-9) High-Priority Task Assignments: Using a CTE, find the FirstName and LastName of all employees who are assigned to at least two 'High' priority tasks.
with high_priority_tasks as
(
select 
	e.FirstName,
    e.Lastname,
    count(t.Priority) as priority_count
from Employees as e
join EmployeeProjectAssignments as ep
	on e.employeeId = ep.EmployeeId
join Tasks as t
	on t.ProjectId = ep.ProjectID
where t.priority = 'High'
group by e.firstname, e.lastname
)
select
	FirstName,
    Lastname,
    priority_count
from high_priority_tasks
where priority_count >= 2;

-- Query-10) Unassigned Planned Projects: Using a CTE, list the ProjectName and Budget of all 'Planned' projects that currently have no tasks assigned to them in the Tasks table
with Unassigned_Projects as
(
select 
	p.ProjectId,
    p.ProjectName,
    p.Budget
from Projects as p
left join Tasks as t
	on p.projectId = t.ProjectId
where t.projectID is NULL and p.status = 'Planned'
)
select 
	ProjectId,
    ProjectName,
    Budget
from Unassigned_Projects;
    
-- Query-11) Departmental Top Earners and Their Tasks: Using a CTE, find the top 2 highest-paid employees in each Department. Then, join this result with the Tasks table to show all tasks assigned to these top earners.
with top_earners as 
(
select 
	distinct e.employeeId,
    e.FirstName,
    e.Lastname,
    e.Department,
    e.salary,
    dense_rank() over (partition by e.department order by e.salary desc) as Salary_rank
from Employees as e
)
select
	te.employeeId,
    te.FirstName,
    te.Lastname,
    te.Department,
    te.salary,
    te.Salary_rank,
    t.Taskname,
    t.projectId,
    t.duedate
from top_earners as te
left join tasks as t
	on te.employeeId = t.AssignedToEmployeeID
where Salary_rank <= 2;


-- Query-12) Project Performance Summary: Create a CTE that calculates for each project: the total number of tasks, the number of completed tasks, and the number of pending tasks. Then, query this CTE to show projects with less than 50% completion rate.

with project_task_summary as
(
select 
	p.projectID,
    count(t.taskId) as total_tasks,
    sum(case when t.CompletionDate is NOT NULL then 1 else 0 end) as compled_task,
    sum(case when t.CompletionDate is NULL then 1 else 0 end) as pending_task
from projects as p
join tasks as t
	on p.projectID = t.projectID
group by p.projectId
)
select
	ProjectID,
    total_tasks,
    compled_task,
    pending_task,
    round((compled_task/total_tasks) * 100,2) as completion_rate_percentage
from project_task_summary
where (compled_task/total_tasks) < 0.5;

-- Query-13) Employee Project Load: Use a CTE to calculate the total number of projects each employee is assigned to. Then, list employees who are assigned to more than 1 projects.
with employee_project_count as
(
select 
	e.employeeId,
    e.FirstName,
    e.LastName,
    count(ep.projectID) Number_of_projects_assigned
from Employees as e
join EmployeeProjectAssignments as ep
	on e.employeeId = ep.employeeId
group by e.employeeId, e.FirstName, e.LastName
)
select
	employeeId,
    FirstName,
    LastName,
    Number_of_projects_assigned
from employee_project_count
where Number_of_projects_assigned > 1
order by employeeId;


-- ============================================================= Advanced Aggregation ======================================================================
-- Query-14) Departmental Salary Breakdown: Get the Department, SUM(Salary), AVG(Salary), MIN(Salary), and MAX(Salary) for all employees.
select
    Department,
    sum(salary) as total_salary,
    round(avg(salary),2) as average_salary,
    min(salary) as minimum_salary,
    max(salary) as maximum_salary
from employees 
group by department
order by total_salary desc;


-- Query-15) Project Status and Budget Summary: For each project Status, calculate the total Budget and the count of projects. Include a row that shows the total budget for all projects combined, regardless of status (using ROLLUP or GROUPING SETS).
select
	COALESCE(status,'total')
	status,
    sum(budget) as total_budget,
    count(projectId) as Project_Count
from projects 
group by rollup(status)
order by total_budget;



-- Query-16) Priority-wise Task Count per Project: 
-- For each ProjectID, show the count of tasks for each Priority ('High', 'Medium', 'Low'). If a project has no tasks of a certain priority, it should show 0 for that priority. (Consider using PIVOT or CASE with SUM).
select 
	p.projectId,
	sum(case when t.priority = 'high' then 1 else 0 end) as High_Count,
    sum(case when t.priority = 'medium' then 1 else 0 end) as Medium_Count,
    sum(case when t.priority = 'Low' then 1 else 0 end) as Low_Count
from projects as p
left join tasks as t
	on p.projectid = t.projectid
group by p.projectid;

-- Query-17) Average Time to Completion by Priority: Calculate the average number of days it took to complete tasks, broken down by Priority.
select
	Priority,
    round(avg(datediff(completiondate, duedate)),2) as Average_number_of_Days
from tasks
where completiondate is NOT NULL
group by priority
order by priority;


-- Query-18) Employees with Above-Average Department Salary: Find the FirstName, LastName, and Salary of employees whose salary is greater than the average salary of their respective department.
select
	e.Firstname,
    e.Lastname,
    e.Salary
from employees as e
where e.salary > (
					select
						avg(e1.salary)
                    from employees as e1
                    where e1.department = e.department
                    );



 -- ============================================================= CASE STATEMENT ======================================================================
-- Query-19) Employee Salary Category: List all employees with their FirstName, LastName, Department, Salary, and a new column named SalaryCategory. SalaryCategory should be 'High Earner' (if Salary > 85000), 'Mid-Range Earner' (if Salary >= 70000 and <= 85000), or 'Entry-Level Earner' (if Salary < 70000).
select
	Firstname,
    LastName,
    Department,
    Salary,
    case
		when salary > 85000 then 'High Earner'
        when salary >= 70000 and salary <= 85000 then 'Mid-Range Earner'
        when salary < 70000 then 'Entry-Level Earner'
	End as SalaryCategory
from employees;


-- Query-20) Task Status Indicator: For each task, show the TaskID, TaskName, DueDate, CompletionDate, and a TaskStatus column. TaskStatus should be 'Overdue' if DueDate is in the past and CompletionDate is NULL, 'Completed' if CompletionDate is not NULL, and 'Pending' otherwise.
select
	TaskId,
    TaskName,
    DueDate,
    CompletionDate,
    case
		when completiondate is NULL and Duedate < current_Date then 'Overdue'
        when completiondate is NOT NULL then 'Completed'
        else 'Pending'
    end as TaskStatus
from tasks;

-- Query-21) Project Budget Classification: For each project, list the ProjectName, Budget, and a BudgetClass column. BudgetClass should be 'Mega Project' (if Budget > 700000), 'Large Project' (if Budget between 400000 and 700000 inclusive), or 'Standard Project' (if Budget < 400000).
select
	ProjectName,
    Budget,
    case
		when budget > 700000 then 'Mega Project'
        when budget between 400000 and 700000 then 'Large Project'
        when budget < 400000 then 'Standard Project'
    end as BudgetClass
from projects;

-- Query-22) Employee Seniority Level: Based on HireDate, categorize employees as 'Veteran' (hired before 2020), 'Experienced' (hired in 2020 or 2021), or 'New Hire' (hired after 2021).
select	
	EmployeeId,
    FirstName,
    Lastname,
    Hiredate,
    case
		when year(hiredate) < 2020 then 'veteran'
        when year(hiredate) = 2020 or year(hiredate) = 2021 then 'Experienced'
        when year(hiredate) > 2021 then 'New Hire'
    end as Employee_Seniority_Level
from employees;


-- Query-23) Dynamic Role Description: In the EmployeeProjectAssignments table, display the Role as is, but if the Role is 'Developer' and the ProjectID is 101, display it as 'Core Developer'.
select
    case
		when role = 'Developer' and ProjectID = 101 then 'Core Developer'
        else role
    end as Dynamic_role
from EmployeeProjectAssignments;

