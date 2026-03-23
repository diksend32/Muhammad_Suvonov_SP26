-- Part 1: Write SQL queries to retrieve the following data. 

-- 1.1 The marketing team needs a list of animation movies between 2017 and 2019 to promote family-friendly content in an upcoming season in stores. 
-- Show all animation movies released during this period with rate more than 1, sorted alphabetically

-- Using JOINS: Multiple joins can make the query structure more complex to read. Additionally I used UPPER to not skip the rows
-- that was written in lower letters
SELECT	f.title as film_name, 
		c.name as category, 
		f.rental_rate as rate,  
		f.release_year
FROM	public.film f
INNER JOIN public.film_category fc
			ON f.film_id = fc.film_id
INNER JOIN public.category c 
			ON c.category_id = fc.category_id
WHERE	UPPER(c.name) = 'ANIMATION' and f.rental_rate > 1 and f.release_year BETWEEN 2017 AND 2019
ORDER BY f.title;

--Using Subquery: 
SELECT  f.title as film_name, 
		f.rental_rate as rate,  
		f.release_year
FROM	public.film f	
WHERE	f.film_id IN (
					 SELECT	fc.film_id
					 FROM public.category c
					 INNER JOIN public.film_category fc
					 			ON c.category_id = fc.category_id
					WHERE UPPER(c.name) = 'ANIMATION' 
)
	AND f.rental_rate > 1  AND f.release_year BETWEEN 2017 AND 2019
ORDER BY f.title;
-- Using CTE: Using the cte makes the query more readable, understandable

WITH category AS(
SELECT	fc.film_id
FROM	public.category c
INNER JOIN	public.film_category fc
			ON c.category_id = fc.category_id
WHERE	UPPER(c.name) = 'ANIMATION'
)

SELECT	f.title as film_name,
		f.release_year,
		f.rental_rate as rate
FROM	public.film f
WHERE	f.film_id IN(SELECT * FROM category) AND f.rental_rate > 1 AND f.release_year BETWEEN 2017 AND 2019
ORDER BY f.title;




-- 1.2 The finance department requires a report on store performance to assess profitability and plan resource allocation for 
-- stores after March 2017. Calculate the revenue earned by each rental store after March 2017 (since April) (include columns: 
-- address and address2 – as one column, revenue)

-- Using Join and CTE: Only using of Joins is not enough because I need to use group by store_id,  so I calculated total revunue 
-- inside the cte  and then added address. Also I did not add address2 since all values of store1 and store2 is NULL 
WITH cte as (
				SELECT	i.store_id, sum(p.amount) as total_revunue
				FROM	public.inventory i
						INNER JOIN public.rental r
								ON i.inventory_id = r.inventory_id
						INNER JOIN public.payment p
								ON p.rental_id = r.rental_id
				
				WHERE	EXTRACT(YEAR FROM p.payment_date) = 2017 AND EXTRACT(MONTH FROM p.payment_date) BETWEEN 3 and 4
				GROUP BY i.store_id)
				
SELECT	c.store_id, c.total_revunue, a.address
FROM public.store s
INNER JOIN public.address a
			ON s.address_id = a.address_id
INNER JOIN cte c
			ON c.store_id = s.store_id
;

--USING Subquery and JOIN
SELECT	t.store_id, t.total_revunue, a.address
FROM (
		SELECT	i.store_id, sum(p.amount) as total_revunue
				FROM	public.inventory i
						INNER JOIN public.rental r
								ON i.inventory_id = r.inventory_id
						INNER JOIN public.payment p
								ON p.rental_id = r.rental_id
				
				WHERE	EXTRACT(YEAR FROM p.payment_date) = 2017 AND EXTRACT(MONTH FROM p.payment_date) BETWEEN 3 and 4
				GROUP BY i.store_id
) as t
INNER JOIN	public.store s
			ON s.store_id = t.store_id
INNER JOIN public.address a
			ON a.address_id = s.address_id;

--1.3 The marketing department in our stores aims to identify the most successful actors since 2015 to boost customer interest 
-- in their films. Show top-5 actors by number of movies (released since 2015) they took part in (columns: first_name, last_name,
-- number_of_movies, sorted by number_of_movies in descending order)

-- Joins
SELECT	a.first_name, a.last_name, count(f.film_id) as total_movies
FROM public.actor a
INNER JOIN	public.film_actor fa
			ON fa.actor_id = a.actor_id
INNER JOIN	public.film f
			ON f.film_id = fa.film_id
WHERE f.release_year >= 2015
GROUP BY a.first_name, a.last_name
ORDER  BY count(f.film_id) desc
LIMIT 5
;

