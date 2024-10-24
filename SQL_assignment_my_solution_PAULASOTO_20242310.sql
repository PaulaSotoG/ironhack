-- LEVEL 1

-- Question 1: Number of users with sessions
SELECT COUNT(DISTINCT user_id) AS Num_Users_With_Sessions
FROM sessions
WHERE user_id IS NOT NULL;

-- Question 2: Number of chargers used by user with id 1

SELECT user_id,
    COUNT(charger_id) AS Num_Chargers_By_UserId1
FROM sessions
WHERE user_id = 1;


-- LEVEL 2

-- Question 3: Number of sessions per charger type (AC/DC):

SELECT * FROM sessions;
SELECT * FROM chargers;

SELECT c.type,
    COUNT(s.id) AS Num_Sessions_Per_Charger_AC_DC
FROM chargers AS c
LEFT JOIN sessions AS s
ON c.id = s.charger_id
WHERE c.type IN ('AC', 'DC')
GROUP BY c.type
ORDER BY COUNT(s.id) DESC;

-- Question 4: Chargers being used by more than one user

SELECT charger_id,
    COUNT(user_id) Num_Users_Per_Charger
FROM sessions
GROUP BY charger_id
HAVING COUNT(user_id) > 1
ORDER BY COUNT(user_id) DESC;

-- Question 5: Average session time per charger

SELECT * FROM sessions;

SELECT charger_id,
    ROUND(AVG(julianday(end_time) - julianday(start_time))* 24 * 60,2) AS Avg_Minutes_Charger_Session
FROM sessions
GROUP BY charger_id;


-- LEVEL 3

-- Question 6: Full username of users that have used more than one charger in one day (NOTE: for date only consider start_time)

SELECT u.name || ' ' || u.surname AS full_username
FROM users u
LEFT JOIN sessions s
ON u.id = s.user_id
WHERE DATE(s.start_time) IN(
    SELECT DATE(s.start_time)
    FROM sessions s
    JOIN chargers c
    ON c.id = s.charger_id
    GROUP BY DATE(s.start_time)
    HAVING COUNT(DISTINCT c.type) > 1
    )
GROUP BY full_username;

-- Question 7: Top 3 chargers with longer sessions

SELECT 
    charger_id,
    ROUND(MAX((julianday(end_time) - julianday(start_time)) * 24 * 60), 2) AS max_session_duration_charger
FROM 
    sessions
GROUP BY 
    charger_id
ORDER BY 
    max_session_duration_charger DESC
LIMIT 3;

-- Question 8: Average number of users per charger (per charger in general, not per charger_id specifically)

SELECT 
    AVG(num_users) AS avg_users_per_charger
FROM (
    SELECT charger_id,
    COUNT(DISTINCT user_id) AS num_users
    FROM sessions
    GROUP BY charger_id
);

-- Question 9: Top 3 users with more chargers being used

SELECT user_id,
    COUNT(DISTINCT charger_id) AS num_chargers_used_user
FROM sessions
GROUP BY user_id
ORDER BY num_chargers_used_user DESC
LIMIT 3;


-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both

SELECT 
    COUNT(DISTINCT CASE WHEN charger_type = 'AC Only' THEN user_id END) AS users_ac_only,
    COUNT(DISTINCT CASE WHEN charger_type = 'DC Only' THEN user_id END) AS users_dc_only,
    COUNT(DISTINCT CASE WHEN charger_type = 'Both' THEN user_id END) AS users_both
FROM (
    SELECT 
        user_id,
        CASE 
            WHEN COUNT(DISTINCT c.type) = 1 AND MIN(c.type) = 'AC' THEN 'AC Only'
            WHEN COUNT(DISTINCT c.type) = 1 AND MIN(c.type) = 'DC' THEN 'DC Only'
             WHEN COUNT(DISTINCT c.type) = 2 
                 AND MIN(c.type) = 'AC' 
                 AND MAX(c.type) = 'DC' THEN 'Both'
        END AS charger_type
    FROM 
        sessions s
        JOIN chargers c ON s.charger_id = c.id
    GROUP BY 
        user_id
) AS users_charger;



/*
create view codificado as
select *, iif(type = 'AC', 1, 2) as cod from session_type
group by user_id, type;
select * from codificado;
select user_id, sum(cod) as 'OnlyAC = 1, OnlyDC = 2, Both = 3' from codificado
group by user_id;
select cod, count(user_id) as cantidad from (select user_id, sum(cod) as cod from codificado
group by user_id)
group by cod; */


-- Question 11: Monthly average number of users per charger

SELECT 
    charger_id,
    AVG(num_users) AS avg_users_per_month
FROM (
    SELECT 
        charger_id,
        COUNT(DISTINCT user_id) AS num_users,
        strftime('%Y-%m', start_time) AS month
    FROM 
        sessions
    GROUP BY 
        charger_id,
        month
) AS monthly_data
GROUP BY 
    charger_id;


-- Question 12: Top 3 users per charger (for each charger, number of sessions)

SELECT charger_id,
    user_id,
    num_sessions_user,
    Ranks
FROM(
    SELECT charger_id,
        user_id,
        COUNT(start_time) AS num_sessions_user,
        RANK() OVER (PARTITION BY user_id ORDER BY COUNT(start_time) DESC) AS Ranks
    FROM sessions
    GROUP BY charger_id, 
    user_id)
WHERE Ranks <= 3
ORDER BY charger_id,
    num_sessions_user;
    

-- LEVEL 5
-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)

SELECT 
    user_id,
    month,
    ROUND((julianday(end_time) - julianday(start_time)) * 24 * 60, 2) AS minutes_Session,
    session_rank
FROM (
    SELECT 
        *,
        strftime('%Y-%m', start_time) AS month,
        ROUND((julianday(end_time) - julianday(start_time)) * 24 * 60, 2) AS session_duration_minutes,
        RANK() OVER (PARTITION BY strftime('%Y-%m', start_time) ORDER BY (julianday(end_time) - julianday(start_time)) DESC) AS session_rank
    FROM 
        sessions
)
WHERE 
    session_rank <= 3
ORDER BY 
    month, session_rank;


-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)

SELECT 
    charger_id,
    strftime('%Y-%m', start_time) AS month,
    ROUND(AVG((julianday(start_time) - julianday(prev_end_time)) * 24 * 60), 2) AS Avg_Minutes_Charger_Between_Session
FROM (
    SELECT 
        charger_id,
        start_time,
        end_time,
        LAG(end_time) OVER(PARTITION BY charger_id ORDER BY start_time) AS prev_end_time
    FROM 
        sessions
) AS session_diffs
WHERE 
    prev_end_time IS NOT NULL
    AND prev_end_time < start_time 
GROUP BY 
    charger_id,
    month;

