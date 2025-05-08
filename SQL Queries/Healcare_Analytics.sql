create database Healthcare_Analytics;

use Healthcare_Analytics;

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender CHAR(1),
    date_of_birth DATE,
    city VARCHAR(50)
);

INSERT INTO Patients VALUES
(1, 'John Doe', 'M', '1980-01-10', 'Chicago'),
(2, 'Jane Smith', 'F', '1975-03-22', 'New York'),
(3, 'Mark Lee', 'M', '1990-07-15', 'Houston'),
(4, 'Sara Ali', 'F', '1985-06-09', 'Phoenix'),
(5, 'Tom Brown', 'M', '2000-12-05', 'San Diego'),
(6, 'Emily Davis', 'F', '1995-02-18', 'Seattle'),
(7, 'Michael Chen', 'M', '1978-11-30', 'Boston'),
(8, 'Anna Bell', 'F', '1982-08-25', 'Dallas'),
(9, 'Lucas White', 'M', '1999-05-14', 'Austin'),
(10, 'Nina Ray', 'F', '2003-09-10', 'Denver');

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialty VARCHAR(50),
    years_experience INT
);


INSERT INTO Doctors VALUES
(101, 'Dr. Smith', 'Cardiology', 15),
(102, 'Dr. Patel', 'Neurology', 20),
(103, 'Dr. Khan', 'Orthopedics', 10),
(104, 'Dr. Jones', 'Pediatrics', 8),
(105, 'Dr. Roy', 'Dermatology', 12),
(106, 'Dr. Lee', 'General Medicine', 7),
(107, 'Dr. Brown', 'ENT', 14),
(108, 'Dr. Singh', 'Oncology', 18),
(109, 'Dr. Taylor', 'Radiology', 9),
(110, 'Dr. Wang', 'Endocrinology', 11);


CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    diagnosis VARCHAR(100),
    fee DECIMAL(6, 2),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

INSERT INTO Appointments VALUES
(1001, 1, 101, '2023-08-15', 'Hypertension', 150.00),
(1002, 2, 102, '2023-08-16', 'Migraine', 200.00),
(1003, 3, 103, '2023-08-16', 'Knee Pain', 180.00),
(1004, 4, 104, '2023-08-17', 'Flu', 120.00),
(1005, 5, 105, '2023-08-18', 'Acne', 130.00),
(1006, 1, 106, '2023-08-19', 'Checkup', 100.00),
(1007, 6, 107, '2023-08-20', 'Sinus', 140.00),
(1008, 7, 108, '2023-08-21', 'Tumor', 250.00),
(1009, 8, 109, '2023-08-22', 'X-Ray', 90.00),
(1010, 9, 110, '2023-08-23', 'Thyroid', 160.00),
(1011, 10, 101, '2023-08-24', 'Chest Pain', 170.00);


CREATE TABLE Prescriptions (
    prescription_id INT PRIMARY KEY,
    appointment_id INT,
    medicine_name VARCHAR(100),
    dosage VARCHAR(50),
    duration_days INT,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

INSERT INTO Prescriptions VALUES
(1, 1001, 'Atenolol', '50mg', 30),
(2, 1002, 'Sumatriptan', '25mg', 10),
(3, 1003, 'Ibuprofen', '400mg', 14),
(4, 1004, 'Oseltamivir', '75mg', 5),
(5, 1005, 'Clindamycin', '300mg', 10),
(6, 1006, 'Multivitamin', '1 tab', 7),
(7, 1007, 'Loratadine', '10mg', 5),
(8, 1008, 'Chemotherapy Drug', 'Varies', 60),
(9, 1009, 'Calcium', '500mg', 30),
(10, 1010, 'Levothyroxine', '100mcg', 30),
(11, 1011, 'Aspirin', '75mg', 15);


use Healthcare_Analytics;

-- Query-1) CTE: Find the average fee per patient using a CTE, and list patients whose average fee is above the overall average of all patients.
with avg_patient_fees as
(
select
	p.name as Pateint_Name,
	round(avg(a.fee),2) as average_fee
from Patients as p
join Appointments as a
	on p.patient_id = a.patient_id
group by p.name
)
select
	Pateint_Name,
    average_fee
from avg_patient_fees
where average_fee > (select avg(average_fee) from avg_patient_fees);

