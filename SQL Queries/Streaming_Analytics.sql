-- =========================================================== 	DATABASE =======================================================================

create database streaming_analytics;

-- Create Tables
CREATE TABLE Shows (
    show_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    release_year INT,
    language VARCHAR(30)
);

CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    country VARCHAR(50),
    signup_date DATE
);

CREATE TABLE WatchHistory (
    watch_id INT PRIMARY KEY,
    user_id INT,
    show_id INT,
    watch_date DATE,
    watch_duration_minutes INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

CREATE TABLE Ratings (
    rating_id INT PRIMARY KEY,
    user_id INT,
    show_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 10),
    rating_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

-- Insert Records into Shows
INSERT INTO Shows VALUES 
(1, 'Dark Matter', 'Sci-Fi', 2023, 'English'),
(2, 'Casa de Papel', 'Thriller', 2017, 'Spanish'),
(3, 'Kingdom', 'Horror', 2019, 'Korean'),
(4, 'Stranger Fiction', 'Mystery', 2021, 'English'),
(5, 'Sacred Games', 'Crime', 2018, 'Hindi');

-- Insert Records into Users
INSERT INTO Users VALUES 
(101, 'ayush_23', 'India', '2022-03-14'),
(102, 'li_wen', 'China', '2021-12-01'),
(103, 'sara_joy', 'USA', '2023-01-21'),
(104, 'omar_h', 'Egypt', '2022-07-30'),
(105, 'lena_kr', 'Germany', '2023-05-09');

-- Insert Records into WatchHistory
INSERT INTO WatchHistory VALUES 
(1, 101, 1, '2023-06-12', 45),
(2, 101, 2, '2023-06-15', 50),
(3, 102, 3, '2023-07-10', 60),
(4, 103, 4, '2023-07-11', 55),
(5, 104, 5, '2023-08-01', 65),
(6, 105, 2, '2023-08-03', 40),
(7, 103, 1, '2023-08-05', 30),
(8, 102, 2, '2023-08-06', 50);

-- Insert Records into Ratings
INSERT INTO Ratings VALUES 
(1, 101, 1, 8, '2023-06-13'),
(2, 101, 2, 9, '2023-06-16'),
(3, 102, 3, 7, '2023-07-11'),
(4, 103, 4, 6, '2023-07-12'),
(5, 104, 5, 9, '2023-08-02'),
(6, 105, 2, 8, '2023-08-04');

use streaming_analytics;

-- ======================================================== BEGINNER =========================================================================

-- Query-1) List all shows released after 2020.
select
	s.show_id,
    s.title,
    s.release_year
from shows as s
where s.release_year > 2020;


-- Query-2) Find all users who signed up in 2023.
select
	u.user_id,
    u.username,
    u.signup_date
from users as u
where year(u.signup_date) = 2023;

-- Query-3) Show the total number of users from each country.
select
	u.country,
    count(u.user_id) as User_Count
from users as u
group by u.country
order by User_Count;

-- Query-4) Retrieve all watch history for user ayush_23.
select 
    u.username,
    watch_date,
    s.title
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
where u.username = 'ayush_23'
order by watch_date desc;

-- Query-5) Count how many times each show was watched.
select 
	s.show_id,
    s.title,
    count(wh.watch_id) as Watch_Count
from watchhistory as wh
join shows as s
	on wh.show_id = s.show_id
group by s.show_id, s.title
order by Watch_Count desc;

-- ======================================================== INTERMEDIATE =========================================================================

-- Query-6) Find the top 3 most-watched shows by number of views.
select 
	s.show_id,
    s.title,
    count(wh.watch_id) as Watch_Count
from watchhistory as wh
join shows as s
	on wh.show_id = s.show_id
group by s.show_id, s.title
order by Watch_Count desc
limit 3;

-- Query-7) Find the most active user (watched the most shows).
select
	u.user_id,
    u.username,
    count(show_id) as watched_shows
from watchhistory as wh
join users as u
	on wh.user_id = u.user_id
