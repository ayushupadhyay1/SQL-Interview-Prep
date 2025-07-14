-- ------------------------------------------------------------ DATASET --------------------------------------------------------------------------

create database twitter_analysis;

use twitter_analysis;

-- USERS table: user info
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(100),
    created_at DATE
);

INSERT INTO Users (user_id, username, full_name, email, created_at) VALUES
(1, 'jack', 'Jack Dorsey', 'jack@twitter.com', '2006-03-21'),
(2, 'elonmusk', 'Elon Musk', 'elon@twitter.com', '2009-06-01'),
(3, 'sundar', 'Sundar Pichai', 'sundar@twitter.com', '2010-01-15'),
(4, 'satya', 'Satya Nadella', 'satya@twitter.com', '2012-05-30'),
(5, 'sheryl', 'Sheryl Sandberg', 'sheryl@facebook.com', '2008-07-10');

-- TWEETS table: tweets posted by users
CREATE TABLE Tweets (
    tweet_id INT PRIMARY KEY,
    user_id INT,
    content VARCHAR(280),
    created_at TIMESTAMP,
    retweet_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Tweets (tweet_id, user_id, content, created_at, retweet_count) VALUES
(101, 1, 'Just setting up my twttr', '2006-03-21 15:00:00', 1000),
(102, 2, 'Mars colonization is the future!', '2024-04-12 10:30:00', 15000),
(103, 3, 'Excited about AI advancements', '2023-11-20 08:45:00', 800),
(104, 4, 'Cloud computing for everyone!', '2023-12-01 09:15:00', 500),
(105, 5, 'Women in tech are unstoppable', '2023-10-10 16:50:00', 1200);

-- FOLLOWERS table: who follows whom
CREATE TABLE Followers (
    follower_id INT,
    followee_id INT,
    followed_at DATE,
    PRIMARY KEY (follower_id, followee_id),
    FOREIGN KEY (follower_id) REFERENCES Users(user_id),
    FOREIGN KEY (followee_id) REFERENCES Users(user_id)
);

INSERT INTO Followers (follower_id, followee_id, followed_at) VALUES
(2, 1, '2009-06-02'),
(3, 1, '2010-02-10'),
(4, 1, '2012-06-15'),
(5, 1, '2008-08-01'),
(1, 2, '2006-04-01'),
(3, 2, '2010-05-15'),
(4, 2, '2012-07-07'),
(5, 3, '2008-09-09');

-- LIKES table: users liking tweets
CREATE TABLE Likes (
    user_id INT,
    tweet_id INT,
    liked_at TIMESTAMP,
    PRIMARY KEY (user_id, tweet_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (tweet_id) REFERENCES Tweets(tweet_id)
);

INSERT INTO Likes (user_id, tweet_id, liked_at) VALUES
(2, 101, '2024-04-15 12:00:00'),
(3, 101, '2024-04-16 13:00:00'),
(4, 102, '2024-04-17 14:00:00'),
(5, 103, '2024-04-18 15:00:00'),
(1, 104, '2024-04-19 16:00:00'),
(2, 105, '2024-04-20 17:00:00');

-- ----------------------------------------------------------- BASIC LEVEL -------------------------------------------------------------------
-- Query-1) Select all users who joined before 2010.
select
	user_id,
    username,
    full_name,
    created_at
from users 
where created_at < '2010-01-01';

-- Query-2) Retrieve all tweets with more than 1000 retweets.
select
	*
from tweets
where retweet_count > 1000;

-- Query-3) Find the username and email of all users who have never tweeted.
select 
	u.user_id,
    u.username,
    u.email
from tweets as t
left join users as u
	on u.user_id = t.user_id
where t.user_id is NULL;

-- Query-4) List all tweets posted by user 'jack'.
select 
    u.user_id,
    u.username,
	t.tweet_id,
    t.content
from tweets as t
join users as u
	on t.user_id = u.user_id
where u.username = 'jack';

-- Query-5) Count how many followers user 'jack' has.
select 
	u.user_id,
    u.username,
    count(f.follower_id) as follower_count
from users as u
join followers as f	
	on u.user_id = f.followee_id
where u.username = 'jack'
group by u.user_id, u.username;

-- ----------------------------------------------------------- INTERMEDIATE LEVEL -------------------------------------------------------------------

-- Query-6) Find the top 3 users with the most tweets.
select
	u.user_id,
    u.username,
    count(tweet_id) as tweet_count
from users as u
join tweets as t	
	on t.user_id = u.user_id
group by u.user_id, u.username
order by tweet_count desc
limit 3;

