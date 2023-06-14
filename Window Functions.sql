USE ebbu;
USE campusx;

SELECT * ,AVG(marks) OVER(PARTITION BY branch) FROM ebbu.marks;

-- Finding minimum and maximum marks of the student

SELECT * ,
AVG( marks) OVER () AS 'overall_avg',
MIN(marks) OVER(),
MAX(marks) OVER(),
MIN(marks) OVER(PARTITION BY branch),
MAX(marks) OVER(PARTITION BY branch)
FROM marks
ORDER BY student_id;

-- Find all the students who have marks higher than the avg marks of thier Respective branch

SELECT * FROM (SELECT * , AVG(marks) 
			   OVER( PARTITION BY branch) AS 'avg_marks'
			   FROM marks ) t1
			   WHERE t1.marks > t1.avg_marks;
               
-- RANK /DENSE RANK/ROW_NUMBER

-- Rank all the students rank on overall data
SELECT *, 
RANK() OVER(ORDER BY marks DESC)
FROM marks;

-- Rank all the students rank on overall marks data by branch

SELECT *, 
RANK() OVER(PARTITION BY branch ORDER BY marks DESC)
FROM marks;

-- DENSE RANK()

SELECT *, 
RANK() OVER(PARTITION BY branch ORDER BY marks DESC),
DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC)
FROM marks;

-- ROW_NUMBER()

SELECT * ,
ROW_NUMBER() OVER (PARTITION BY branch)
FROM marks;

-- with CONCAT
-- DENSE RANK()

SELECT *, 
CONCAT(branch, '-', ROW_NUMBER() OVER(PARTITION BY branch ))
FROM marks;

-- for extracting dates and moths
SELECT date ,MONTH(date) , MONTHNAME(date) FROM orders;

-- Find top 2 most paying customers of each month
SELECT * FROM  (SELECT MONTHNAME(date) AS 'month' ,user_id , 
				SUM(amount)AS 'total' ,
				RANK() OVER (PARTITION BY MONTHNAME(date)
                ORDER BY SUM(amount)DESC) AS 'month_rank'
				FROM orders
				GROUP BY MONTHNAME(date) ,user_id 
				ORDER BY  MONTH(date)) t
                WHERE t.month_rank < 3
                ORDER BY month DESC , month_rank ASC;
                
-- FIRST_VALUE/LAST_VALUE/NTH_VALUE
 
SELECT * ,
FIRST_VALUE(marks) OVER(ORDER BY marks DESC) AS 'total_highest_marks'
FROM marks ;

-- LAST_VALUE by branch

