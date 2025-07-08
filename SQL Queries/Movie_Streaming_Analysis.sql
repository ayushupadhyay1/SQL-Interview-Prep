Create database Movie_Streaming_Analsis;

use Movie_Streaming_Analsis;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    country VARCHAR(50),
    signup_date DATE
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    release_year INT,
    rating FLOAT
);

CREATE TABLE watch_history (
    watch_id INT PRIMARY KEY,
    user_id INT,
    movie_id INT,
    watch_date DATE,
    watch_duration INT, -- duration in minutes
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

CREATE TABLE subscriptions (
    sub_id INT PRIMARY KEY,
    user_id INT,
    plan_type VARCHAR(20), -- 'Basic', 'Standard', 'Premium'
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- Users
INSERT INTO users VALUES
(1, 'alice', 'USA', '2023-01-15'),
(2, 'bob', 'UK', '2023-02-20'),
(3, 'carla', 'India', '2023-03-05'),
(4, 'daniel', 'Germany', '2023-04-10');

-- Movies
INSERT INTO movies VALUES
(101, 'Inception', 'Sci-Fi', 2010, 8.8),
(102, 'The Godfather', 'Crime', 1972, 9.2),
(103, 'Parasite', 'Thriller', 2019, 8.6),
(104, 'The Matrix', 'Sci-Fi', 1999, 8.7),
(105, 'Interstellar', 'Sci-Fi', 2014, 8.6);

-- Watch History
INSERT INTO watch_history VALUES
(1001, 1, 101, '2023-07-01', 148),
(1002, 2, 102, '2023-07-02', 175),
(1003, 1, 103, '2023-07-03', 132),
(1004, 3, 104, '2023-07-04', 136),
(1005, 4, 105, '2023-07-05', 169),
(1006, 2, 103, '2023-07-06', 132),
(1007, 2, 105, '2023-07-07', 169);

-- Subscriptions
INSERT INTO subscriptions VALUES
(201, 1, 'Premium', '2023-01-15', '2024-01-14', TRUE),
(202, 2, 'Standard', '2023-02-20', '2024-02-19', TRUE),
(203, 3, 'Basic', '2023-03-05', '2023-09-04', FALSE),
(204, 4, 'Premium', '2023-04-10', '2024-04-09', TRUE);


-- ======================================================= BEGINNER ==================================================================

-- Query-1) List all users who signed up in 2023.
select
	user_id,
    username,
    signup_date
from users
where year(signup_date) = 2023;


-- Query-2) Find all movies released before the year 2010.
select
	movie_id,
    title,
    release_year
from movies
where release_year < 2010;

-- Query-3) Show the watch history of user 'bob'.
select 
	u.user_id,
    u.username,
    wh.movie_id,
    wh.watch_date,
    wh.watch_duration
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
where u.username = 'bob';

-- Query-4) Count the number of movies each user has watched.
select 
	u.user_id,
    u.username,
    count(wh.movie_id) as watched_movie_count
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
group by u.user_id, u.username
order by watched_movie_count desc;


-- Query-5) Get the average rating of movies by genre.
select
	genre,
    round(avg(rating),2) as average_rating
from movies 
group by genre
order by average_rating desc;


-- ======================================================= INTERMEDIATE ==================================================================

-- Query-6) Find users who have watched more than one movie.
select 
	u.user_id,
    u.username,
    count(wh.movie_id) as movie_count
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
group by u.user_id, u.username
having count(wh.movie_id) > 1
order by movie_count desc;
    

-- Query-7) List users along with their current subscription plan.
select 
	u.user_id,
    u.username,
    s.plan_type,
    s.start_date,
    s.end_date,
    s.is_active
from users as u
join subscriptions as s
	on u.user_id = s.user_id
where s.is_active = TRUE ;

-- Query-8) Get the top 2 highest-rated movies.
select
	movie_id,
    title,
    rating
from movies
order by rating desc
limit 2;

-- Query-9) Identify which movies haven’t been watched by any user.
select 
	m.movie_id,
    m.title
from movies as m
left join watch_history as wh
	on m.movie_id = wh.movie_id
where wh.movie_id is NULL;

-- Query-10) Calculate the total watch time per user.
select 
	u.user_id,
    u.username,
    sum(wh.watch_duration) as total_watch_time
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
group by u.user_id, u.username
order by total_watch_time desc;


