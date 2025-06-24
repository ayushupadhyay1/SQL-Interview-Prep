
use Hospital_Emergencey_Room_Analytics;

-- Query-1) Find the average ER treatment duration by doctor specialization, only including successful treatments.
select 
	d.specialization,
    round(avg(time_to_sec(timediff( t.end_time, t.start_time)))/60,2) as duration
from treatments as t
join visits as v
	on t.visit_id = v.visit_id
join doctors as d
	on d.doctor_id = v.doctor_id
where t.success = 1
group by d.specialization;

-- Query-2) Identify patients who received treatment before their visit was officially registered.
select 
	v.patient_id,
    v.visit_id,
    t.treatment_id,
    v.visit_time,
    t.start_time
from visits as v
join treatments as t	
	on v.visit_id = t.visit_id
where t.start_time < v.visit_time;

-- Query-3) Which doctor had the highest patient severity average during the night shifts (00:00–08:00)?
select 
	d.doctor_id,
    d.name,
    round(avg(v.severity_level),2) as average_severity_level
from doctors as d
join visits as v
	on d.doctor_id = v.doctor_id
where cast(v.visit_time as time) between '00:00:00' and '08:00:00'
group by d.doctor_id, d.name
order by average_severity_level desc
limit 1;

-- Query-4) List visits where total treatment time exceeds the visit duration.
with visit_and_treatment_duration as
(
select 
	v.visit_id,
	t.start_time  as treatment_start_time,
    t.end_time as treatment_end_time,
    v.visit_time as visit_time,
    v.discharge_time as discharge_time
from treatments as t
join visits as v
	on t.visit_id = v.visit_id
)
select *
from
(
select
	visit_id,
    timediff(treatment_end_time, treatment_start_time) as treatment_duration,
    timediff(discharge_time, visit_time) as visit_duration
from visit_and_treatment_duration
) as diff
where treatment_duration > visit_duration;

-- Query-5) Rank doctors based on total number of patients treated successfully over the past 30 days.
with doctor_rank as
(
select 
	d.doctor_id,
    d.name,
    count(distinct v.patient_id) as patient_count
from doctors as d
join visits as v
	on d.doctor_id = v.doctor_id
join treatments as t
	on t.visit_id = v.visit_id
where t.success = 1 and date(end_time) >= current_date() - interval 30 day
group by d.doctor_id, d.name
)
select
	doctor_id,
    name,
    patient_count,
    rank() over (order by patient_count desc) as RNK
from doctor_rank;

-- Query-6) Find the average waiting time (visit_time to first treatment start_time) per severity level.
with waiting_time as 
(
select 
	v.severity_level,
    v.visit_time,
    min(t.start_time) as first_treatment
from visits as v
join treatments as t
	on v.visit_id = t.visit_id
group by v.severity_level, v.visit_time
)
select
	severity_level,
    round(avg(time_to_sec(timediff(first_treatment, visit_time))/60),2) as total_waiting_time
from waiting_time
group by severity_level
order by total_waiting_time;

-- Query-7) Identify shifts where a doctor worked but didn’t treat any patients.
select
	distinct s.doctor_id,
    d.name
from er_shifts as s
left join visits as v
	on s.doctor_id = v.doctor_id
    and v.visit_time between s.start_time and s.end_time
join doctors as d
	on d.doctor_id = s.doctor_id 
where v.doctor_id is NULL;

-- Query-8) List top 2 treatments by frequency for each doctor across all visits.
with top_2_treatments as
(
select 
	d.doctor_id,
    d.name,
    t.treatment_name,
    count(*) as treatment_freq
from doctors as d
join visits as v
	on d.doctor_id = v.doctor_id
join treatments as t
	on t.visit_id = v.visit_id
group by d.doctor_id, d.name, t.treatment_name
), 
ranked_treatment as
(
select
	doctor_id,
    name,
    treatment_name,
    treatment_freq,
    rank() over (partition by doctor_id order by treatment_freq desc) as RNK
from top_2_treatments
)
select *
from ranked_treatment
where RNK <= 2;


-- Query-9) Detect overlapping shifts for any doctor (i.e., double-booked).
select 
	d.doctor_id,
    d.name,
    s.shift_date,
    s.start_time,
    s.end_time
from doctors as d
join ER_Shifts as s
	on d.doctor_id = s.doctor_id
join ER_Shifts as s1
	on s1.doctor_id = s.doctor_id
	and s1.shift_date = s.shift_Date
    and s.shift_id < s1.shift_id
    and s.end_time > s1.start_time
    and s.start_time < s1.end_time;
    
-- Query-10) Find doctors whose average treatment success rate is below 75% over the last 60 days.
with doctor_treatment_success_ratio as
(
select 
	d.doctor_id,
    d.name,
    sum(t.success) as total_success_cases,
    count(*) as total_treatments_per_doctor
from doctors as d
join visits as v
	on d.doctor_id = v.doctor_id
join treatments as t
	on t.visit_id = v.visit_id
where t.end_time >= current_time() - interval 60 day
group by d.doctor_id, d.name
),
total_treamtments as
(
select 
	count(*) as total_treatments
from Treatments as t
where t.end_time >= current_time() - interval 60 day
)
select *
from
(
select 
	dts.doctor_id,
    dts.name,
    round((dts.total_success_cases / dts.total_treatments_per_doctor) * 100,2) as Success_Percentages
from doctor_treatment_success_ratio as dts
cross join total_treamtments as tt
) as percentage_ratio
where Success_Percentages < 75;

with doctor_treatment_success_ratio as (
  select 
    d.doctor_id,
    d.name,
    sum(t.success) as total_success_cases,
    count(*) as total_treatments
  from doctors as d
  join visits as v
    on d.doctor_id = v.doctor_id
  join treatments as t
    on t.visit_id = v.visit_id
  where t.end_time >= current_date() - interval 60 day
  group by d.doctor_id, d.name
)
select
  doctor_id,
  name,
  round((total_success_cases / total_treatments) * 100, 2) as success_percentage
from doctor_treatment_success_ratio
where (total_success_cases / total_treatments) < 0.75;


-- Query-11) Identify patients who visited more than once in a 7-day window.
    
-- Query-12) Determine which doctor had the longest cumulative shift duration in the past month.
with doctors_shift_duration as
(
select 
	d.doctor_id,
    d.name,
    round(time_to_sec(timediff(s.end_time, s.start_time))/3600 + 
			IF(s.end_time < s.start_time, 24, 0),2) as shift_duration
from doctors as d
join ER_shifts as s
	on d.doctor_id = s.doctor_id
where s.shift_date >= current_date() - interval 1 month
)
select
	doctor_id,
    name,
    shift_duration,
    sum(shift_duration) over (partition by doctor_id) as Cumulative_shift_duration
from doctors_shift_duration
order by Cumulative_shift_duration desc;


-- Query-13) Find top 3 hours of the day with the highest patient inflow.
select
	hour(visit_time) as visit_hour,
	count(*) as visit_count
from visits as v
group by visit_hour
order by visit_count desc
limit 3;
