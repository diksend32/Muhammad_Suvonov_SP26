-- Task 1
--Create a query for analyzing the annual sales data for the years 1999 to 2001, focusing on different sales channels and regions: 
--'Americas,' 'Asia,' and 'Europe.' 
-- I included 1998 in filter of t.calendar_year for avoid skipping the diff for 1999. This year will be skipped in the overall result since 
-- in  <<Where  c1.calendar_year - c2.calendar_year = 1>>    1997 is not exists
WITH cte1 AS (
SELECT  cn.country_region, t.calendar_year,  
		ch.channel_desc, SUM(s.amount_sold) AS amount_sold,
		ROUND((SUM(s.amount_sold))/(SUM(SUM(s.amount_sold)) OVER(PARTITION BY cn.country_region, t.calendar_year))*100,2) AS by_channels
FROM	sh.sales s
JOIN	sh.channels ch
		ON ch.channel_id = s.channel_id
JOIN	sh.times t
		ON t.time_id = s.time_id
JOIN	sh.customers cm
		ON cm.cust_id = s.cust_id
JOIN	sh.countries cn
		ON cm.country_id = cn.country_id
WHERE  t.calendar_year IN (1998, 1999, 2000, 2001) AND cn.country_region IN ('Americas', 'Asia', 'Europe')
GROUP BY cn.country_region, t.calendar_year,  ch.channel_desc
ORDER BY cn.country_region, t.calendar_year,  ch.channel_desc)
, cte2 AS(
SELECT   c1.country_region, c1.calendar_year, c1.channel_desc, c1.amount_sold, c1.by_channels,
		c1.by_channels - c2.by_channels AS diff
FROM	cte1 c1
JOIN	cte1 c2
		ON c1.country_region = c2.country_region AND c1.calendar_year - c2.calendar_year = 1 AND c1.channel_desc = c2.channel_desc
)
SELECT	*
FROM	cte2;

--Task 2
WITH cte AS (
SELECT  t.calendar_week_number, t.time_id, t.day_name, SUM(s.amount_sold) AS sales,
		SUM(SUM(s.amount_sold)) OVER(PARTITION BY t.calendar_week_number ORDER BY t.time_id) AS cum_sum,
		CASE 
		WHEN t.day_name = 'Monday' THEN AVG(SUM(s.amount_sold)) OVER(ORDER BY t.time_id ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING)
		WHEN t.day_name = 'Friday' THEN AVG(SUM(s.amount_sold)) OVER(ORDER BY t.time_id ROWS BETWEEN 1 PRECEDING AND 2 FOLLOWING)
        ELSE
		AVG(SUM(s.amount_sold)) OVER(ORDER BY t.time_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) END AS CENTERED_3_DAY_AVG
FROM	sh.sales s
JOIN	sh.times t
		ON t.time_id = s.time_id
WHERE   t.calendar_year = 1999 AND t.calendar_week_number IN (48, 49, 50, 51, 52)
GROUP BY t.calendar_week_number, t.time_id, t.day_name
)
SELECT	*
FROM	cte
WHERE	calendar_week_number IN (49, 50, 51);

--Task 3
--Please provide 3 instances of utilizing window functions that include a frame clause, using RANGE, ROWS, and GROUPS modes. 

SELECT	cust_id,  time_id, SUM(amount_sold) AS sales,
	SUM(SUM(amount_sold)) OVER(ORDER BY time_id ROWS BETWEEN 5 PRECEDING AND 4 FOLLOWING) AS ten_rows, --  take total sales of 10 rows
	SUM(SUM(amount_sold)) OVER(ORDER BY time_id RANGE BETWEEN INTERVAL '5 days' PRECEDING AND INTERVAL '4 days' FOLLOWING) AS ten_days, -- take total sales for 10 days
    SUM(SUM(amount_sold)) OVER(ORDER BY EXTRACT(YEAR FROM time_id) GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS three_years --take total sales for previous, current, and next year groups
FROM	sh.sales
GROUP BY cust_id,  time_id;


-- ROWS - it only takes the values of the previous, current and following rows
-- RANGE - it only takes the values of weeks that are higher and lower to 1 from current week. Also it will take the current week 
-- GROUPS - takes the previous, current, and following groups of equal week values