-- Subquery
SELECT	a.first_name, a.last_name, f.total_movies
FROM (
		SELECT fa.actor_id, count(f.film_id) as total_movies
		FROM public.film_actor fa
		INNER JOIN public.film f
				ON f.film_id = fa.film_id
				WHERE f.release_year >= 2015
				GROUP BY fa.actor_id
) f
INNER JOIN public.actor a
		ON a.actor_id = f.actor_id
ORDER BY  f.total_movies desc
LIMIT 5;

-- CTE
WITH films as (
        SELECT fa.actor_id, count(f.film_id) as total_movies
		FROM public.film_actor fa
		INNER JOIN public.film f
				ON f.film_id = fa.film_id
				WHERE f.release_year >= 2015
				GROUP BY fa.actor_id
)

SELECT 	a.first_name, a.last_name, f.total_movies
FROM	public.actor a
INNER JOIN films f
	ON f.actor_id = a.actor_id
ORDER BY  f.total_movies desc
LIMIT 5;

-- 1.4 The marketing team needs to track the production trends of Drama, Travel, and Documentary films to inform genre-specific 
-- marketing strategies. Show number of Drama, Travel, Documentary per year (include columns: release_year, 
-- number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), sorted by release year in descending order. 
-- Dealing with NULL values is encouraged)
-- I used   "ELSE 0 END"  wich avoid null values

-- JOIN
SELECT	f.release_year, 
		SUM(CASE WHEN UPPER(c.name) = 'DRAMA' THEN 1 ELSE 0 END) AS number_of_drama_movies,
	    SUM(CASE WHEN UPPER(c.name) = 'TRAVEL' THEN 1 ELSE 0 END) AS number_of_travel_movies,
	    SUM(CASE WHEN UPPER(c.name) = 'DOCUMENTARY' THEN 1 ELSE 0 END) AS number_of_documentary_movies
FROM public.film f
INNER JOIN film_category fc 
			ON fc.film_id = f.film_id
INNER JOIN	public.category c
			ON c.category_id = fc.category_id
GROUP BY f.release_year
ORDER BY f.release_year DESC
;

-- Subquery
SELECT	sub.release_year,
		SUM(CASE WHEN UPPER(sub.name) = 'DRAMA' THEN 1 ELSE 0 END) AS number_of_drama_movies,
	    SUM(CASE WHEN UPPER(sub.name) = 'TRAVEL' THEN 1 ELSE 0 END) AS number_of_travel_movies,
	    SUM(CASE WHEN UPPER(sub.name) = 'DOCUMENTARY' THEN 1 ELSE 0 END) AS number_of_documentary_movies
FROM	(
		 SELECT f.release_year, c.name
		 FROM public.film f
		 INNER JOIN film_category fc 
					ON fc.film_id = f.film_id
		 INNER JOIN	public.category c
					ON c.category_id = fc.category_id		
		) sub
GROUP BY sub.release_year
ORDER BY sub.release_year DESC	;	

--CTE
WITH cte as (
             SELECT f.release_year, c.name
			 FROM public.film f
			 INNER JOIN film_category fc 
						ON fc.film_id = f.film_id
			 INNER JOIN	public.category c
						ON c.category_id = fc.category_id
)

SELECT c.release_year, 
		SUM(CASE WHEN UPPER(c.name) = 'DRAMA' THEN 1 ELSE 0 END) AS number_of_drama_movies,
	    SUM(CASE WHEN UPPER(c.name) = 'TRAVEL' THEN 1 ELSE 0 END) AS number_of_travel_movies,
	    SUM(CASE WHEN UPPER(c.name) = 'DOCUMENTARY' THEN 1 ELSE 0 END) AS number_of_documentary_movies
FROM	cte c 
GROUP BY c.release_year
ORDER BY c.release_year DESC
;

-- Part 2: Solve the following problems using SQL
-- 2.1 The HR department aims to reward top-performing employees in 2017 with bonuses to recognize their contribution to stores 
-- revenue. Show which three employees generated the most revenue in 2017? 

-- JOIN


SELECT	s.first_name, s.last_name, SUM(p.amount) as total
FROM	public.payment p
INNER JOIN public.staff s
			ON s.staff_id = p.staff_id
WHERE	EXTRACT(YEAR FROM p.payment_date) = 2017
GROUP BY 	s.first_name, s.last_name	
ORDER BY 	SUM(p.amount) desc
LIMIT 3;

-- Subquery

SELECT	s.first_name, s.last_name, ps.total
FROM	(SELECT	p.staff_id, SUM(p.amount) as total
		FROM public.payment p
		WHERE	EXTRACT(YEAR FROM p.payment_date) = 2017
		GROUP BY p.staff_id) ps
