-- ======================================================= TABLE CREATION ====================================================================

create database Travel_Booking_System;

use Travel_Booking_System;

-- Create Tables

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50)
);

CREATE TABLE Airports (
    airport_code CHAR(3) PRIMARY KEY,
    airport_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE Flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(10),
    departure_airport CHAR(3),
    arrival_airport CHAR(3),
    departure_time DATETIME,
    arrival_time DATETIME,
    capacity INT,
    CONSTRAINT fk_departure FOREIGN KEY (departure_airport) REFERENCES Airports(airport_code),
    CONSTRAINT fk_arrival FOREIGN KEY (arrival_airport) REFERENCES Airports(airport_code)
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    flight_id INT,
    booking_date DATE,
    seat_number VARCHAR(5),
    price DECIMAL(10,2),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

-- Insert Records

INSERT INTO Customers VALUES
(1, 'Alice', 'Johnson', 'alice.johnson@email.com', '555-1234', 'New York'),
(2, 'Bob', 'Smith', 'bob.smith@email.com', '555-5678', 'Chicago'),
(3, 'Carol', 'Davis', 'carol.davis@email.com', '555-8765', 'Los Angeles'),
(4, 'David', 'Martinez', 'david.martinez@email.com', '555-4321', 'Miami');

INSERT INTO Airports VALUES
('JFK', 'John F. Kennedy International Airport', 'New York', 'USA'),
('ORD', 'O\'Hare International Airport', 'Chicago', 'USA'),
('LAX', 'Los Angeles International Airport', 'Los Angeles', 'USA'),
('MIA', 'Miami International Airport', 'Miami', 'USA');

INSERT INTO Flights VALUES
(101, 'AA100', 'JFK', 'LAX', '2025-07-01 08:00:00', '2025-07-01 11:00:00', 180),
(102, 'UA200', 'ORD', 'MIA', '2025-07-01 09:00:00', '2025-07-01 13:00:00', 150),
(103, 'DL300', 'LAX', 'ORD', '2025-07-02 14:00:00', '2025-07-02 20:00:00', 170),
(104, 'SW400', 'MIA', 'JFK', '2025-07-02 15:30:00', '2025-07-02 19:00:00', 160);

INSERT INTO Bookings VALUES
(201, 1, 101, '2025-06-15', '12A', 350.00),
(202, 2, 102, '2025-06-16', '7B', 200.00),
(203, 1, 103, '2025-06-17', '15C', 400.00),
(204, 3, 101, '2025-06-18', '14D', 350.00),
(205, 4, 104, '2025-06-20', '1A', 300.00),
(206, 2, 104, '2025-06-21', '3C', 300.00);


-- ================================================================ Easy =======================================================================

-- Query-1) Select all customers living in 'New York' or 'Chicago'.
select
	c.customer_id,
    c.first_name,
    c.last_name,
    c.city
from customers as c
where c.city = 'New York' or c.city = 'Chicago';


-- Query-2) List all flights departing from 'JFK' airport.
select
	f.flight_id,
    f.flight_number,
    f.departure_airport,
    f.arrival_airport,
    f.arrival_time
from Flights as f
where f.departure_airport = 'JFK';

-- Query-3) Find the total number of bookings for flight_id 101.
select
	f.flight_id,
    count(b.booking_id) as total_booking_count
from flights as f
join bookings as b
	on f.flight_id = b.flight_id
where f.flight_id = 101
group by f.flight_id;

-- Query-4) Retrieve booking details along with customer names for all bookings.
select 
	b.booking_id,
	b.customer_id,
    c.first_name,
    c.last_name,
    b.flight_id,
    b.booking_Date,
    b.seat_number,
    b.price
from bookings as b
join customers as c
	on b.customer_id = c.customer_id;

-- Query-5) Find all airports located in the USA.
select
	*
from airports
where country = 'USA';

-- Query-6) List all flights sorted by departure_time ascending.
select
	*
from flights
order by departure_time;

-- Query-7) Show customers who booked more than one flight.
select
	c.customer_id,
    c.first_name,
    c.last_name,
    count(b.booking_id) as booking_count
from customers as c
join bookings as b
	on c.customer_id = b.customer_id
group by c.customer_id, c.first_name, c.last_name
having count(b.booking_id) > 1
order by c.customer_id;

-- Query-8) Find the maximum price paid in the Bookings table.
select
	b.booking_id,
    b.customer_id,
    c.first_name,
    c.last_name,
    b.booking_date,
    b.seat_number,
    b.price
from bookings as b
join customers as c
	on b.customer_id = c.customer_id
order by b.price desc
limit 1;

-- ================================================================ Medium =======================================================================

-- Query-9) Find the total revenue generated by each flight.
select 
	f.flight_id,
    f.flight_number,
    sum(b.price) as total_revenue
from flights as f
join bookings as b
	on f.flight_id = b.flight_id
group by f.flight_id, f.flight_number
order by total_revenue desc;


-- Query-10) List customers who have booked flights departing from 'ORD'.
select 
	c.customer_id,
    c.first_name,
    c.last_name,
    f.departure_airport
from customers as c
join bookings as b
	on c.customer_id = b.customer_id
join flights as f
	on f.flight_id = b.flight_id
