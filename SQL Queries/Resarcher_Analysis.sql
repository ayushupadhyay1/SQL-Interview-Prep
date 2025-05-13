create database research_management_system;
use research_management_system;

CREATE TABLE Researchers (
    researcher_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100),
    joining_date DATE
);

CREATE TABLE Projects (
    project_id INT PRIMARY KEY,
    title VARCHAR(200),
    lead_researcher_id INT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (lead_researcher_id) REFERENCES Researchers(researcher_id)
);

CREATE TABLE Publications (
    publication_id INT PRIMARY KEY,
    project_id INT,
    title VARCHAR(200),
    published_date DATE,
    journal VARCHAR(100),
    impact_factor DECIMAL(3,2),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

CREATE TABLE Project_Funding (
    funding_id INT PRIMARY KEY,
    project_id INT,
    funding_agency VARCHAR(100),
    amount DECIMAL(10,2),
    awarded_date DATE,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);


-- Researchers
INSERT INTO Researchers VALUES
(1, 'Dr. Alice Monroe', 'Biotech', '2015-08-01'),
(2, 'Dr. John Carter', 'AI & Robotics', '2017-01-15'),
(3, 'Dr. Lina Zhang', 'Physics', '2012-09-10'),
(4, 'Dr. Omar Farooq', 'Environmental Science', '2018-04-22'),
(5, 'Dr. Emma Stone', 'Cybersecurity', '2020-03-30');

-- Projects
INSERT INTO Projects VALUES
(101, 'Gene Editing in Plants', 1, '2019-01-01', '2021-06-30'),
(102, 'Autonomous Drone Navigation', 2, '2020-05-01', NULL),
(103, 'Quantum Computing Models', 3, '2018-03-01', '2022-08-15'),
(104, 'Urban Air Quality Monitoring', 4, '2021-01-01', NULL),
(105, 'Secure IoT Devices', 5, '2020-09-15', '2023-02-28'),
(106, 'Bio-Plastic Degradation', 4, '2022-05-01', NULL);

-- Publications
INSERT INTO Publications VALUES
(201, 101, 'CRISPR Use in Agriculture', '2020-02-15', 'Nature Biotech', 9.5),
(202, 101, 'Plant Gene Sequencing Tools', '2021-01-10', 'Science', 8.9),
(203, 102, 'Real-Time Obstacle Avoidance', '2022-03-05', 'IEEE Robotics', 7.2),
(204, 103, 'Entanglement in Qubits', '2019-11-11', 'Quantum Journal', 6.8),
(205, 105, 'IoT Threat Detection', '2021-07-07', 'CyberSec Today', 5.5),
(206, 105, 'Secure Communication Protocols', '2022-09-20', 'Infosec Weekly', 6.0),
(207, 104, 'CO2 Sensor Networks', '2022-06-15', 'Enviro Tech', 5.1),
(208, 106, 'Plastic Degradation Enzymes', '2023-05-10', 'Eco Science', 4.8);

-- Project_Funding
INSERT INTO Project_Funding VALUES
(301, 101, 'NSF', 250000.00, '2019-02-01'),
(302, 102, 'DARPA', 400000.00, '2020-05-20'),
(303, 103, 'DOE', 300000.00, '2018-04-10'),
(304, 104, 'EPA', 200000.00, '2021-02-01'),
(305, 105, 'NSF', 150000.00, '2020-10-10'),
(306, 106, 'UNEP', 100000.00, '2022-06-01'),
(307, 102, 'NASA', 150000.00, '2021-08-20'),
(308, 101, 'AgriTech Fund', 120000.00, '2020-01-15'),
(309, 103, 'Quantum Alliance', 180000.00, '2019-05-15');

-- Query-1) Find the researcher(s) who have led more than one project that received funding from more than one agency.
with agent_count as
(
select
	p.project_id,
    p.lead_researcher_id,
	count(distinct pf.funding_agency) as agency_count
from Projects as p
join Project_funding as pf
	on p.project_id = pf.project_id
group by p.project_id, p.lead_researcher_id
), 
project_count as
(
select
	lead_researcher_id
from agenct_count
where  agency_count > 1
group by lead_researcher_id
having count(project_id) > 1
)
select
	r.researcher_id,
	r.name