group by u.user_id, u.username
order by watched_shows desc;    

-- Query-8) Show the average rating for each show.
select 
	s.show_id,
    s.title,
    round(avg(rating),2) as average_rating
from shows as s
join ratings as r
	on s.show_id = r.show_id
group by s.show_id, s.title
order by average_rating desc;

-- Query-9) List users who have rated all the shows they’ve watched.
select 
	u.user_id,
    u.username
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
left join ratings as r
	on r.user_id = wh.user_id and wh.show_id = r.show_id
group by u.user_id, u.username
having count(distinct wh.show_id) = count(distinct r.show_id);


-- Query-10) Show each user’s favorite genre based on the most watched.
with users_favourite_genre as
(
select 
	u.user_id,
    u.username,
	s.genre,
    count(wh.watch_id) as watch_count
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
group by u.user_id, u.username, s.genre
order by u.user_id
)
select 
	user_id,
    username,
    genre,
    watch_count
from
(
select
	user_id,
    username,
    genre,
    watch_count,
    row_number() over (partition by user_id order by watch_count desc) as RNK
from users_favourite_genre
) as top_watched_genre
where RNK = 1;

-- Query-11) Find users who have watched more than one genre.
select 
	u.user_id,
    u.username
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
group by u.user_id, u.username
having count(distinct genre) > 1;

-- Query-12) Retrieve shows that have never been rated.
select 
	s.show_id,
    s.title
from shows as s
left join ratings as r	
	on s.show_id = r.show_id
where r.show_id is NULL;

-- Query-13) Find the earliest and latest watch date for each user.
select 
	u.user_id,
    u.username,
    min(wh.watch_date) as First_Watched_Date,
    max(wh.watch_date) as Latest_Watched_Date
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
group by u.user_id, u.username;

-- Query-14) Get average watch duration per show.
select 
	s.show_id,
    s.title,
    round(avg(wh.watch_duration_minutes),2) as average_show_duration
from shows as s
join watchhistory as wh
	on s.show_id = wh.show_id
group by s.show_id, s.title
order by average_show_duration desc;

-- ======================================================== SUB-QUERIES + AGGREGATION =========================================================================

-- Query-15) Get the list of users who watched and rated the same show on the same day.
select 
	u.user_id,
    u.username
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join ratings as r
	on r.user_id = wh.user_id
where r.rating_date = wh.watch_date and wh.show_id = r.show_id;


-- Query-16) Find users who watched shows but didn’t rate them.
select 
	u.user_id,
    u.username
from users as u
join watchhistory as wh
	on wh.user_id = u.user_id
left join ratings as r
	on u.user_id = r.user_id and r.show_id = wh.show_id
where r.rating_id is NULL;

-- Query-17) Show the highest-rated show in each genre.
with highest_rated_shows as
(
select 
	s.show_id,
    s.title,
    s.genre,
    r.rating,
    rank() over (partition by s.genre order by r.rating desc) as RNK
from shows as s
join ratings as r
	on s.show_id = r.show_id
)
select
	show_id,
    title,
    genre,
    rating
from highest_rated_shows
where RNK = 1;

-- Query-18) Return shows where the average rating is higher than the average rating of all shows.
with average_show_rating as
(
select
	s.show_id,
    s.title,
    round(avg(r.rating),2) as average_show_rating
from shows as s
join ratings as r
	on s.show_id = r.show_id
group by s.show_id, s.title
),
average_rating as
(
select
	avg(r.rating) as average_rating
from ratings as r
)
select
	show_id,
    title,
    average_show_rating
from average_show_rating as a, average_rating as o
where a.average_show_rating > o.average_rating;

-- ============================================================= WINDOW FUNCTION ==================================================================
-- Query-19) For each user, show the most recent show they watched with the watch date.
with most_recent_watched_show as 
(
select 
	u.user_id,
    u.username,
    s.title,
    wh.watch_date,
    rank() over (partition by u.user_id order by wh.watch_date desc) as RNK
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
)
select
	user_id,
    username,
    title,
    watch_date