SELECT * ,
LAST_VALUE(marks) OVER(PARTITION BY branch
ORDER BY marks DESC  
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'lowest_marks'
FROM marks ;

-- "DEFAULT FRAME"
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- NTH_VALUE by name with 2

SELECT * ,
NTH_VALUE(name,2) OVER(PARTITION BY branch
ORDER BY marks DESC  
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'nth_marks_names'
FROM marks ;

-- Find the branch toppers
SELECT name , branch , marks FROM (SELECT * ,
FIRST_VALUE(name) OVER( PARTITION BY branch ORDER BY marks DESC) AS 'topper_name',
FIRST_VALUE(marks) OVER( PARTITION BY branch ORDER BY marks DESC) AS 'topper_marks'
FROM marks) t
WHERE t.name = t.topper_name AND t.topper_marks;

-- LEAD/LAG 

SELECT * ,
LAG(marks) OVER(PARTITION BY branch ORDER BY student_id),
LEAD(marks) OVER(PARTITION BY branch ORDER BY student_id)
FROM marks;

-- Find the MoM( Month by Month) revenue growth of Zomato

SELECT MONTHNAME(date) , SUM(amount),
((SUM(amount) - LAG(SUM(amount)) OVER(ORDER BY MONTH(date))) / LAG(SUM(amount)) OVER(ORDER BY MONTH(date)))*100
FROM orders
GROUP BY MONTHNAME(date)
ORDER BY  MONTH(date) ASC;

 -- Windows Functions on ipl data
 -- RANKING

SELECT * FROM (SELECT BattingTeam , batter , SUM(batsman_run) 'total_runs',
DENSE_RANK() OVER( PARTITION BY BattingTeam ORDER BY SUM(batsman_run ) DESC) AS 'total_ranking'
FROM ipl
GROUP BY BattingTeam , batter ) t
WHERE t.total_ranking < 6
ORDER BY t.BattingTeam ,t.total_ranking;

-- CUMILATIVE SUM
-- V kohli CUMALITIVE SUM  of runs scored  on 50TH , 100TH ,200TH match

SELECT * FROM (SELECT 
CONCAT('Match-', CAST(ROW_NUMBER() OVER (ORDER BY ID) AS CHAR)) AS match_no,
SUM(batsman_run) AS 'runs_scored',
SUM(SUM(batsman_run)) OVER( ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'cumative_sum'
FROM ipl
WHERE batter = 'V Kohli'
GROUP BY ID) t
WHERE match_no = 'MATCH-50' OR match_no = 'MATCH-100';

-- CUMILATIVE AVERAGE
-- V kohli CUMALITIVE AVERAGE  of run avg on 50TH , 100TH  

SELECT * FROM (SELECT 
CONCAT('Match-', CAST(ROW_NUMBER() OVER (ORDER BY ID) AS CHAR)) AS match_no,
SUM(batsman_run) AS 'runs_scored',
SUM(SUM(batsman_run)) OVER w AS 'carrer_runs',
AVG(SUM(batsman_run)) OVER w AS 'carrer_Avg'
FROM ipl
WHERE batter = 'V Kohli'
GROUP BY ID
-- we can use Window  function shorcut using this
WINDOW w AS (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) t
WHERE match_no = 'MATCH-50' OR match_no = 'MATCH-100';
 
-- RUNNING AVERAGE
-- V kohli RUNNING AVERAGE  from 5th match 

SELECT * FROM (SELECT 
CONCAT('Match-', CAST(ROW_NUMBER() OVER (ORDER BY ID) AS CHAR)) AS 'match_no',
SUM(batsman_run) AS 'runs_scored',
SUM(SUM(batsman_run)) OVER w AS 'carrer_runs',
AVG(SUM(batsman_run)) OVER w AS 'carrer_Avg',
AVG(SUM(batsman_run)) OVER (ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS 'rolling_Avg'
FROM ipl
WHERE batter = 'V Kohli'
GROUP BY ID
-- we can use Window  function shorcut using this
WINDOW w AS (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) t ;
 
 
 -- Percent of Total
 -- calculate the food items moslty saled by percentage
 
SELECT f_name , 
(total_value / SUM(total_value) OVER())*100 AS 'total_percentage'
FROM
  (SELECT f_id, SUM(amount) AS 'total_value'
   FROM orders t1
   JOIN order_details t2 ON t1.order_id = t2.order_id
   WHERE r_id = 2
   GROUP BY f_id) t
   JOIN food t3
   ON t.f_id = t3.f_id
   ORDER BY total_percentage DESC;
   
-- Percent by Change
-- Yotube views on the Montly bases

SELECT YEAR(Date) , MONTHNAME(Date) ,SUM(views) AS 'views',
((SUM(views) - LAG (SUM(views)) OVER(ORDER BY YEAR(Date), MONTH(Date))) / 
LAG (SUM(views)) OVER(ORDER BY YEAR(Date), MONTH(Date))) * 100 AS 'Percent_Chage'
FROM yotube_views
GROUP BY YEAR(Date) , MONTHNAME(Date) 
ORDER BY YEAR(Date) , MONTH(Date) ;

-- QUARTER BY QUARTER 

SELECT YEAR(Date) ,  QUARTER(Date) ,SUM(views) AS 'views',
((SUM(views) - LAG (SUM(views)) OVER(ORDER BY YEAR(Date),  QUARTER(Date))) / 
LAG (SUM(views)) OVER(ORDER BY YEAR(Date), QUARTER(Date))) * 100 AS 'Percent_Chage'
FROM yotube_views
GROUP BY YEAR(Date) ,  QUARTER(Date) 
ORDER BY YEAR(Date) , QUARTER(Date) ;

-- Weekly Percent change

SELECT * ,
((views - LAG(views , 7) OVER ( ORDER BY Date))/LAG(views , 7) OVER (ORDER BY Date))*100 AS 'Weekly_percent_change'
FROM youtube_views ;

-- PERCENTILE AND QUARTILES

-- Find the media marks of all students
SELECT *, 
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY marks) OVER() AS 'median_marks'
FROM marks;

-- Find branch wise median of Student marks

SELECT *, 
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY marks) OVER(PARTITION BY branch) AS 'median_marks'
FROM marks;

-- CONT -- Continuous

SELECT *, 
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY marks) OVER(PARTITION BY branch) AS 'median_marks_count'
FROM marks;

-- REMOVE OUTLIERS (IQR FORMULA)

SELECT * FROM (SELECT *, 
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY marks) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY marks) OVER() AS 'Q3'
FROM marks) t
WHERE t.marks > t.Q1 - (1.5*(t.Q3 -t.Q1)) AND
t.marks < t.Q3 + ( 1.5*(t.Q3 -t.Q1))
ORDER BY t.student_id; 

-- SEGEMENTATION ( NTILE)

SELECT *,
NTILE(3) OVER(ORDER BY marks DESC)  AS 'buckets'
FROM marks
ORDER BY student_id;

SELECT brand_name,model,price,
CASE
    WHEN bucket = 1 THEN 'budget'
    WHEN bucket =2 THEN 'mid-range'
    WHEN bucket =3 THEN 'premium'
END AS 'Phoe_type'
FROM(SELECT brand_name ,model,price ,
NTILE(3) OVER(ORDER BY price) AS 'bucket'
FROM smartphones) t;

-- CUMILATIVE DISTRIBUTION
 
SELECT * FROM ( SELECT * ,
 CUME_DIST() OVER(ORDER BY marks) AS'percentile_marks'
FROM marks
ORDER BY student_id) t
WHERE t.percentile_marks > 0.99;

-- PARTITION BY ON MULTIPLE COLUMNS
SELECT * FROM (
	SELECT source,destination,airline, AVG(price) AS 'avg_price',
	DENSE_RANK() OVER(PARTITION BY source ,destination ORDER BY AVG(price)) AS 'rank'
	FROM flights
	GROUP BY source , destination, airline) t
WHERE t .rank < 2









 
              
               
               
 

