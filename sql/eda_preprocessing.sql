-- ============================================
-- Project: Appliance/Device Usage Classification
--File: eda.sql
--============================================

/*Creating the DB that is going to hold my data*/
CREATE TABLE device_usage (
Time TEXT, 
Fridge REAL, 
Dishwasher REAL,
TumbleDryer REAL, 
WashingMachine REAL, 
Kettle REAL
);

/*Counting the rows*/
SELECT count(*) AS n_rows
FROM device_usage;

/*Checking the time range*/
SELECT
MIN(Time) AS start_time,
MAX(Time) AS end_time
FROM device_usage;

/*Searching for missing values in every attribute*/
SELECT 
SUM(Fridge IS NULL) AS missing_fridge,
SUM(Dishwasher IS NULL) AS missing_dishwasher,
SUM(TumbleDryer IS NULL) AS missing_tumbledryer,
SUM(WashingMachine IS NULL) AS missing_washingmachine,
SUM(Kettle IS NULL) AS missing_kettle
FROM device_usage;

/*Checking for duplicates*/
SELECT
COUNT(*) AS n_rows,
COUNT(DISTINCT Time) AS n_distinct_time,
COUNT(*) - COUNT(DISTINCT Time) AS n_duplicates
FROM device_usage;

/*Checking for missing timestamps*/
WITH t AS (
SELECT
Time, 
LAG(Time) OVER (ORDER BY Time) AS prev_time
FROM device_usage
),
diffs AS (
SELECT
Time,
prev_time,
(strftime('%s', Time) - strftime('%s', prev_time)) AS diff_seconds
FROM t
WHERE prev_time IS NOT NULL
)
SELECT
COUNT(*) AS n_checked,
SUM(diff_seconds <> 60) AS n_not_60sec,
MIN(diff_seconds) AS min_diff,
MAX(diff_seconds) AS max_diff
FROM diffs;

/*Extracting hour-of-day and weekday features from the timestamp*/
SELECT
Time,
CAST(strftime('%H', datetime(Time)) AS INTEGER) AS hour,
CAST(strftime('%w', datetime(Time)) AS INTEGER) AS weekday
FROM device_usage
LIMIT 10;

/*Typical day profile*/
--Average power per device for each hour of the day
SELECT
CAST(strftime('%H', datetime(Time)) AS INTEGER) AS hour,
AVG(Fridge) AS avg_fridge,
AVG(Dishwasher) AS avg_dishwasher,
AVG(TumbleDryer) AS avg_tumbledryer,
AVG(WashingMachine) AS avg_washingmachine,
AVG(Kettle) AS avg_kettle
FROM device_usage
GROUP BY hour
ORDER BY hour;

/*Typical week profile*/
--Average power per device for each weekday
SELECT
CAST(strftime('%w', datetime(Time)) AS INTEGER) AS weekday,
AVG(Fridge) AS avg_fridge,
AVG(Dishwasher) AS avg_dishwasher,
AVG(TumbleDryer) AS avg_tumbledryer,
AVG(WashingMachine) AS avg_washingmachine,
AVG(Kettle) AS avg_kettle
FROM device_usage
GROUP BY weekday
ORDER BY weekday;

/*Creating VIEWS for easier usage of typical days/weekdays*/
CREATE VIEW IF NOT EXISTS typical_day AS
SELECT
CAST(strftime('%H', datetime(Time)) AS INTEGER) AS hour,
AVG(Fridge) AS avg_fridge,
AVG(Dishwasher) AS avg_dishwasher,
AVG(TumbleDryer) AS avg_tumbledryer,
AVG(WashingMachine) AS avg_washingmachine,
AVG(Kettle) AS avg_kettle
FROM device_usage
GROUP BY hour;

CREATE VIEW IF NOT EXISTS typical_week AS
SELECT
CAST(strftime('%w', datetime(Time)) AS INTEGER) AS weekday,
AVG(Fridge) AS avg_fridge,
AVG(Dishwasher) AS avg_dishwasher,
AVG(TumbleDryer) AS avg_tumbledryer,
AVG(WashingMachine) AS avg_washingmachine,
AVG(Kettle) AS avg_kettle
FROM device_usage
GROUP BY weekday;