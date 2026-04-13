-- 1.TASK
--Create a view called 'sales_revenue_by_category_qtr' that shows the film category and total sales revenue for the current 
--quarter and year. The view should only display categories with at least one sale in the current quarter. 
--Note: make it dynamic - when the next quarter begins, it automatically considers that as the current quarter
--current quarter
--current year
--why only categories with sales appear
--how zero-sales categories are excluded
--the current default database does not contain data for the current year. Also, please indicate how you verified that 
--view is working correctly

-- 1. I filtered this qaurter as  p.payment_date >= CURRENT_DATE AND p.payment_date < CURRENT_DATE + INTERVAL '3 months'. It enforce 
-- table to return payments inside of this 3 month which is on quarter. 
-- It is dynamic since it only count from day that we excecuted the query to next 3 month.

--2 That query returns the catogories of t films there were only selled because I used INNER JOIN which skips the films.
-- So only  sold films ' categories are apeared and zero sales are excluded
--3. When I called the view it was empty, then I checked the MAX and MIN payment_date where  year is 2017. So it was empty 

CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS(
SELECT	c.name, SUM(p.amount) total_sales
FROM	public.category c
JOIN	public.film_category fc
		ON fc.category_id = c.category_id
JOIN	public.film f
		ON f.film_id = fc.film_id
JOIN	public.inventory i
		ON i.film_id = f.film_id
JOIN	public.rental r
		ON r.inventory_id = i.inventory_id
JOIN	public.payment p
		ON p.rental_id = r.rental_id
WHERE   p.payment_date >= CURRENT_DATE AND p.payment_date < CURRENT_DATE + INTERVAL '3 months'
GROUP BY c.name)

SELECT	*
FROM	sales_revenue_by_category_qtr

SELECT  CURRENT_DATE + INTERVAL '3 months';


SELECT	MAX(payment_date), MIN(payment_date)
FROM	public.payment;



-- TASK 2
-- Create a query language function called 'get_sales_revenue_by_category_qtr' that accepts one parameter representing the 
-- current quarter and year and returns the same result as the 'sales_revenue_by_category_qtr' view.
-- Explain in the comment:
-- why parameter is needed
-- what happens if:
-- 		invalid quarter is passed
-- 		no data exists

-- Parameter is needed to look up for specfic value. So here I can enter the year and quarter so it will filter and give the 
-- total sales that is in the given year and quarter.

-- If the invalid quarter is passed, it will return an error.
-- For example if I take 0 it will return <<date field value out of range: 2017--3-01>>
-- Empty table will be returned if I take as parametres that is out of period.

CREATE FUNCTION get_sales_revenue_by_category_qtr (IN year_ INT, quarter INT)
RETURNS TABLE (cetogory TEXT,
				total_sales NUMERIC
					)
AS $$
SELECT	c.name AS cetegory, SUM(p.amount) total_sales
FROM	public.category c
JOIN	public.film_category fc
		ON fc.category_id = c.category_id
JOIN	public.film f
		ON f.film_id = fc.film_id
JOIN	public.inventory i
		ON i.film_id = f.film_id
JOIN	public.rental r
		ON r.inventory_id = i.inventory_id
JOIN	public.payment p
		ON p.rental_id = r.rental_id	
WHERE	EXTRACT(YEAR FROM p.payment_date) = year_ 
		AND  p.payment_date >= MAKE_DATE(year_, (quarter - 1) * 3, 1)
		AND  p.payment_date <  MAKE_DATE(year_, (quarter -  1) * 3, 1)+ INTERVAL '3 months' 
GROUP BY c.name 
$$
LANGUAGE sql;

SELECT get_sales_revenue_by_category_qtr(2017, 2);

-- TASK 3