where f.departure_airport = 'ORD';


-- Query-11) Show flights that have capacity greater than the number of bookings.
with flight_total_capacity as
(
select
	f.flight_id,
    sum(capacity) as total_capacity
from flights as f
group by f.flight_id
),
number_of_booking as
(
select 
	f.flight_id,
    count(b.booking_id) as booking_count
from flights as f
join bookings as b
	on f.flight_id = b.flight_id
group by f.flight_id
)
select
	flight_total_capacity.flight_id,
    flight_total_capacity.total_capacity,
    total_booking.booking_count
from flight_total_capacity as flight_total_capacity
join number_of_booking as total_booking
	on flight_total_capacity.flight_id = total_booking.flight_id 
where flight_total_capacity.total_capacity > total_booking.booking_count;


-- Query-12) Find the average booking price for each customer.
select 
	c.customer_id,
    c.first_name,
    c.last_name,
    round(avg(b.price),2) as average_booking_price
from bookings as b
join customers as c
	on b.customer_id = c.customer_id
group by c.customer_id, c.first_name, c.last_name
order by average_booking_price desc;

-- Query-13) Display flights along with the number of bookings and remaining available seats.
with avaiable_seats as 
(
select 
	f.flight_id,
    f.flight_number,
	sum(f.capacity) as total_capacity,
    count(b.booking_id) as booking_count
from flights as f
left join bookings as b
	on f.flight_id = b.flight_id
group by f.flight_id, f.flight_number
)
select
	flight_id,
    flight_number,
    total_capacity,
    booking_count,
    (total_capacity - booking_count) as remaining_seats
from avaiable_seats;

-- Query-14) Retrieve all flights that depart and arrive in the same country.
select 
	f.flight_id,
    f.flight_number,
    f.departure_airport,
    a1.country,
    f.arrival_airport,
    a2.country
from flights as f
join airports as a1
	on f.departure_airport = a1.airport_code
join airports as a2
	on f.arrival_airport = a2.airport_code
where  a1.country =  a2.country;

-- Query-15) Get all bookings with seat numbers starting with '1'.
select
	*
from bookings
where seat_number like '1%';

-- Query-16) Find the customer who booked the most flights
select
	c.customer_id,
    c.first_name,
    c.last_name,
    count(b.booking_id) as booking_count
from customers as c
join bookings as b
	on c.customer_id = b.customer_id
group by c.customer_id, c.first_name, c.last_name
order by booking_count desc
limit 1;

-- ================================================================ Hard =======================================================================


-- Query-17) Write a query to find customers who have booked flights to all available airports.
with airport_count as
(
select 
	count(airport_code) as total_airports
from airports
),
customer_unique_airport_counts as
(
select 
	c.customer_id,
    c.first_name,
    c.last_name,
    count(distinct f.arrival_airport) as booking_count
from customers as c
join bookings as b
	on c.customer_id = b.customer_id
join flights as f
	on f.flight_id = b.flight_id
group by c.customer_id, c.first_name, c.last_name
)
select
	cuac.customer_id,
    cuac.first_name,
    cuac.last_name
from airport_count as ac, customer_unique_airport_counts as cuac
where cuac.booking_count = ac.total_airports;


-- Query-18) Use a window function to rank flights by total revenue generated.
with total_revenue_generated as
(
select 
	f.flight_id,
    f.flight_number,
    sum(b.price) as total_revenue
from flights as f
join bookings as b
	on f.flight_id = b.flight_id
group by f.flight_id, f.flight_number
)
select
	flight_id,
    flight_number,
    total_revenue,
    rank() over (order by total_revenue desc) as RNK
from total_revenue_generated;


-- Query-19) Calculate the average time difference (in hours) between booking date and flight departure date for each customer.
select 
	c.customer_id,
    c.first_name,
    c.last_name,
    round(avg(datediff(f.departure_time,  b.booking_date) * 24),0) as time_diff_in_Hours
from customers as c
join bookings as b
	on c.customer_id = b.customer_id
join flights as f
	on f.flight_id = b.flight_id
group by c.customer_id, c.first_name, c.last_name;


-- Query-20) Write a query to find flights that have no bookings.
select 
	f.flight_id,
    f.flight_number
from flights as f
left join bookings as b
	on f.flight_id = b.flight_id
where b.booking_id is NULL;

-- Query-21) Retrieve the top 3 customers based on total amount spent on bookings.
select
	c.customer_id,
    c.first_name,
    c.last_name,
    sum(b.price) as total_price
from customers as c
join bookings as b
	on c.customer_id = b.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_price desc
limit 3;

-- Query-22) Find flights where the arrival_time is earlier than the departure_time (consider timezone issues or incorrect data).
select
	flight_id,
    flight_number,
    departure_time,
    arrival_time
from flights 
where arrival_time < departure_time;

-- Query-23) Show cumulative revenue generated by flights ordered by departure_time.
select 
	f.flight_id,
    f.flight_number,
    sum(b.price) as total_revenue_per_flight,
    sum(sum(b.price)) over (order by f.departure_time) as cumulative_revenue
from flights as f
join bookings as b
	on f.flight_id = 
    b.flight_id
group by f.flight_id, f.flight_number, f.departure_time;



