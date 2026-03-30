
-- TASK 1

-- At first I added Turkish language to the language table
INSERT INTO language (name)
Values
('Turkish')


-- Added filmsS
INSERT INTO public.film (title, release_year, rental_rate,  rental_duration, language_id)
VALUES
('WHIPLASH', 2014, 4.99, 1, 1),
('DEHA', 2024, 9.99, 2, 7),
('CHUKUR', 2017, 19.99, 3, 7)
RETURNING *
;



;

-- Added only actor's first and last name because the actor_id is set NOT NULL DEFAULT nextval('actor_actor_id_seq'::regclass) so it will be automatically 
-- added.  last_update timestamp with time zone NOT NULL DEFAULT now() last_update  also will be added automatically  as current time because of now()
-- I can also put those value manually 

INSERT INTO public.actor (first_name, last_name)
VALUES
('MILES', 'TELLER'),
('JONATHAN', 'SIMMONS'),
('PAUL', 'REISER'),
('MELISSA', 'BENOIST'),
('AUSTIN', 'STOWELL'),
('NATE', 'LANG'),
('ARAS BULUT', 'IYNEMLI'),
('ERKAN KOLCAK', 'KOSTENDIL'),
('RIZA', 'KOCAOGLU'),
('ERCAN', 'KESAL'),
('PERIHAN', 'SAVAS'),
('DILAN CICEK', 'DENIZ'),
('MELIS', 'SEZEN'),
('TANER', 'OLMEZ'),
('ONUR', 'SAYLAK'),
('SEDA', 'BAKAN'),
('UGUR', 'POLAT')
RETURNING *;

-- There aren't any duplicate names
SELECT first_name, last_name, count(*) as cnt
FROM public.actor
GROUP BY first_name, last_name;


INSERT INTO public.film_actor (actor_id, film_id)
VALUES
(286, 1010),
(287, 1010),
(288, 1010),
(289, 1010),
(290, 1010),
(291, 1010),
(292, 1012),
(293, 1012),
(294, 1012),
(295, 1012),
(296, 1012),
(297, 1012),
(292, 1011),
(298, 1011),
(299, 1011),
(300, 1011),
(301, 1011),
(302, 1011)
RETURNING *;



-- I added all  films to hte store_id = 1 
INSERT INTO public.inventory (film_id, store_id)
VALUES
(1010, 1),
(1011, 1),
(1012, 1)
RETURNING *
;



--Alter any existing customer in the database with at least 43 rental and 43 payment records. Change their personal 
-- data to yours (first name, last name, address, etc.). You can use any existing address from the "address" table. 
-- Please do not perform any updates on the "address" table, as this can impact multiple records with the same address.
-- I choose customer with customer_id so I can change more then 43 rental and payment records
SELECT	customer_id, count(amount) 
FROM 	public.payment
GROUP BY customer_id
HAVING customer_id = 5
ORDER BY count(amount) DESC, customer_id
;

SELECT customer_id, count(return_date) 
FROM	public.rental
GROUP BY customer_id
HAVING customer_id = 5
ORDER BY count(return_date) DESC, customer_id
;


UPDATE public.customer
SET first_name = 'MUHAMMAD',
	last_name = 'SUVONOV',
	email = 'MUHAMMAD.SUVONOV@sakilacustomer.org',
	address_id = 100
WHERE customer_id = 5
;


--Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'

DELETE FROM public.payment
WHERE	customer_id = 5;

DELETE FROM public.rental
WHERE	customer_id = 5
;

--Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to 
--represent this activity)
INSERT INTO rental (inventory_id, rental_date, customer_id, staff_id)
VALUES 
(4594, '2017-01-01 09:00:00+05', 5, 1),
(4595, '2017-05-20 18:15:00+05', 5, 1),
(4596, '2017-12-31 23:59:59+05', 5, 1);

INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES
(5, 1, 32296, 99.8, '2017-01-15 10:30:00+05'),
(5, 1, 32297, 93.9,'2017-03-22 18:45:00+05'),
(5, 1, 32298, 16.9,'2017-06-10 09:15:00+05')
RETURNING *;