-- Query-2) Using a CTE, assign a row number to each appointment per patient ordered by appointment date. List the most recent appointment for each patient.
with patient_appointment_info as 
(
select 
	p.patient_id as Patient_id_,
    p.name as Patient_name,
    a.appointment_id as Appointment_id_,
    a.appointment_Date as Appointment_Date_
from patients as p
join Appointments as a
	on p.patient_id = a.patient_id
),
ranked_appointment as
(
select
	Patient_id_,
    Patient_name,
    Appointment_id_,
    Appointment_Date_,
    rank() over (partition by Patient_id_ order by Appointment_Date_ desc) as RNK
from patient_appointment_info
)
select
	Patient_id_,
    Patient_name,
    Appointment_id_,
    Appointment_Date_
from ranked_appointment
where RNK = 1;

-- Query-3) VIEW:Create a view showing the patient name, doctor name, appointment date, diagnosis, and city.
Create or replace view doctor_patient_diagnosis_info as
(
select 
	p.name as Patient_name,
    d.name as Doctor_name,
    a.appointment_date,
    a.diagnosis,
    p.city
from Patients as p
join Appointments as a
	on p.patient_id = a.patient_id
join doctors as d
	on a.doctor_id = d.doctor_id
join Prescriptions as pre
	on pre.appointment_id = a.appointment_id
);

select * from doctor_patient_diagnosis_info;

-- Query-4)Advanced Join: Write a query to list the doctors who have not been visited by any patient yet.
select
	d.doctor_id,
	d.name
from doctors as d
left join appointments as a
	on d.doctor_id = a.doctor_id
where a.appointment_id is NULL;

-- Query-5) Advanced Aggregation: For each city, find the average appointment fee and number of distinct doctors consulted.
select 
	p.city,
    round(avg(a.fee),2) as avg_appointment_fees,
    count(distinct a.doctor_id) as doctor_count
from patients as p
join appointments as a
	on p.patient_id = a.patient_id
group by p.city;

-- Query-6)Window Function (RANK): Rank patients based on their total amount spent on appointments. List top 5 spenders.
select *
from 
(
select 
	p.patient_id,
	p.name,
    sum(a.fee) as total_spent,
    rank() over (order by sum(a.fee) desc) as RNK
from patients as p
join appointments as a
	on p.patient_id = a.patient_id
group by p.patient_id, p.name
) as patient_spent
where RNK <= 5
order by RNK;

-- Query-7)Join + Aggregation: List the number of prescriptions issued per doctor, along with the doctor’s name.
select
	d.doctor_id,
    d.name,
    count(pre.prescription_id) as presecription_count
from Prescriptions as pre
join appointments as a
	on pre.appointment_id = a.appointment_id
join doctors as d
	on d.doctor_id = a.doctor_id
group by d.doctor_id, d.name;

-- Query-8) Nested Aggregation: Find doctors who charged more than the average fee of all doctors for at least one appointment.
SELECT 
    d.doctor_id,
    d.name AS doctor_name,
    SUM(a.fee) AS total_fees
FROM doctors AS d
JOIN appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name
HAVING SUM(a.fee) > (
    SELECT AVG(fee)
    FROM appointments
);

-- Query-9) Multiple CTEs:Using two CTEs, first calculate the total appointments per doctor, then the average total appointments. List doctors above this average.
with doctor_appointment_count as 
(
select 
	d.doctor_id as Doctor_Id_,
    d.name as Doctor_Name_,
    count(a.appointment_id) as appointment_count
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
group by d.doctor_id, d.name
),
average_total_appontments as
(
	select
    avg(appointment_count) as average_appointments
    from doctor_appointment_count
)
select
	doctor_appointment_count.Doctor_Id_,
    doctor_appointment_count.Doctor_Name_,
    doctor_appointment_count.appointment_count
from average_total_appontments 
join doctor_appointment_count
	on average_total_appontments.average_appointments < doctor_appointment_count.appointment_count;

-- Query-10) Partitioned Window Function: For each doctor, calculate the cumulative revenue they’ve generated ordered by appointment date.
select 
	d.Doctor_id,
    d.name,
    sum(a.fee) over (partition by d.doctor_id order by a.appointment_date rows between unbounded preceding and current row) as cumulative_revenue
from Doctors as d
join Appointments as a
	on d.doctor_id = a.doctor_id;

-- Query-11) CTE + CASE Statement: Create a report using a CTE that classifies patients as 'Young', 'Adult', or 'Senior' based on age, and list their total appointments.
with patient_age_distribution as
(
select
	timestampdiff(year, p.date_of_birth, curdate()) as age,
    count(a.appointment_id) as appointment_count
from patients as p
join Appointments as a
	on p.patient_id = a.patient_id
group by age
)
select
	age,
	case
		when age < 20 then 'Young'
        when age between 21 and 50 then 'Adult'
        when age >= 51 then 'senior'
    end as age_distribution,
    appointment_count