-- ======================================================= ADVANCED ==================================================================

-- Query-11) Write a query using a CTE to calculate the total watch duration per user and rank users by total time watched.
with watch_duration_per_user as
(
select 
	u.user_id,
    u.username,
    sum(wh.watch_duration) as total_watch_duration
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
group by u.user_id, u.username
)
select
	user_id,
    username,
    total_watch_duration,
    rank() over (order by total_watch_duration desc) as RNK
from watch_duration_per_user;


-- Query-12) Create a VIEW that shows user, subscription plan, total movies watched, and total watch duration.
create or replace view user_watch_history as 
select 
	u.user_id,
    u.username,
    s.plan_type as subscription_plan,
    count(wh.movie_id) as watched_movie_count,
    sum(wh.watch_duration) as total_watch_duration
from users as u
join subscriptions as s
	on u.user_id = s.user_id
join watch_history as wh
	on wh.user_id = u.user_id
group by u.user_id, u.username, s.plan_type;

select *
from user_watch_history;

-- Query-13) Use a correlated subquery to find users who watched movies with above-average ratings.
select 
	u.user_id,
    u.username,
    m.rating
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
join movies as m
	on m.movie_id = wh.movie_id
where m.rating > 
				(select
					avg(rating)
				from movies);

-- Query-14) Write a query using window functions to get the watch count and cumulative watch time per user.
select 
	u.user_id,
    u.username,
    count(wh.watch_id) over (partition by u.user_id) as watch_count,
    sum(wh.watch_duration) over (partition by u.user_id order by wh.watch_duration ROWS UNBOUNDED PRECEDING) as cumulative_watch_time,
    wh.watch_date
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
order by u.user_id, wh.watch_Date;

-- Query-15) Find the top watched genre per user using a CTE and window function.
with genre_watch_count as
(
select 
	u.user_id,
    u.username,
    m.genre,
    count(*) as watch_count
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
join movies as m
	on m.movie_id = wh.movie_id
group by u.user_id, u.username, m.genre
),
ranked_genres as 
(
select
	user_id,
    username,
    genre,
    watch_count,
    rank() over (partition by user_id order by watch_count desc) as RNK
from genre_watch_count
)
select	
	user_id,
    username,
    genre,
    watch_count
from ranked_genres
where RNK = 1;

-- Query-16) Write a query using multiple joins to list each watch record with movie title, user name, subscription plan, and whether the subscription was active during the watch.
select 
	u.user_id,
    u.username,
    m.title,
    s.plan_type,
    wh.watch_date,
    case
		when wh.watch_date between s.start_date and s.end_date then 'Plan was Active'
        else 'Plan was not active'
    end as subscription_plan_status
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
join subscriptions as s
	on s.user_id = u.user_id
join movies as m
	on m.movie_id = wh.movie_id;

-- Query-17) Using a CTE, find users whose subscription ended before their last watch date.
select 
	u.user_id,
    u.username,
    wh.watch_date,
    s.end_date
from users as u
join subscriptions as s
	on u.user_id = s.user_id
join watch_history as wh
	on wh.user_id = u.user_id
where wh.watch_date > s.end_date;

-- Query-18) Find users who have never watched a Sci-Fi movie.
select
	u.user_id,
    u.username
from users as u
left join(
	select
		distinct user_id
	from watch_history as wh
    join movies as m
		on m.movie_id = wh.movie_id
	where m.genre = 'Sci-Fi'
) as sci_fi_watchers on u.user_id = sci_fi_watchers.user_id
where sci_fi_watchers.user_id is NULL;


-- Query-19) Get the longest movie watched by each user.
with longest_watched_movie as
(
select 
	u.user_id,
    u.username,
    m.title,
    wh.watch_duration,
    rank() over (partition by u.user_id order by wh.watch_duration desc) as RNK
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
join movies as m
	on m.movie_id = wh.movie_id
)
select
	user_id,
    username,
    title,
    watch_duration
from longest_watched_movie
where RNK = 1;

-- Query-20) Identify churned users (those who do not have an active subscription and haven’t watched anything in the last 60 days).
select 
	u.user_id,
    u.username
from users as u
left join subscriptions as s
	on u.user_id = s.user_id
left join watch_history as wh
	on wh.user_id = u.user_id and wh.watch_date >= current_date - interval 60 day
where s.user_id is NULL
and wh.user_id is NULL;