from project_count as pc
join Researchers as r
	on pc.lead_researcher_id = r.researcher_id;

-- Query-2) Retrieve the average impact factor of publications per department, ordered by highest average.
select 
	r.department as Research_Department,
    round(avg(pub.impact_factor),2) as average_impact_factor
from Researchers as r
join projects as p
	on r.researcher_id = p.lead_researcher_id
join publications as pub
	on p.project_id = pub.project_id
group by r.department
order by average_impact_factor desc;

-- Query-3) List all projects that have no publications yet.
select
	p.project_id, 
    p.title
from projects as p
left join publications as pub
	on p.project_id = pub.project_id
where pub.project_id is NULL;

-- Query-4) Get the top 3 researchers based on the total number of publications from their projects.
select 
	r.researcher_id,
    r.name,
    count(pub.publication_id) as publication_count
from researchers as r
join projects as p
	on r.researcher_id = p.lead_researcher_id 
join publications as pub
	on p.project_id = pub.project_id
group by r.researcher_id, r.name
order by publication_count desc
limit 3;                        

-- Query-5) Show total funding amount grouped by department and ordered by highest total.
select
	r.department,
	sum(pf.amount) as Total_Funding_Amount
from Project_Funding as pf
join projects as p
	on pf.project_id = p.project_id
join researchers as r
	on r.researcher_id = p.lead_researcher_id
group by r.department
order by Total_Funding_Amount DESC;
    
-- Query-6) Identify researchers who started before 2021 and still have active projects.
select 
	r.researcher_id,
	r.name
from projects as p
join researchers as r
	on p.lead_researcher_id = r.researcher_id
where  p.start_date < '2021-01-01' and p.end_Date is NULL;

-- Query-7) Retrieve the title and journal of the highest impact factor publication per project.
select 
	p.title,
    pub.journal,
    pub.impact_factor
from Projects as p
join Publications as pub
	on p.project_id = pub.project_id
where pub.impact_factor = (
	select max(impact_factor) 
    from publications
    where project_id = pub.project_id
)
order by pub.impact_factor;

-- Query-8) List researchers who have not received any funding on their projects.
select 
	r.researcher_id,
    r.name,
    p.title
from researchers as r
join projects as p
	on r.researcher_id = p.lead_researcher_id
left join project_funding as pf
	on pf.project_id = p.project_id
where pf.project_id is NULL;
    

-- Query-9) Find the average duration of completed projects by department.
with project_duration as
(
select 
	p.Project_id,
	p.title,
    r.department,
    p.start_Date,
    p.end_Date,
    datediff( p.end_date, p.start_date) as days_
from projects as p
join researchers as r
	on p.lead_researcher_id = r.researcher_id
where p.end_date is Not NUll
)
select
    department,
    round(avg(days_),2) as average_Days
from project_duration
group by department
order by average_Days;


-- Query-10) For each researcher, show the count of publications from their projects published after 2020.
select 
	r.researcher_id,
    r.name,
    count(publication_id) as publication_count
from researchers as r
join projects as p
	on r.researcher_id = p.lead_researcher_id
join publications as pub
	on pub.project_id = p.project_id
where pub.published_date > '2020-12-31'
group by r.researcher_id, r.name
order by researcher_id;

-- Query-11) Identify any projects that have funding gaps of more than one year between funding rounds.
select *
from 
(
select 
	p.project_id,
    p.title,
	min(pf.awarded_Date) as first_funding_round,
    max(pf.awarded_Date) as second_funding_round,
    datediff(max(pf.awarded_Date), min(pf.awarded_Date)) as days_difference_between_funding_rounds
from projects as p
join project_funding as pf
	on p.project_id = pf.project_id
group by p.project_id, p.title
having count(pf.funding_id) > 1
) as duration_between_funding_rounds
where days_difference_between_funding_rounds > 365;



-- Query-12) For each project, show the cumulative funding received over time, ordered chronologically.
select 
	p.project_id,
    p.title,
    pf.amount,
    sum(pf.amount) over (partition by p.project_id order by pf.awarded_Date) as cumulative_funding
from projects as p
join project_funding as pf
	on p.project_id = pf.project_id
order by p.project_id, pf.awarded_Date;