INNER JOIN public.staff s
			ON s.staff_id = ps.staff_id						
ORDER BY 	ps.total desc
LIMIT 3;

-- CTE 
WITH ps AS (
SELECT	p.staff_id, SUM(p.amount) as total
		FROM public.payment p
		WHERE	EXTRACT(YEAR FROM p.payment_date) = 2017
		GROUP BY p.staff_id
)

SELECT s.first_name, s.last_name, ps.total
FROM	ps
INNER JOIN public.staff s
			ON s.staff_id = ps.staff_id						
ORDER BY 	ps.total desc
LIMIT 3;

-- 2.2  The management team wants to identify the most popular movies and their target audience age groups to optimize marketing
-- efforts. Show which 5 movies were rented more than others (number of rentals), and what's the expected age of the audience 
-- for these movies?
-- Here it is impossible to use only joins because I need first group by film and then outside of cte or subquery I can work with ages  


-- CTE
WITH cte as(
			SELECT 	i.film_id, count(r.rental_id) as total_rent
			FROM	public.inventory i
			INNER JOIN public.rental r
					ON i.inventory_id = r.inventory_id
			GROUP BY i.film_id
			ORDER BY total_rent DESC
			LIMIT 5)
SELECT	f.title, 
		c.total_rent, 
		CASE  f.rating
			  WHEN 'G' THEN 'General Audiences'
			  WHEN 'PG' THEN 'Parental Guidance Suggested'
			  WHEN 'PG-13' THEN 'Parents Strongly Cautioned'
			  WHEN 'R' THEN 'Restricted'
			  WHEN 'NC-17' THEN 'Adults Only'
			  ELSE 'Unknown Rating'
              END AS rating_description
FROM cte c
INNER JOIN public.film f
			ON f.film_id = c.film_id
;
-- Subquery
SELECT  f.title, 
		sub.total_rent, 
		CASE  f.rating
			  WHEN 'G' THEN 'General Audiences'
			  WHEN 'PG' THEN 'Parental Guidance Suggested'
			  WHEN 'PG-13' THEN 'Parents Strongly Cautioned'
			  WHEN 'R' THEN 'Restricted'
			  WHEN 'NC-17' THEN 'Adults Only'
			  ELSE 'Unknown Rating'
			  END AS rating_description
FROM	(
			SELECT 	i.film_id, count(r.rental_id) as total_rent
			FROM	public.inventory i
			INNER JOIN public.rental r
					ON i.inventory_id = r.inventory_id
			GROUP BY i.film_id
			ORDER BY total_rent DESC
			LIMIT 5
) sub
INNER JOIN public.film f
			ON f.film_id = sub.film_id;

-- Part 3. Which actors/actresses didn't act for a longer period of time than the others? 
--The stores’ marketing team wants to analyze actors' inactivity periods to select those with notable career breaks for 
-- targeted promotional campaigns, highlighting their comebacks or consistent appearances to engage customers with nostalgic or 
-- reliable film stars
-- The task can be interpreted in various ways, and here are a few options (provide solutions for each one):
-- V1: gap between the latest release_year and current year per each actor;
-- V2: gaps between sequential films per each actor;
--V1
-- JOIN
SELECT	a.first_name, a.last_name, (EXTRACT(YEAR FROM CURRENT_DATE) -  MAX(f.release_year))  as pause_year
FROM	public.actor a
INNER JOIN public.film_actor fa
			ON a.actor_id = fa.actor_id
INNER JOIN	public.film f
		ON f.film_id = fa.film_id
GROUP BY a.first_name, a.last_name
ORDER BY pause_year DESC;

-- CTE
WITH cte AS (
SELECT	*
FROM	public.actor a
INNER JOIN public.film_actor fa
			ON a.actor_id = fa.actor_id
INNER JOIN	public.film f
		ON f.film_id = fa.film_id

)

SELECT	c.first_name, c.last_name, (EXTRACT(YEAR FROM CURRENT_DATE) -  MAX(c.release_year))  as pause_year
FROM	cte c
GROUP BY  c.first_name, c.last_name
ORDER BY pause_year DESC;

-- Subquery
SELECT	sub.first_name, sub.last_name, (EXTRACT(YEAR FROM CURRENT_DATE) -  MAX(sub.release_year))  as pause_year
FROM (
		SELECT	*
FROM	public.actor a
INNER JOIN public.film_actor fa
			ON a.actor_id = fa.actor_id
INNER JOIN	public.film f
		ON f.film_id = fa.film_id
) sub
GROUP BY sub.first_name, sub.last_name
ORDER BY pause_year DESC;

 --V2 - I had no idea how to do it, can you give some advice.