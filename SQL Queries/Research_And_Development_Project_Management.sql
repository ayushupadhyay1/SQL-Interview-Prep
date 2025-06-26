use Research_And_Development_Project_Management;

-- ------------------------------------------- Window Functions & CTS's ----------------------------------------------------------

-- Query-1) Rank all employees by their salary within each department. If two employees in the same department have the same salary, they should have the same rank, and the next rank should be skipped.
with employees_and_salary as
(
select 
	e.EmployeeId,
    e.FirstName,
    e.lastName,
    d.Departmentname,
    e.Salary	
from employee as e
join departments as d
	on e.departmentId = d.departmentid
)
select 
	EmployeeId,
    FirstName,
    lastName,
    Departmentname,
    Salary,
    rank() over (partition by Departmentname order by Salary desc) as RNK
from employees_and_salary;

-- Query-2) Calculate the running total of EventCost for each ProjectID, ordered by EventDate
select
	ProjectId,
    EventCost,
    sum(EventCost) over (Partition by ProjectId order by EventDate) as Running_Total
from ProjectEvents;

-- Query-3) Find the average ProjectBudget for projects in the same Department that started within the last 6 months of a given project. 
-- (This requires a self-join with a window function or a CTE).


-- Query-4) Identify the top 3 Employees who have worked on the most unique Projects.
select 
	E.EmployeeId,
    E.Firstname,
    E.Lastname,
    count(distinct p.ProjectID) as Number_of_Unique_Projects
from Employee as e
join Projects as p
	on e.EmployeeId = p.ProjectManagerId
group by E.EmployeeId, E.firstname, E.LastName
order by Number_of_Unique_Projects desc
limit 3;

-- Query-5) For each Equipment item, find its MaintenanceDate and the MaintenanceDate of the previous maintenance performed on that same equipment. Handle cases where there's no previous maintenance.
select 
	e.EquipmentId,
    e.equipmentname,
    em.MaintenanceDate,
    Lag(em.MaintenanceDate) over (partition by e.EquipmentId order by em.MaintenanceDate) as Previous_Maintenance_date
from equipment as e
join EquipmentMaintenance em
	on e.EquipmentId = em.equipmentId;


-- Query-6) Calculate the difference in ProjectBudget between each project and the project with the highest budget in the same Department.
with project_budget_difference as
(
select 
	p.projectId,
    p.ProjectName,
    d.Departmentname,
    d.departmentId,
    p.projectbudget
from projects as p
join departments as d
	on p.departmentid = d.departmentid
), Maximum_project_per_department as 
(
select
	p1.projectId,
    p1.ProjectName,
    d1.Departmentname,
    p1.projectbudget,
    Max(p1.projectbudget) over (partition by d1.departmentId) as Maximum_project_budget
    from projects as p1
	join departments as d1
	on p1.departmentid = d1.departmentid
)
select 
	pbd.ProjectId,
    pbd.ProjectName,
    mpd.DepartmentName,
    mpd.projectbudget,
    mpd.Maximum_project_budget,
    mpd.Maximum_project_budget - mpd.projectbudget as Project_budget_difference
from project_budget_difference as pbd
join Maximum_project_per_department as mpd
	on pbd.projectId = mpd.projectId;
    
-- ------------------------------------------- Subqueries & Joins ----------------------------------------------------------
-- Query-7) Find all Departments that have at least one Project with a Status of 'Overdue' 
-- and at least one Project with a Status of 'Completed'.
select 
	d.departmentId,
    d.departmentname,
    p.status
from departments as d
join projects as p
	on d.departmentId = p.departmentId
where p.status = 'overdue' and p.status = 'completed';

-- Query-8) List all Employees who are not assigned to any Project.
select 
	e.EmployeeId,
    e.FirstName,
    e.Lastname
from employee as e
left join projects as p
	on e.employeeId = p.ProjectManagerId
where p.ProjectManagerId is NULL;

-- Query-9) Retrieve Project details for projects where all Equipment assigned to them has a MaintenanceDate in the current year. 
select 
	p.projectId,
    p.ProjectName,
    p.StartDate,
    p.EndDate,
    P.Projectbudget
from projects as p
join ProjectEquipment as pe
	on p.projectID = pe.ProjectId
join EquipmentMaintenance as em
	on em.EquipmentID = pe.EquipmentID
where em.MaintenanceDate is NOT NULL;


-- Query-10) Find the ProjectManagerID who manages the most Projects that have a total EventCost exceeding $10,000.
select
	p.ProjectManagerId,
	count(p.projectID) as Project_Count
from projects as p
join ProjectEvents as pe
	on p.ProjectId = pe.ProjectID
where pe.EventCost > 10000
group by p.projectManagerId, pe.eventcost
limit 1;

WITH ProjectTotalCost AS (
  SELECT
    p.ProjectId,
    p.ProjectManagerId,
    SUM(pe.EventCost) AS TotalEventCost
  FROM projects AS p
  JOIN ProjectEvents AS pe
    ON p.ProjectId = pe.ProjectID
  GROUP BY p.ProjectId, p.ProjectManagerId
),
FilteredProjects AS (
  SELECT *
  FROM ProjectTotalCost
  WHERE TotalEventCost > 10000
)
SELECT 
  ProjectManagerId,
  COUNT(ProjectId) AS Projects_Over_10k
FROM FilteredProjects
GROUP BY ProjectManagerId
ORDER BY Projects_Over_10k DESC
LIMIT 1;
