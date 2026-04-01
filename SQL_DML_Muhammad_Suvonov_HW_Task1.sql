-- TASK 1

-- At first I added Turkish language to the language table. Here I also checked whether the name is written with upper or 
-- lower letters (case-insensitive)
BEGIN;
INSERT INTO public.language (name)
SELECT 'Turkish'
WHERE NOT EXISTS (
	SELECT 1
	FROM public.language
	WHERE UPPER(name) = 'TURKISH'
)
RETURNING *;
COMMIT;

-- Added films. USED UNION ALL to not rewrite insert into
BEGIN;
INSERT INTO public.film (title, release_year, rental_rate, rental_duration, language_id)
SELECT	'WHIPLASH', 2014, 4.99, 7, l.language_id
FROM	public.language l
WHERE l.name = 'English' AND NOT EXISTS(SELECT 1 FROM public.film WHERE title = 'WHIPLASH')

UNION ALL

SELECT	'DEHA', 2024, 9.99, 14, l.language_id
FROM	public.language l
WHERE l.name = 'Turkish' AND NOT EXISTS(SELECT 1 FROM public.film WHERE title = 'DEHA')
UNION ALL

SELECT	'CHUKUR', 2017, 19.99, 21, l.language_id
FROM	public.language l
WHERE l.name = 'Turkish' AND NOT EXISTS(SELECT 1 FROM public.film WHERE title = 'CHUKUR')
RETURNING *;
COMMIT;

-- Added actors, NOT EXISTS is used to avoid duplication of actor names
BEGIN;
INSERT INTO public.actor (first_name, last_name)
SELECT 'MILES', 'TELLER'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'MILES' AND last_name = 'TELLER')
UNION ALL
SELECT 'JONATHAN', 'SIMMONS'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'JONATHAN' AND last_name = 'SIMMONS')
UNION ALL
SELECT 'PAUL', 'REISER'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'PAUL' AND last_name = 'REISER')
UNION ALL
SELECT 'MELISSA', 'BENOIST'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'MELISSA' AND last_name = 'BENOIST')
UNION ALL
SELECT 'AUSTIN', 'STOWELL'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'AUSTIN' AND last_name = 'STOWELL')
UNION ALL
SELECT 'NATE', 'LANG'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'NATE' AND last_name = 'LANG')
UNION ALL
SELECT 'ARAS BULUT', 'IYNEMLI'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'ARAS BULUT' AND last_name = 'IYNEMLI')
UNION ALL
SELECT 'ERKAN KOLCAK', 'KOSTENDIL'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'ERKAN KOLCAK' AND last_name = 'KOSTENDIL')
UNION ALL
SELECT 'RIZA', 'KOCAOGLU'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'RIZA' AND last_name = 'KOCAOGLU')
UNION ALL
SELECT 'ERCAN', 'KESAL'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'ERCAN' AND last_name = 'KESAL')
UNION ALL
SELECT 'PERIHAN', 'SAVAS'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'PERIHAN' AND last_name = 'SAVAS')
UNION ALL
SELECT 'DILAN CICEK', 'DENIZ'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'DILAN CICEK' AND last_name = 'DENIZ')
UNION ALL
SELECT 'MELIS', 'SEZEN'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'MELIS' AND last_name = 'SEZEN')
UNION ALL
SELECT 'TANER', 'OLMEZ'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'TANER' AND last_name = 'OLMEZ')
UNION ALL
SELECT 'ONUR', 'SAYLAK'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'ONUR' AND last_name = 'SAYLAK')
UNION ALL
SELECT 'SEDA', 'BAKAN'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'SEDA' AND last_name = 'BAKAN')
UNION ALL
SELECT 'UGUR', 'POLAT'
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name = 'UGUR' AND last_name = 'POLAT')
RETURNING *;
COMMIT;

-- film_actor  
BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM	public.actor a, public.film f
WHERE	a.first_name = 'MILES' AND a.last_name = 'TELLER'
AND f.title = 'WHIPLASH'
AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor
	WHERE	a.actor_id = actor_id AND f.film_id = film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM	public.actor a, public.film f
WHERE	a.first_name = 'JONATHAN' AND a.last_name = 'SIMMONS'
AND f.title = 'WHIPLASH'
AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor
	WHERE	a.actor_id = actor_id AND f.film_id = film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM	public.actor a, public.film f
WHERE	a.first_name = 'PAUL' AND a.last_name = 'REISER'
AND f.title = 'WHIPLASH'
AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor
	WHERE	a.actor_id = actor_id AND f.film_id = film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM	public.actor a, public.film f
