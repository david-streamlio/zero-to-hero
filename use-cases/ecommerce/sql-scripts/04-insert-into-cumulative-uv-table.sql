INSERT INTO cumulative_uv
SELECT date_str, MAX(time_str), COUNT(DISTINCT user_id) as uv
FROM (
         SELECT
             DATE_FORMAT(ts, 'yyyy-MM-dd') as date_str,
             SUBSTR(DATE_FORMAT(ts, 'HH:mm'),1,4) || '0' as time_str,
             user_id
         FROM user_behavior)
GROUP BY date_str;