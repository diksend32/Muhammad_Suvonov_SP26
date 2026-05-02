
-- Task 1
-- I used DENSE_RANK for not skipping the rows wiht the same 
WITH cte1 AS(
SELECT	ch.channel_class, c.cust_first_name, c.cust_last_name, SUM(s.amount_sold) AS amount_sold,
        DENSE_RANK() OVER(PARTITION BY ch.channel_class ORDER BY SUM(s.amount_sold) DESC) AS l
FROM	sh.customers c
JOIN    sh.sales s
			ON c.cust_id = s.cust_id
JOIN sh.channels ch
			ON ch.channel_id = s.channel_id
GROUP BY ch.channel_class, c.cust_first_name, c.cust_last_name),
cte2 AS(
SELECT  ch.channel_class, SUM(s.amount_sold) AS total
FROM	sh.channels ch
JOIN  sh.sales s
			ON ch.channel_id = s.channel_id
GROUP BY ch.channel_class 
)

SELECT  c1.channel_class, c1.cust_first_name, c1.cust_last_name, c1.amount_sold AS amount_sold,  
		ROUND((c1.amount_sold*100/c2.total), 2) || ''|| '%' AS sales_percentage
FROM cte1 c1
JOIN cte2 c2
		ON c1.channel_class = c2.channel_class

WHERE  l <= 5;

-- Task 2
-- The sales amount was already in two decimal places, so ROUND was not needed.
--CREATE EXTENSION tablefunc; is used in PostgreSQL to enable extra functions that are not included by default — especially 
--the crosstab (pivot) function.

SELECT prod_name, q1, q2, q3, q4, (q1+q2+q3+q4) AS year_sum
FROM(
SELECT prod_name, COALESCE(q1, 0) AS q1,COALESCE(q2, 0) AS q2, COALESCE(q3, 0) AS q3, COALESCE(q4, 0) AS q4
FROM crosstab(
$$
SELECT 
    prod_name,
    q,
   SUM(amount_sold)
FROM (
    SELECT  
        p.prod_name,
        s.amount_sold,
        CASE 
            WHEN EXTRACT(QUARTER FROM t.time_id) = 1 THEN 'q1'
            WHEN EXTRACT(QUARTER FROM t.time_id) = 2 THEN 'q2'
            WHEN EXTRACT(QUARTER FROM t.time_id) = 3 THEN 'q3'
            WHEN EXTRACT(QUARTER FROM t.time_id) = 4 THEN 'q4'
        END AS q
    FROM sh.products p
    JOIN sh.sales s ON p.prod_id = s.prod_id
    JOIN sh.customers c ON c.cust_id = s.cust_id
    JOIN sh.countries cr ON cr.country_id = c.country_id
    JOIN sh.times t ON t.time_id = s.time_id
    WHERE t.calendar_year = 2000
      AND p.prod_category = 'Photo'
      AND cr.country_subregion = 'Asia'
) x
GROUP BY prod_name, q
ORDER BY 1,2
$$
) AS ct (
    prod_name VARCHAR(50),
    q1 NUMERIC,
    q2 NUMERIC,
    q3 NUMERIC,
    q4 NUMERIC
)
) y
ORDER BY year_sum DESC  ; -- I used year_sum because ORDER BY is executed after SELECT 

CREATE EXTENSION tablefunc;

--Task 3
WITH cte1 AS ( 
SELECT  t.calendar_year, ch.channel_class, c.cust_first_name, c.cust_last_name, SUM(s.amount_sold) AS amount_sold,
		ROW_NUMBER() OVER(PARTITION BY t.calendar_year, ch.channel_class ORDER BY  SUM(s.amount_sold) DESC ) AS r
FROM	sh.customers c
JOIN    sh.sales s
		ON c.cust_id = s.cust_id
JOIN    sh.channels ch
		ON ch.channel_id = s.channel_id
JOIN    sh.times t
		ON t.time_id = s.time_id
WHERE t.calendar_year = 1998 OR  t.calendar_year = 1999 OR t.calendar_year = 2001
GROUP BY t.calendar_year, ch.channel_class, c.cust_first_name, c.cust_last_name
)

SELECT  channel_class, cust_first_name, cust_last_name,  amount_sold
FROM 	cte1
WHERE   r <=300;


-- Task 4
SELECT  '2000'||'-'||EXTRACT(MONTH FROM t.time_id) AS calendar_month_desc, 
		p.prod_category, SUM(s.amount_sold) FILTER (WHERE cr.country_region = 'Americas') AS "Americas Sales",
		SUM(s.amount_sold) FILTER (WHERE cr.country_region = 'Europe') AS "Europe Sales"
FROM	sh.products p
JOIN	sh.sales s
		ON p.prod_id = s.prod_id
JOIN	sh.times t
		ON t.time_id = s.time_id
JOIN    sh.customers c
		ON c.cust_id = s.cust_id
JOIN	sh.countries cr
		ON cr.country_id = c.country_id
WHERE   EXTRACT(QUARTER FROM t.time_id)=1 AND t.calendar_year = 2000 AND (cr.country_region = 'Americas' OR  cr.country_region = 'Europe')
GROUP BY '2000'||'-'||EXTRACT(MONTH FROM t.time_id), p.prod_category
;