from most_recent_watched_show
where RNK = 1;


-- Query-20) Rank shows based on average rating within each genre.
with average_genre_rating as
(
select 
	s.genre,
    round(avg(r.rating),2) as average_rating
from shows as s
join ratings as r
	on s.show_id = r.show_id
group by s.genre
)
select
	genre,
    average_rating,
    rank() over (order by average_rating desc) as RNK
from average_genre_rating;

-- Query-21) For each user, calculate the cumulative watch time ordered by watch date.
select 
	u.user_id,
    u.username,
    wh.watch_duration_minutes,
    sum(wh.watch_duration_minutes) over (partition by u.user_id order by wh.watch_date) as cumulative_watch_duration
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id;
    
-- Query-22) Identify top 2 most-watched shows per user using DENSE_RANK
with top_2_shows as
(
select 
	u.user_id,
    u.username,
    wh.show_id,
    s.title,
    count(*) as watch_count,
    dense_rank() over (partition by u.user_id order by  count(*) desc) as dense_rank_
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
group by u.user_id, u.username, wh.show_id, s.title
)
select
	user_id,
    username,
    show_id,
    title
from top_2_shows
where dense_rank_ <= 2;

-- ============================================================= CASE + VIEWS ==================================================================

-- Query-23) Create a CTE that shows user activity (number of shows watched, total minutes).
with user_activity as
(
select 
	u.user_id,
    u.username,
    count(wh.show_id) as watched_show_count,
    sum(wh.watch_duration_minutes) as total_minutes
from users as u
join WatchHistory as wh
	on u.user_id = wh.user_id
group by u.user_id, u.username
order by total_minutes desc
)
select *
from user_activity;

-- Query-24) Create a view that lists each show’s average rating and number of ratings.
create or replace view average_ratings_per_show as 
select 
	s.show_id,
    s.title,
    round(avg(r.rating),2) as average_rating,
    count(r.rating_id) as number_of_rating
from shows as s
join ratings as r
	on s.show_id = r.show_id
group by s.show_id, s.title
order by number_of_rating desc;

select * from average_ratings_per_show;


-- Query-25) Use INTERSECT to find users who watched both Dark Matter and Casa de Papel.
select 
	u.user_id,
    u.username
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
where s.title = 'Dark Matter'

INTERSECT

select 
	u.user_id,
    u.username
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
where s.title = 'Casa de Papel';


-- Query-26) Use EXCEPT to find shows that were watched but not rated by any user.
select
	distinct wh.show_id
from watchhistory as wh

EXCEPT

select
	distinct show_id
from ratings as r;

-- ============================================================= COMPLEX LOGIC ==================================================================

-- Query-27) Identify users who watched shows from 3 or more different languages.
select 
	u.user_id,
    u.username,
    count(distinct s.language) as language_count
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
join shows as s
	on s.show_id = wh.show_id
group by u.user_id, u.username
having count(distinct s.language) >= 3;

-- Query-28) List users who rated shows from every genre available.
with total_genre as 
(
select
	count(genre) as total_genre
from shows
),
user_genre_count as 
(
select 
	r.user_id,
    count(distinct s.genre) as rated_genre_count
from ratings as r
join shows as s
	on s.show_id = r.show_id
group by r.user_id
)
select
	u.user_id,
    u.username
from users u
join user_genre_count ugc
	on u.user_id = ugc.user_id
join total_genre as tg
	on 1 = 1
where ugc.rated_genre_count = tg.total_genre;

-- Query-29) Identify time gaps in each user’s watch history (days between consecutive watches).
select 
	u.user_id,
    u.username,
    wh.watch_date,
    lag(wh.watch_date) over (partition by u.user_id order by wh.watch_date) as prev_watch_date,
    datediff(wh.watch_date, lag(wh.watch_date) over (partition by u.user_id order by wh.watch_date)) as gap_days
from users as u
join watchhistory as wh
	on u.user_id = wh.user_id
order by u.user_id, wh.watch_date;