-- Query-7) Retrieve tweets along with the username of the author.
select 
	t.tweet_id,
    u.username,
    u.full_name
from tweets as t
join users as u
	on t.user_id = u.user_id;

-- Query-8) Find users who follow 'elonmusk' but 'elonmusk' does not follow back.
select 
	f.follower_id as user_id,
    u.username
from users as u
join followers as f
	on u.user_id = f.follower_id
where f.followee_id = 2
and f.follower_id NOT IN(
select followee_id
from followers
where follower_id = 2
);


-- Query-9) List all tweets that have been liked by user 'sheryl'.
select 
	t.tweet_id,
    t.content,
    u.user_id,
    u.username
from likes as l
join tweets as t
	on l.tweet_id = t.tweet_id
join users as u
	on u.user_id = t.user_id
where l.user_id = (select user_id from users where username = 'Sheryl');

-- Query-10) Calculate the average number of retweets per user.
select 
	u.user_id,
    u.username,
    round(avg(t.retweet_count),2) as average_retweet_count
from tweets as t
join users as u
	on t.user_id = u.user_id
group by u.user_id, u.username
order by average_retweet_count desc;

-- ----------------------------------------------------------- ADVANCED LEVEL -------------------------------------------------------------------

-- Query-11) For each user, get the total number of likes received on their tweets.
with user_and_tweet as
(
select 
	u.user_id,
    u.username,
    t.tweet_id
from users as u
join tweets as t
	on u.user_id = t.user_id
order by u.user_id
),
tweets_and_likes as
(
select 
	t.tweet_id,
	count(l.user_id) as like_count
from tweets as t
join likes as l
	on t.tweet_id = l.tweet_id
group by t.tweet_id
)
select
	u.user_id,
    u.username,
    sum(t.like_count) as total_number_of_likes
from user_and_tweet as u
join tweets_and_likes as t
	on u.tweet_id = t.tweet_id
group by u.user_id, u.username
order by total_number_of_likes desc;


-- Query-12) Find users who have liked their own tweets.
select distinct	
	u.user_id,
    u.username
from likes as l
join tweets as t
	on l.tweet_id = t.tweet_id
join users as u
	on u.user_id = t.user_id
where l.user_id = t.user_id;

-- Query-13) List all users who have no followers.
select 
	u.user_id,
    u.username,
    count(f.follower_id) as follower_count
from users as u
left join followers as f
	on u.user_id = f.followee_id
group by u.user_id, u.username
having count(f.follower_id) = 0;


-- Query-14) Retrieve tweets along with the number of likes and retweets, ordered by total engagement (likes + retweets).
select 
	t.tweet_id,
    count(l.user_id) as like_count,
    t.retweet_count,
    (count(l.user_id) + t.retweet_count) as total_engagement
from tweets as t
left join likes as l
	on t.tweet_id = l.tweet_id
group by t.tweet_id, retweet_count
order by total_engagement desc;

-- Query-15) Find the most recent tweet liked by each user.
with most_recent_tweet_liked as
(
select 
	u.user_id,
    u.username,
    t.tweet_id,
    l.liked_at,
    rank() over (partition by u.user_id order by  l.liked_at desc) as rnk
from likes as l
join tweets as t
	on l.tweet_id = t.tweet_id
join users as u
	on u.user_id = l.user_id
)
select
	user_id,
    username,
    tweet_id,
    liked_at
from most_recent_tweet_liked
where rnk = 1;


-- ----------------------------------------------------------- EXPERT LEVEL -------------------------------------------------------------------

-- Query-16) Using window functions, rank users by total retweets across all their tweets.
with total_retweer_count as
(
select 
	u.user_id,
    u.username,
    sum(t.retweet_count) as total_retweets
from users as u
join tweets as t
	on u.user_id = t.user_id
group by u.user_id, u.username
)
select
	user_id,
    username,
    total_retweets,
    rank() over (order by total_retweets desc) as rnk
from total_retweer_count;


-- Query-17) Find the day with the highest number of tweets posted.
select
	date(created_at) as tweet_post_date,
    count(tweet_id) as tweet_count
from tweets as t
group by date(created_at)
order by tweet_count desc
limit 1;

-- Query-18) Calculate a running total of likes for tweets ordered by creation date.
select 
	t.tweet_id,
    t.created_at,
    count(l.user_id) as likes,
    sum(count(l.user_id)) over (order by t.created_at asc) as running_total_of_likes
from tweets as t
join likes as l
	on t.tweet_id = l.tweet_id
group by t.tweet_id, t.created_at
order by t.created_at asc;







