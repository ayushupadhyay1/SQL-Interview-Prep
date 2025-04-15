-- --------------------------------------------------------- PART-1 (EASY) -----------------------------------------------------------------
-- Query-1) List all users who have watched any movie.
SELECT DISTINCT
    u.user_id, u.name
FROM
    watch_history AS wh
        LEFT JOIN
    users AS u ON wh.user_id = u.user_id
WHERE
    wh.user_id IS NOT NULL
ORDER BY u.user_id;

-- Query-2) Show each movie along with its genre and release year.
SELECT 
    movie_id, title, genre, release_year
FROM
    movies;

-- Query-3) List all watch history records with movie titles instead of movie IDs.
SELECT 
    user_id, m.title, watch_date, watch_time_mins, rating
FROM
    watch_history AS wh
        JOIN
    movies AS m ON m.movie_id = wh.movie_id;

-- Query-4) Find the total number of movies watched by each user.
SELECT 
    user_id, COUNT(movie_id) AS total_watched_movies
FROM
    watch_history
GROUP BY user_id;

-- --------------------------------------------------------- PART-2 (Medium) -----------------------------------------------------------------

SELECT 
    user_id, ROUND(AVG(rating), 2) AS average_rating
FROM
    watch_history
GROUP BY user_id;


-- Query-2) Find users who have watched more than one Sci-Fi movie.

    

-- Query-3) Show the top 3 highest-rated movies based on average ratings.
SELECT 
    m.movie_id,
    m.title,
    ROUND(AVG(wh.rating), 2) AS Highest_Rated_Movies
FROM
    movies AS m
        JOIN
    watch_history AS wh ON m.movie_id = wh.movie_id
GROUP BY m.movie_id , m.title
ORDER BY Highest_Rated_Movies DESC
LIMIT 3;

-- Query-4) For each genre, find the total watch time by all users.
SELECT 
    genre, SUM(wh.watch_time_mins) AS total_duration
FROM
    movies AS m
        JOIN
    watch_history AS wh ON m.movie_id = wh.movie_id
GROUP BY genre;

-- Query-5) Display user names and the count of unique movies they have watched.
SELECT 
    u.Name, COUNT(DISTINCT wh.movie_id) AS movie_count
FROM
    users AS u
        JOIN
    watch_history AS wh ON u.user_id = wh.user_id
GROUP BY u.Name;
    

-- Query-6) Find the most watched movie (by count).
SELECT 
    m.title, COUNT(wh.movie_id) AS movie_count
FROM
    movies AS m
        JOIN
    watch_history AS wh ON m.movie_id = wh.movie_id
GROUP BY m.title
ORDER BY movie_count DESC
LIMIT 1;

-- Query-7) Get the first movie each user watched (based on watch_date).
SELECT 
    u.Name, MIN(wh.watch_date) AS First_Watched_Movie
FROM
    users AS u
        JOIN
    watch_history AS wh ON u.user_id = wh.user_id
GROUP BY u.name;


-- Query-8) Show users who upgraded from Basic to Premium plans.


-- Query-9) Find movies that have never been watched.
SELECT 
    m.title
FROM
    movies AS m
        LEFT JOIN
    watch_history AS wh ON m.movie_id = wh.movie_id
WHERE
    wh.movie_id IS NULL;

-- Query-10) Show movies watched for less than their full duration.
SELECT 
    m.title, m.duration_mins, wh.watch_time_mins
FROM
    movies AS m
        JOIN
    watch_history AS wh ON m.movie_id = wh.movie_id
WHERE
    wh.watch_time_mins < m.duration_mins;

-- Query-11) For each user, calculate total time spent watching movies.
SELECT 
    u.name, SUM(wh.watch_time_mins) AS total_time_spent
FROM
    users AS u
        JOIN
    watch_history AS wh ON u.user_id = wh.user_id
GROUP BY u.name
ORDER BY total_time_spent DESC;

-- Query-12) For each subscription plan, calculate the number of active users in March 2023.
SELECT 
    s.plan, COUNT(DISTINCT wh.user_id) AS Active_User_Count
FROM
    subscriptions AS s
        JOIN
    watch_history AS wh ON s.user_id = wh.user_id
WHERE
    DATE_FORMAT(watch_Date, '%M-%Y') = 'March-2023'
GROUP BY s.plan;

-- --------------------------------------------------------- PART-3 (Hard) -----------------------------------------------------------------

-- Query-1) Find the top 2 genres per country by total watch time using window functions.
select *
from 
(
select 
	dense_rank() over (partition by u.country order by sum(wh.watch_time_mins) desc) as top_watched_genres,
	u.country,
    m.genre
from movies as m
join watch_history as wh
	on m.movie_id = wh.movie_id
join users as u
	on u.user_id = wh.user_id
group by u.country,
m.genre
) as top_genre
where top_watched_genres <= 2;

-- Query-2) For each user, find the movie with the highest rating they've given (if tie, show latest).
select
	u.name,
    m.title,
    wh.rating,
    wh.watch_history
from 
(
select 
	u.user_id,
    m.title,
    wh.rating,
    wh.watch_Date,
    row_number() over (partition by u.user_id order by wh.rating desc, wh.watch_Date desc) as rnk
from users as u
join watch_history as wh
    on u.user_id = wh.user_id
join movies as m
	on m.movie_id = wh.movie_id
) as rating
where rnk = 1;

-- Query-3) Create a rolling 7-day average rating for each movie based on watch date.
select
	m.title,
    wh.rating,
    wh.watch_date,
    round(avg(wh.rating) over (partition by m.title order by wh.watch_Date rows between 6 preceding and current row),2) as rolling_average
from watch_history as wh
join movies as m
	on wh.movie_id = m.movie_id
order by m.title, wh.watch_Date;

-- Query-4) For each user, calculate the time gap between each consecutive movie watched.
select
	u.Name,
    m.Title,
    wh.watch_Date,
    datediff(wh.watch_Date, LAG(wh.watch_Date) over (partition by u.user_id order by wh.watch_Date)) as day_since_previous
from users as u
join watch_history as wh
	on u.user_id = wh.user_id
join movies as m
	on m.movie_id = wh.movie_id;