from patient_age_distribution;

-- Query-12) View + Join: Create a view showing doctor performance: doctor name, total patients seen, and average fee charged.
create or replace view doctor_performance as 
(
select 
	d.doctor_id,
    d.name,
    count(a.appointment_id) as patient_seen,
    round(avg(a.fee),2) as average_charged_fees
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
group by d.doctor_id, d.name
);

select * from doctor_performance;

-- ==================================================== WINDOW FUNCTION =======================================================================

-- Query-1) For each patient, show the date of their latest appointment and their total number of appointments.
select 
	patient_id,
    name,
    appointment_date,
    number_of_appointments
from
(
select 
	p.patient_id,
    p.name,
    a.appointment_date,
	count(*) over (partition by p.patient_id) as number_of_appointments,
    rank() over (partition by p.patient_id order by a.appointment_date desc) as RNK
from patients as p
join appointments as a
	on p.patient_id = a.patient_id
) as latest_appointments
where RNK = 1;

-- Query-2) Rank doctors within each specialty based on the total fee they have generated from appointments.
with doctor_specialty as 
(
select 
	d.doctor_id as Doctor_id_,
    d.name as Doctor_Name,
    d.specialty as Specialty,
    round(sum(a.fee),2) as total_fees
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
group by d.doctor_id, d.name, d.specialty
) 
select
	Doctor_id_,
    Doctor_Name,
    Specialty,
    total_fees,
    rank() over (partition by Specialty order by total_fees DESC) as RNK
from doctor_specialty;

-- Query-3) For each doctor, calculate the running total of appointment fees ordered by appointment date.
select
	d.doctor_id,
    d.name,
    a.fee,
    sum(a.fee) over (partition by d.doctor_id order by a.appointment_date) as running_total
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id;

-- Query-4) List the top 2 most prescribed medicines per doctor.
with presecription_count_by_doctors_ as
(
select 
	d.doctor_id as Doctor_id_,
    d.name as Doctor_Name,
    pre.medicine_name as Medicine_Name, 
	rank () over (partition by d.doctor_id order by count(prescription_id)) as RNK
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
join Prescriptions as pre
	on pre.appointment_id = a.appointment_id
group by d.doctor_id, d.name, pre.medicine_name
)
select
	Doctor_id_,
    Doctor_Name,
    Medicine_Name
from presecription_count_by_doctors_
where RNK <= 2;

-- =============================================================== CTE =============================================================================

-- Query-5) Using a CTE, find all patients who had more than one appointment and list the dates of those appointments.
WITH patient_appointment_counts AS (
    SELECT 
        p.patient_id AS Patient_Id_,
        p.name AS Patient_Name,
        COUNT(a.appointment_id) AS appointment_count
    FROM patients p
    JOIN appointments a ON p.patient_id = a.patient_id
    GROUP BY p.patient_id, p.name
),
qualified_patients AS (
    SELECT Patient_Id_
    FROM patient_appointment_counts
    WHERE appointment_count > 1
)
SELECT 
    p.patient_id AS Patient_Id_,
    p.name AS Patient_Name,
    a.appointment_date AS Appointment_Date_
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN qualified_patients q ON p.patient_id = q.Patient_Id_
ORDER BY p.patient_id, a.appointment_date;

-- Query-6) Create a CTE that calculates the average fee per diagnosis, and then list all appointments with fees above this average.
with avg_diagnosis_fees as 
(
select
	a.appointment_id as Appointment_ID,
    a.diagnosis as Diagnosis_Name,
    round(avg(a.fee),2) as avg_fee
from Appointments as a
group by a.diagnosis, a.appointment_id
),
feess_above_average as 
(
select
	a.appointment_id as Appointment_ID,
    a.fee as Normal_Fees
from Appointments as a
)
select
	faa.Appointment_ID,
    faa.Normal_Fees
from avg_diagnosis_fees as adf
join feess_above_average as faa
	on adf.Appointment_ID = faa.Appointment_ID
where faa.Normal_Fees > adf.avg_fee;