-- Create a function that takes a country as an input parameter and returns the most popular film in that specific country. 
--The function should format the result set as follows:
--            Query (example):select * from core.most_popular_films_by_countries(array['Afghanistan','Brazil','United States’]);

-- Explain in the comment:
-- 1.how 'most popular' is defined: by rentals / by revenue / by count
-- 2.how ties are handled
-- 3.what happens if country has no data

-- 1. The most popular film is definded by to rentals with window function 
-- 2. I used RANK which put 1 to the most rented so films with the same rentals are not missed
--3.  That country will NOT appear in the result, because INNER JOIN removes countries without rentals.

CREATE OR REPLACE FUNCTION most_popular_films_by_countries(p_countries TEXT[])
RETURNS TABLE(
				country      TEXT,
				film	     TEXT,
				rating       MPAA_RATING,
				language     CHARACTER(20),
				relaese_year YEAR
				
)
LANGUAGE plpgsql
AS
$$
BEGIN
RETURN QUERY
WITH cte1 AS(
SELECT 	cn.country, f.title, f.rating, l.name, f.release_year, COUNT(r.rental_id) as total
FROM	public.film f
JOIN	public.inventory i
		ON f.film_id = i.film_id
JOIN	public.rental r
		ON r.inventory_id = i.inventory_id
JOIN	public.customer c
		ON c.customer_id = r.customer_id
JOIN	public.address a
		ON a.address_id = c.address_id
JOIN	public.city ct
		ON ct.city_id = a.city_id
JOIN	public.country cn
		ON cn.country_id = ct.city_id
JOIN	public.language l
		ON l.language_id = f.language_id
GROUP BY cn.country, f.title, f.rating, l.name, f.release_year),

cte2 AS(
SELECT	*, RANK() OVER(PARTITION BY c1.country ORDER BY c1.total DESC) as r
FROM	cte1 c1)

SELECT c2.country, c2.title, c2.rating, c2.name as language, c2.release_year
FROM  cte2 c2
WHERE r = 1 AND  c2.country = ANY(p_countries);
END;
$$;

select * from public.most_popular_films_by_countries(array['Afghanistan','Brazil','United States']);


-- Task 4
--Create a function that generates a list of movies available in stock based on a partial title match (e.g., movies 
--containing the word 'love' in their title). 
-- The titles of these movies are formatted as '%...%', and if a movie with the specified title is not in stock, return a
-- message indicating that it was not found.
-- The function should produce the result set in the following format (note: the 'row_num' field is an automatically generated 
-- counter field, starting from 1 and incrementing for each entry, e.g., 1, 2, ..., 100, 101, ...).


CREATE OR REPLACE FUNCTION films_in_stock_by_title(p_title TEXT)
RETURNS TABLE (
    row_num INT,
    film_title TEXT,
    language CHARACTER,
    customer_name TEXT,
    rental_date TIMESTAMPTZ
)
LANGUAGE plpgsql
AS
$$
BEGIN
RETURN QUERY
SELECT 
    ROW_NUMBER() OVER () ::INT,
    f.title,
    l.name,
    cu.first_name || ' ' || cu.last_name,
    r.rental_date
FROM film f
JOIN language l ON l.language_id = f.language_id
JOIN inventory i ON i.film_id = f.film_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
LEFT JOIN customer cu ON cu.customer_id = r.customer_id

WHERE f.title ILIKE p_title
AND (r.rental_id IS NULL OR r.return_date IS NOT NULL);
END;
$$;

select * from films_in_stock_by_title('%love%');




-- TAKS 5
CREATE OR REPLACE FUNCTION new_movie(
    p_title TEXT,
    p_release_year INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    p_language TEXT DEFAULT 'Klingon'
)
RETURNS VOID
LANGUAGE plpgsql
AS
$$
DECLARE
    v_language_id INT;
    v_film_id INT;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM film
        WHERE title = p_title
    ) THEN
        RAISE EXCEPTION 'Movie with title "%" already exists', p_title;
    END IF;

    SELECT language_id
    INTO v_language_id
    FROM language
    WHERE name = p_language;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Language "%" does not exist in language table', p_language;
    END IF;

    SELECT COALESCE(MAX(film_id), 0) + 1
    INTO v_film_id
    FROM film;

    INSERT INTO film (
        film_id,
        title,
        release_year,
        language_id,
        rental_duration,
        rental_rate,
        replacement_cost,
        last_update
    )
    VALUES (
        v_film_id,
        p_title,
        p_release_year,
        v_language_id,
        3,
        4.99,
        19.99,
        CURRENT_TIMESTAMP
    );
END;
$$;