WHERE	a.first_name = 'MELISSA' AND a.last_name = 'BENOIST'
AND f.title = 'WHIPLASH'
AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor
	WHERE	a.actor_id = actor_id AND f.film_id = film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM	public.actor a, public.film f
WHERE	a.first_name = 'AUSTIN' AND a.last_name = 'STOWELL'
AND f.title = 'WHIPLASH'
AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor
	WHERE	a.actor_id = actor_id AND f.film_id = film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM	public.actor a, public.film f
WHERE	a.first_name = 'NATE' AND a.last_name = 'LANG'
AND f.title = 'WHIPLASH'
AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor
	WHERE	a.actor_id = actor_id AND f.film_id = film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'ARAS BULUT' AND a.last_name = 'IYNEMLI'
AND f.title = 'CHUKUR' AND NOT EXISTS(
		SELECT 1
		FROM public.film_actor
		WHERE film_id = f.film_id AND actor_id = a.actor_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'ERKAN KOLCAK' AND a.last_name = 'KOSTENDIL'
AND f.title = 'CHUKUR' AND NOT EXISTS(
		SELECT 1
		FROM public.film_actor
		WHERE film_id = f.film_id AND actor_id = a.actor_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'RIZA' AND a.last_name = 'KOCAOGLU'
AND f.title = 'CHUKUR' AND NOT EXISTS(
		SELECT 1
		FROM public.film_actor
		WHERE film_id = f.film_id AND actor_id = a.actor_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'ERCAN' AND a.last_name = 'KESAL'
AND f.title = 'CHUKUR' AND NOT EXISTS(
		SELECT 1
		FROM public.film_actor
		WHERE film_id = f.film_id AND actor_id = a.actor_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'PERIHAN' AND a.last_name = 'SAVAS'
AND f.title = 'CHUKUR' AND NOT EXISTS(
		SELECT 1
		FROM public.film_actor
		WHERE film_id = f.film_id AND actor_id = a.actor_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT	a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'DILAN CICEK' AND a.last_name = 'DENIZ'
AND f.title = 'CHUKUR' AND NOT EXISTS(
		SELECT 1
		FROM public.film_actor
		WHERE film_id = f.film_id AND actor_id = a.actor_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'ARAS BULUT' AND a.last_name = 'IYNEMLI'
AND f.title = 'DEHA' AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor 
	WHERE	a.actor_id = actor_id AND film_id = f.film_id
)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'MELIS' AND a.last_name = 'SEZEN'
AND f.title = 'DEHA' AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor 
	WHERE	a.actor_id = actor_id AND film_id = f.film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'TANER' AND a.last_name = 'OLMEZ'
AND f.title = 'DEHA' AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor 
	WHERE	a.actor_id = actor_id AND film_id = f.film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'ONUR' AND a.last_name = 'SAYLAK'
AND f.title = 'DEHA' AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor 
	WHERE	a.actor_id = actor_id AND film_id = f.film_id
)
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'SEDA' AND a.last_name = 'BAKAN'
AND f.title = 'DEHA' AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor 
	WHERE	a.actor_id = actor_id AND film_id = f.film_id
)
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.film f, public.actor a
WHERE a.first_name = 'UGUR' AND a.last_name = 'POLAT'
AND f.title = 'DEHA' AND NOT EXISTS (
	SELECT 1
	FROM public.film_actor 
	WHERE	a.actor_id = actor_id AND film_id = f.film_id
)
RETURNING *;
COMMIT;

-- INVENTORY. NOT EXISTS is used to avoid adding films to inventory several times
BEGIN;
INSERT INTO public.inventory (film_id, store_id)
SELECT f.film_id, (SELECT store_id FROM public.store LIMIT 1)
FROM public.film f
WHERE f.title IN ('WHIPLASH', 'DEHA', 'CHUKUR')
AND NOT EXISTS (
		SELECT 1 
		FROM public.inventory i
		WHERE i.film_id = f.film_id
)
RETURNING *;
COMMIT;

-- Alter any existing customer in the database with at least 43 rental and 43 payment records
BEGIN;
UPDATE public.customer
SET	first_name = 'MUHAMMAD',
	last_name = 'SUVONOV',
	email = 'MUHAMMAD.SUVONOV@sakilacustomer.org',
	address_id = (SELECT address_id FROM public.address LIMIT 1)
	WHERE customer_id = (
							SELECT c.customer_id
							FROM public.customer c
							INNER JOIN public.payment p
									ON c.customer_id = p.customer_id
							INNER JOIN public.rental r
									ON c.customer_id = r.customer_id
							GROUP BY c.customer_id
							HAVING COUNT(p.payment_id) >= 43 AND  COUNT(r.rental_id) >=43
							LIMIT 1
								)
RETURNING *;
COMMIT;

--Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
BEGIN;
DELETE FROM public.payment p
WHERE p.customer_id = (
	SELECT c.customer_id
	FROM public.customer c
	WHERE c.email =  'MUHAMMAD.SUVONOV@sakilacustomer.org'
)
RETURNING *;
COMMIT;

BEGIN;
DELETE FROM public.rental
WHERE	customer_id =  (
	SELECT c.customer_id
	FROM public.customer c
	WHERE c.email =  'MUHAMMAD.SUVONOV@sakilacustomer.org'
)
RETURNING*;
COMMIT;

--Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to 
--represent this activity)
-- renitng: First I added my films to rental table
BEGIN;
INSERT INTO public.rental(rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT '2016-05-30 23:07:15+05', i.inventory_id, 
		(SELECT customer_id FROM public.customer WHERE email = 'MUHAMMAD.SUVONOV@sakilacustomer.org'),
		'2016-06-03 03:48:15+05', (SELECT staff_id FROM public.staff LIMIT 1 )
FROM public.inventory i
INNER JOIN public.film f
			ON i.film_id = f.film_id
WHERE f.title = 'WHIPLASH'
RETURNING *;
COMMIT;


BEGIN;
INSERT INTO public.rental(rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT '2016-05-30 23:07:15+05', i.inventory_id, 
		(SELECT customer_id FROM public.customer WHERE email = 'MUHAMMAD.SUVONOV@sakilacustomer.org'),
		'2016-06-03 03:48:15+05', (SELECT staff_id FROM public.staff LIMIT 1 )
FROM public.inventory i
INNER JOIN public.film f
			ON i.film_id = f.film_id
WHERE f.title = 'CHUKUR'
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.rental(rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT '2016-05-30 23:07:15+05', i.inventory_id, 
		(SELECT customer_id FROM public.customer WHERE email = 'MUHAMMAD.SUVONOV@sakilacustomer.org'),
		'2016-06-03 03:48:15+05', (SELECT staff_id FROM public.staff LIMIT 1 )
FROM public.inventory i
INNER JOIN public.film f
			ON i.film_id = f.film_id
WHERE f.title = 'DEHA'
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT c.customer_id,
	  (SELECT staff_id FROM public.staff LIMIT 1),
       r.rental_id,
       f.rental_rate,
       '2017-01-15 10:30:00+05'
FROM public.rental r
INNER JOIN public.customer c ON c.email = 'MUHAMMAD.SUVONOV@sakilacustomer.org'
INNER JOIN public.inventory i ON i.inventory_id = r.inventory_id
INNER JOIN public.film f ON f.film_id = i.film_id
WHERE f.title = 'WHIPLASH'
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT c.customer_id,
	   (SELECT staff_id FROM public.staff LIMIT 1),
		r.rental_id,
		f.rental_rate,
		'2017-05-17 12:34:00+05'
FROM public.rental r
INNER JOIN public.customer c
			ON c.email =  'MUHAMMAD.SUVONOV@sakilacustomer.org'
INNER JOIN public.inventory i 
			ON i.inventory_id = r.inventory_id
INNER JOIN public.film f
			ON f.film_id = i.film_id
WHERE f.title = 'CHUKUR'
RETURNING *;
COMMIT;

BEGIN;
INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT c.customer_id,
	   (SELECT staff_id FROM public.staff LIMIT 1),
		r.rental_id,
		f.rental_rate,
		'2017-05-17 12:34:00+05'
FROM public.rental r
INNER JOIN public.customer c
			ON c.email =  'MUHAMMAD.SUVONOV@sakilacustomer.org'
INNER JOIN public.inventory i 
			ON i.inventory_id = r.inventory_id
INNER JOIN public.film f
			ON f.film_id = i.film_id
WHERE f.title = 'DEHA'
RETURNING *;
COMMIT;
 -- Advantages of INSER ... SELECT over INSER ... VALUES
 -- 1 We can add more rows at once rather than adding one by one
 -- 2 Avoid duplicates with using  NOT EXISTS
 -- 3 Avoid hardcoding IDS
 -- 4  Dynamically retrieves values from other tables (e.g., language_id, film_id)

 