-- Query-7)Find doctors who have treated patients from more than 1 different cities.
with doctor_patient_treatment as 
(
select 
	d.doctor_id as Doctor_ID_,
    d.name as Doctor_Name,
	count(distinct p.city) as distinct_city_count
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
join patients as p
	on p.patient_id = a.patient_id
group by d.doctor_id, d.name
)
select
	Doctor_ID_,
    Doctor_Name
from doctor_patient_treatment
where distinct_city_count > 1;

-- ==================================================== AGGREGATION & GROUPING =======================================================================

-- Query-8) Find the diagnosis with the highest average treatment fee.
select
	a.Diagnosis,
    round(avg(a.fee),2) as avg_fees
from Appointments as a
group by a.Diagnosis
order by avg_fees desc
limit 1;

-- Query-9) Show the number of unique patients seen by each doctor.
select
	d.Doctor_id,
    d.name,
    count(distinct a.patient_id) as Patient_count
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
group by d.doctor_id, d.name;
    

-- Query-10) Calculate the total revenue generated per city through appointments.
select
	p.city,
    sum(a.fee) as total_fees
from patients as p
join appointments as a
	on p.patient_id = a.patient_id
group by p.city
order by total_fees desc;
    

-- Query-11) Find the medicine that has been prescribed for the longest average duration.
select
	p.medicine_name,
    round(avg(duration_days),2) as average_duration
from prescriptions as p
group by p.medicine_name
order by average_duration desc
limit 1;


-- ==================================================== ADVANCED JOINS =======================================================================

-- Query-12) List all patients and their most recent prescription (even if they didn’t have one).
select 
	p.patient_id,
    p.name,
    pre.prescription_id,
    a.appointment_date as latest_appointment_date
from patients as p
left join appointments as a
	on p.patient_id = a.patient_id
left join Prescriptions as pre
	on pre.appointment_id = a.appointment_id
where a.appointment_date = (
	select max(a.appointment_date)
    from appointments as a2
    where a2.patient_id = p.patient_id
)
order by p.patient_id;

-- Query-13) Find doctors who have never prescribed medicine through their appointments.
select
	d.Doctor_id,
    d.name
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
left join Prescriptions as p
	on p.appointment_id = a.appointment_id
group by d.doctor_id, d.name
having count(p.Prescription_id) = 0;

-- ========================================================== VIEWS ==========================================================================

-- Query-14) Create a view that shows patient name, appointment date, doctor name, diagnosis, and prescribed medicine.
create or replace view patient_doctor_info as 
(
select 
	p.name as Patient_Name,
    a.appointment_date,
    d.name as Doctor_Name,
    a.diagnosis,
    pre.medicine_name
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
join patients as p
	on p.patient_id = a.patient_id
join Prescriptions as pre
	on pre.appointment_id = a.appointment_id
);
select * from patient_doctor_info;

-- Query-15) Design a view to summarize each doctor’s activity: total appointments, total revenue, and number of unique patients.
create or replace view doctors_activity as
(
select 
	d.doctor_id,
    d.name,
    count(a.appointment_id) as total_appointments,
    sum(a.fee) as total_revenue,
    count(distinct a.patient_id) as unique_patients
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
group by d.doctor_id, d.name
order by d.doctor_id
);
select * from doctors_activity;
-- Query-16) Make a view that shows medicines prescribed for diagnoses starting with ‘C’ or ‘T’, along with related patient details.
create or replace view medicine_for_diagnosis_C_or_T as
(
select
	pa.*,
	a.diagnosis,
    p.medicine_name
from Appointments as a
join Prescriptions as p
	on a.appointment_id = p.appointment_id
join patients as pa
	on pa.patient_id = a.patient_id
where a.diagnosis like 'c%' or a.diagnosis like 't%'
);
select * from medicine_for_diagnosis_C_or_T;

-- ========================================================== SUBQURIES ==========================================================================

-- Query-17) Find the doctor who generated the highest total revenue in August 2023.
select
	d.doctor_id,
    d.name,
    sum(a.fee) as total_revenue
from doctors as d
join appointments as a
	on d.doctor_id = a.doctor_id
where  date_format(a.appointment_Date, '%M-%Y') = 'August-2023'
group by d.doctor_id, d.name
order by total_revenue desc
limit 1;

-- Query-18)List all diagnoses that had an average prescription duration greater than 15 days.
select *
from
(
select
	a.diagnosis,
    round(avg(p.duration_days),2) as average_duration_days
from appointments as a
join Prescriptions as p
	on a.appointment_id = p.appointment_id
group by a.diagnosis
) average_prescription_duration
where average_duration_days > 15;





