-- Task 1. Figure out what security precautions are already used in your 'dvd_rental' database.  Prepare description
SELECT *
FROM	pg_roles;

SELECT	rolname, 
		rolsuper AS is_superrole, 
		rolcreaterole AS can_create_role, 
		rolcreatedb AS can_create_database
FROM	pg_roles;

SELECT table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public';

SELECT	*
FROM	pg_class;

SELECT *
FROM pg_policies;

SELECT datname AS database, datconnlimit AS connection_limit
FROM	pg_database;

ALTER DATABASE postgres CONNECTION LIMIT 50;


-- Task 2. Implement role-based authentication model for dvd_rental database

-- 1. Create a new user with the username "rentaluser" and the password "rentalpassword". Give the user the ability to 
-- connect to the database but no other permissions.

CREATE ROLE rentaluser LOGIN  PASSWORD 'rentalpassword';

GRANT CONNECT ON DATABASE dvdrental_dml TO rentaluser;

--2. Grant "rentaluser" permission allows reading data from the "customer" table. Сheck to make sure this permission works 
--correctly: write a SQL query to select all customers.
GRANT SELECT ON public.customer TO rentaluser;
-- I switched to  rentaluser:  <New connection> -> user = rentaluser -> entered password  
-- rentalpassword = dvdrental_dml/rentaluser@PostgreSQL 18

SELECT	*
FROM	customer;

-- checked others - ERROR:  permission denied for table film
SELECT	*
FROM	film ;

-- switched to  postgres 

-- 3. Create a new user group called "rental" and add "rentaluser" to the group.
CREATE ROLE  rental;

GRANT rental TO rentaluser;

--4. Grant the "rental" group INSERT and UPDATE permissions for the "rental" table. Insert a new row and update one existing
--row in the "rental" table under that role. 

GRANT INSERT, UPDATE ON public.rental TO rental;
GRANT SELECT ON public.inventory TO rental;  -- for avoiding hardcoding I granted inventory ,staff,  film and rental to the rental
GRANT SELECT ON public.film TO rental;
GRANT SELECT ON public.staff TO rental;

-- switched to  rentaluser

INSERT INTO public.rental(rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT		NOW(), i.inventory_id, c.customer_id, NOW() + INTERVAL '10 days', s.staff_id
FROM	public.inventory i
INNER JOIN public.film f
			ON f.film_id = i.film_id  AND f.title = 'CHAMBER ITALIAN'
INNER JOIN public.customer c
			ON c.email = 'DIANA.ALEXANDER@sakilacustomer.org'
INNER JOIN public.staff s
			ON s.store_id = i.store_id 
LIMIT 1
;

UPDATE rental
SET staff_id  = 2
WHERE	inventory_id = 100;

--5. Revoke the "rental" group's INSERT permission for the "rental" table. Try to insert new rows into the "rental" table
-- make sure this action is denied.


-- switched to  postgres 
REVOKE INSERT ON public.rental FROM rental;

-- switched to  rentaluser
INSERT INTO public.rental(rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT		NOW(), i.inventory_id, c.customer_id, NOW() + INTERVAL '10 days', s.staff_id
FROM	public.inventory i
INNER JOIN public.film f
			ON f.film_id = i.film_id  AND f.title = 'CHAMBER ITALIAN'
INNER JOIN public.customer c
			ON c.email = 'DIANA.ALEXANDER@sakilacustomer.org'
INNER JOIN public.staff s
			ON s.store_id = i.store_id 
LIMIT 1                                      -- ERROR:  permission denied for table rental 
;


-- 6. Create a personalized role for any customer already existing in the dvd_rental database. The name of the role name
--must be client_{first_name}_{last_name} (omit curly brackets). The customer's payment and rental history must not be empty. 

-- I find the customer with rental history and payment
SELECT c.first_name, c.last_name
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
JOIN payment p ON p.customer_id = c.customer_id
GROUP BY c.customer_id
LIMIT 1;        ---> MUHAMMAD SUVONOV -> I added it earlier


CREATE ROLE client_MUHAMMAD_SUVONOV LOGIN;



--Task 3. Implement row-level security
-- Configure that role so that the customer can only access their own data in the "rental" and "payment" tables. 
-- Write a query to make sure this user sees only their own data and one to show zero rows or error

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'MUHAMMAD.SUVONOV@sakilacustomer.org') THEN
        CREATE ROLE "MUHAMMAD.SUVONOV@sakilacustomer.org" LOGIN PASSWORD '123';
    END IF;

    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'AUSTIN.CINTRON@sakilacustomer.org') THEN
        CREATE ROLE "AUSTIN.CINTRON@sakilacustomer.org" LOGIN PASSWORD '321';
    END IF;

    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'customer') THEN
        CREATE ROLE customer;
    END IF;
END;
$$;



ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

CREATE POLICY rental
ON public.rental
FOR SELECT  
USING(
	customer_id IN (
			SELECT customer_id
			FROM public.customer
			WHERE  email = current_user 
			)
);



CREATE POLICY payment
ON public.payment
FOR SELECT
USING(
	customer_id IN (
			SELECT customer_id
			FROM public.customer
			WHERE  email = current_user 
			)
);


-- Giving the privileges is depersonalized
CREATE ROLE customer;  
GRANT SELECT ON public.rental, public.payment, public.customer TO customer;
GRANT customer TO "MUHAMMAD.SUVONOV@sakilacustomer.org" ;   ---> I added it earlier and the tables such customer, rental, payment have data with that customer_id
GRANT customer TO "AUSTIN.CINTRON@sakilacustomer.org" ;


SELECT * 
FROM   public.rental;

SELECT * 
FROM   public.payment;


