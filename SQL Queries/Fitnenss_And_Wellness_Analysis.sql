use Fitness_And_Wellness_Analysis;

-- ============================================================ EASY =============================================================================

-- Query-1) List all users who registered after February 2023.
select
	user_id,
    name,
    registration_date
from users 
where registration_date > '2023-02-28';

-- Query-2) Find the average calories burned for each workout type.
select
	workout_type,
    round(avg(calories_burned),0) as average_burned_calories
from workouts 
group by workout_type
order by average_burned_calories desc;

-- Query-3) Show all sleep logs where sleep quality was ‘Excellent’.
select
	*
from sleep_logs 
where sleep_quality = 'Excellent';

-- Query-4) How many workouts has each user done?
select 
	u.user_id,
    u.name,
    count(w.workout_id) as workout_count
from users as u
left join workouts as w
	on w.user_id = u.user_id
group by u.user_id, u.name
order by workout_count desc;

-- Query-5) Retrieve the total calories intake per user.
select 
	u.user_id,
    u.name,
    sum(n.calories_intake) as total_calories_intake
from users as u
left join nutrition_logs as n
	on u.user_id = n.user_id
group by u.user_id, u.name
order by u.user_id, u.name;

-- ============================================================ MEDIUM =============================================================================

-- Query-6) Find users who have done both ‘Running’ and ‘Swimming’ workouts.
select
	u.user_id,
    u.name
from users as u
join workouts as w
	on u.user_id = w.user_id
where w.workout_type in ('Running', 'Swimming')
group by u.user_id, u.name
having count(distinct w.workout_type) = 2;


-- Query-7) Show the day when each user had their highest calorie intake.
with highest_calories_intake as
(
select 
	u.user_id,
    u.name,
    n.log_date,
    n.calories_intake,
    rank() over (partition by u.user_id order by n.calories_intake desc) as rn
from users as u
join nutrition_logs as n
	on u.user_id = n.user_id
)
select
	user_id,
    name,
    log_date,
    calories_intake
from highest_calories_intake
where rn=1;

-- Query-8) List users who slept less than 6 hours but still burned more than 300 calories on the same day.
select 
	u.user_id,
    u.name,
    s.sleep_hours,
    w.calories_burned
from users as u
join sleep_logs as s
	on u.user_id = s.user_id
join workouts as w
	on w.user_id = u.user_id
where s.sleep_hours < 6 and w.calories_burned > 300 
and s.sleep_date = w.workout_date;

-- Query-9) Calculate average protein intake grouped by gender.
select 
	u.gender,
    round(avg(n.protein_grams),2) as average_protein_intake
from users as u
join nutrition_logs as n
	on u.user_id = n.user_id
group by u.gender
order by average_protein_intake desc;

-- Query-10) Show all users who worked out at least 3 times in the first 7 days of June 2023.
select 
	u.user_id,
    u.name,
    count(w.workout_id) as workout_count
from users as u
join workouts as w
	on u.user_id = w.user_id
where w.workout_date between '2023-06-01' and '2023-06-07'
group by u.user_id, u.name
having count(w.workout_id) >= 3;

-- ============================================================ HARD =============================================================================

-- Query-11) Find the rolling 2-day average sleep hours for each user.
with rolling_2_avg_sleep as
(
select 
	u.user_id,
    u.name,
    s.sleep_hours,
    round(avg(s.sleep_hours) over (partition by u.user_id order by s.sleep_hours),2)as rolling_sleep_for_2_days,
    row_number() over (partition by u.user_id) as rn
from users as u
join sleep_logs as s
	on u.user_id = s.user_id
group by u.user_id, u.name, s.sleep_hours
)
select
	user_id,
    name,
    sleep_hours,
    rolling_sleep_for_2_days
from rolling_2_avg_sleep
where rn <= 2;


-- Query-12) Show the difference between calorie intake and calories burned per user per day.
select 
	u.user_id,
    u.name,
    w.workout_date,
    n.log_date,
    n.calories_intake,
    w.calories_burned,
    (n.calories_intake - w.calories_burned) as difference
from users as u
join nutrition_logs as n
	on u.user_id = n.user_id
join workouts as w
	on w.user_id = u.user_id
where w.workout_date = n.log_date
order by u.user_id, n.log_date;

-- Query-13) List the users who improved their sleep quality over consecutive days (e.g., from Fair → Good → Excellent).
WITH sleep_quality_ranked AS (
  SELECT 
    u.user_id,
    u.name,
    s.sleep_date,
    s.sleep_quality,
    CASE
      WHEN s.sleep_quality = 'Excellent' THEN 1
      WHEN s.sleep_quality = 'Good' THEN 2
      WHEN s.sleep_quality = 'Fair' THEN 3
      WHEN s.sleep_quality = 'Poor' THEN 4
      ELSE NULL
    END AS sleep_quality_score,
    LAG(CASE
      WHEN s.sleep_quality = 'Excellent' THEN 1
      WHEN s.sleep_quality = 'Good' THEN 2
      WHEN s.sleep_quality = 'Fair' THEN 3
      WHEN s.sleep_quality = 'Poor' THEN 4
      ELSE NULL
    END) OVER (
      PARTITION BY u.user_id 
      ORDER BY s.sleep_date
    ) AS prev_sleep_quality_score
  FROM users u
  JOIN sleep_logs s ON u.user_id = s.user_id
)
SELECT 
  user_id,
  name,
  sleep_date,
  sleep_quality,
  sleep_quality_score,
  prev_sleep_quality_score
FROM sleep_quality_ranked
WHERE prev_sleep_quality_score IS NOT NULL
  AND sleep_quality_score < prev_sleep_quality_score
ORDER BY user_id, sleep_date;


-- Query-14) Rank users by total calories burned in descending order and assign rank.
with total_burned_calories as 
(
select 
	u.user_id,
    u.name,
    sum(w.calories_burned) as total_burned_calories
from users as u
join workouts as w
	on u.user_id = w.user_id
group by u.user_id, u.name
)
select
	user_id,
    name,
    total_burned_calories,
    rank() over (order by total_burned_calories desc) as rnk
from total_burned_calories;