-- Query-13) For each department, retrieve the currently active project (i.e., end_date IS NULL) that has received the highest total funding.
with highest_funded_projects as
(
select 
	r.department,
    p.project_id,
    p.title,
    sum(pf.amount) as Highest_Total_Funding,
    row_number() over (partition by r.department order by sum(pf.amount) desc) as RNK
from Researchers as r
join Projects as p
	on r.researcher_id = p.lead_researcher_id
join project_Funding as pf
	on pf.project_id = p.project_id
where p.end_date is NULL
group by r.department, p.title, p.project_id
)
select
	department,
    title,
    Highest_Total_Funding
from highest_funded_projects
where RNK = 1;

-- Query-14) For each year, find the researcher whose project(s) yielded the publication with the highest impact factor that year.
with Researchers_with_highest_impact_factor as
(
select 
	r.researcher_id,
    r.name,
    p.title,
    year(pub.published_date) as year_,
    pub.impact_factor,
    row_number() over (partition by  year(pub.published_date) order by pub.impact_factor desc) as RNK
from researchers as r
join projects as p
	on r.researcher_id = p.lead_researcher_id
join publications as pub
	on pub.project_id = p.project_id
)
select
	researcher_id,
    name,
    year_,
    impact_factor
from Researchers_with_highest_impact_factor
where RNK = 1
order by year_;

-- Query-15) List all projects that have received funding but have no publications yet.
select DISTINCT
	p.project_id,
    p.title
from projects as p
join project_funding as pf
	on p.project_id = pf.project_id
left join publications as pub
	on pub.project_id = p.project_id
where pub.project_id IS NULL;

-- Query-16) For each project, return the latest funding agency (based on awarded_date).
with latest_funding_agency as
(
select 
	p.project_id,
    p.title,
    pf.funding_agency,
    pf.awarded_Date,
    row_number() over (partition by p.project_id order by  pf.awarded_Date desc) as RNK
from projects as p
join project_funding as pf
	on p.project_id = pf.project_id
)
select
	project_id,
    title,
    funding_agency,
    awarded_Date
from latest_funding_agency
where RNK = 1;

-- Query-17) Calculate the average number of days between a project's start date and its first funding date.
with Average_days_duration as
(
select 	
	p.project_id,
    p.title,
    p.start_Date,
    pf.awarded_Date,
    row_number() over (partition by p.project_id order by pf.awarded_Date) as RNK
from projects as p
join project_funding as pf
	on p.project_id = pf.project_id
)
select
	project_id,
    title,
    start_Date,
    awarded_Date,
    round(avg(datediff(awarded_Date, start_Date)),0) as average_days
from Average_days_duration
where RNK = 1
group by project_id, title, start_Date, awarded_Date;

-- Query-18) Which departments have the most ongoing projects (end_date IS NULL)?
select 
	r.department,
    count(project_id) as On_Going_Projects
from researchers as r
join projects as p
	on r.researcher_id = p.lead_researcher_id
where p.end_Date is NULL
group by r.department
order by On_Going_Projects DESC
limit 1;
    

-- Query-19) Which journal has the highest average impact factor, and what is that value?
select
	Journal,
    round(avg(Impact_factor),2) as average_impact_factor
from Publications
group by Journal
order by average_impact_factor DESC
limit 1;

-- Query-20) For each project, calculate the funding amount per publication. Only include projects that have at least one publication and one funding entry.
with funding_per_project as
(
select
	p.project_id,
    p.title,
    sum(pf.amount) as total_funding_amount
from projects as p
join project_funding as pf
	on p.project_id = pf.project_id
group by p.project_id, p.title
),
publication_count as
(
select
	p.project_id,
    count(pub.publication_id) as publication_counts
from projects as p
join publications as pub
	on p.project_id = pub.project_id
group by p.project_id
),
funding_per_publications as
(
select
	fpp.project_id,
    fpp.title,
    fpp.total_funding_amount,
    pc.publication_counts,
    ROUND(fpp.total_funding_amount / pc.publication_counts, 2) AS funding_per_publication
from funding_per_project as fpp
join publication_count as pc
	on fpp.project_id = pc.project_id
)
select *
from funding_per_publications
order by funding_per_publication;












