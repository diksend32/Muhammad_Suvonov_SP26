CREATE DATABASE household_appliances_store;

CREATE SCHEMA IF NOT EXISTS store;
-- Firstly I created parent tables that doesn't have a Foreign key to avoid error when column referenced to the other table 
-- does not exists .

CREATE TABLE IF NOT EXISTS  store.customer(
customer_id BIGSERIAL PRIMARY KEY ,
first_name  VARCHAR(50) NOT NULL,
last_name   VARCHAR(50) NOT NULL,
fullname    TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL,
email		TEXT NOT NULL UNIQUE CHECK(email LIKE '%@gmail.com')  -- email is checked whether it contain %@gmail.com at the end
);

CREATE TABLE IF NOT EXISTS store.category(
category_id  BIGSERIAL PRIMARY KEY,
category	 VARCHAR(50) NOT NULL 
);

CREATE TABLE IF NOT EXISTS store.supplier(
supplier_id BIGSERIAL PRIMARY KEY,
name		TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS store.employee(
employee_id  BIGSERIAL PRIMARY KEY,
first_name   VARCHAR(50) NOT NULL,
last_name	 VARCHAR(50) NOT NULL,
fullname	 TEXT  GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL,
email        TEXT  NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS store.address(
address_id	BIGSERIAL PRIMARY KEY,
name		TEXT NOT NULL UNIQUE
)
;
-- Started to create tables with foreign key
CREATE TABLE IF NOT EXISTS store.product(
product_id   BIGSERIAL PRIMARY KEY,
product_name VARCHAR(50) NOT NULL UNIQUE,
price        DECIMAL(10,2) ,
category_id  BIGINT NOT NULL REFERENCES  store.category(category_id),
supplier_id  BIGINT NOT NULL REFERENCES store.supplier(supplier_id)
);

CREATE TABLE IF NOT EXISTS store.orders(
order_id     BIGSERIAL  PRIMARY KEY,
customer_id  BIGINT NOT NULL REFERENCES  store.customer(customer_id),
employee_id  BIGINT NOT NULL REFERENCES  store.employee(employee_id),
order_date   DATE   NOT NULL ,
order_status TEXT NOT NULL CHECK ( order_status IN ('pending', 'shipped', 'delivered'))
);

-- this table is created to establish many-to-many relationship between orders on product, because in one order can be 
-- multiple products and one product can occur in many orders
CREATE TABLE IF NOT EXISTS store.product_order(
order_id   BIGINT REFERENCES store.orders(order_id),
product_id BIGINT REFERENCES store.product(product_id),
units  	INT NOT NULL CHECK(units > 0),
PRIMARY KEY(order_id, product_id)
);

CREATE TABLE IF NOT EXISTS store.inventory(
inventory_id  BIGSERIAL PRIMARY KEY,
product_id	  BIGINT  NOT NULL REFERENCES store.product(product_id),
quantity	  INT NOT NULL DEFAULT 0 CHECK(quantity >=0)   -- by default the quantity is 0
);


-- Created this branch table to establish many-to-many relationship between address and customer, since in one address can be 
-- many customers and one customer can have many addresses
CREATE TABLE IF NOT EXISTS store.customer_address(
address_id  BIGINT NOT NULL REFERENCES store.address(address_id),
customer_id BIGINT NOT NULL REFERENCES store.customer(customer_id),
PRIMARY KEY(address_id, customer_id)
);


-- ALTER

-- Use ALTER TABLE to add at least 5 check constraints across the tables to restrict certain values

--date to be inserted, which must be greater than January 1, 2026
ALTER TABLE store.orders
ADD CONSTRAINT check_year CHECK(order_date >= '2026-01-01');

--inserted measured value that cannot be negative
ALTER TABLE store.product
ADD CONSTRAINT price_positive CHECK (price > 0); -- to ensure the price is not negative or equal to 0
-- inserted value that can only be a specific value is not null
ALTER TABLE store.product
ALTER COLUMN price SET NOT NULL;



-- inserted value that can only be a specific value is unique
ALTER TABLE store.category
ADD CONSTRAINT category_unique  UNIQUE (category);


ALTER TABLE store.employee
ADD CONSTRAINT valid_email  CHECK(email LIKE '%@gmail.com');  --email is checked whether it contain %@gmail.com at the end

ALTER TABLE store.orders
ALTER COLUMN order_date SET DEFAULT NOW();

--4. Populate the tables with the sample data generated, ensuring each table has at least 6+ rows (for a total of 36+ rows 
--in all the tables) for the last 3 months.

-- Here for parent tables I used INSERT INTO ... VALUES because I am entering values manually and not taking data from other
-- tables
INSERT INTO store.customer(first_name, last_name, email)
VALUES
('Yamac', 'Kocovali', 'yamackocovali@gmail.com'),
('Vartolu', 'Sadettin', 'vartolusadettin49@gmail.com'),
('Jumali', 'Kocovali', 'jumalikucovali@gmail.com'),
('Alico', 'Ban', 'alicoban@gmail.com'),
('Cengiz', 'Erdenet', 'cengizerdenet@gmail.com'),
('Akin', 'Kocovali', 'akinkocovali@gmail.com')
ON CONFLICT (email) DO NOTHING     -- it skips the row if its email exists in the table and prevent from error
RETURNING *;   

INSERT INTO store.address(name)
VALUES
('12 Mustaqillik Street, Qarshi, Qashqadarya Region'),
('45 Nasaf Street, Qarshi, Qashqadarya Region'),
('7A Amir Temur Street, Qarshi, Qashqadarya Region'),
('103 Alisher Navoi Street, Qarshi, Qashqadarya Region'),
('28 Bobur Street, Qarshi, Qashqadarya Region'),
('66 Shahrisabz Street, Qarshi, Qashqadarya Region'),
('91B Istiqlol Street, Qarshi, Qashqadarya Region'),
('14 Gulshan Neighborhood, Qarshi, Qashqadarya Region'),
('39 Navruz Street, Qarshi, Qashqadarya Region'),
('5 Yangi Hayot Street, Qarshi, Qashqadarya Region'),
('77 Temiryolchilar Street, Qarshi, Qashqadarya Region'),
('22 Bogbonlar Street, Qarshi, Qashqadarya Region')
ON CONFLICT (name) DO NOTHING
RETURNING *;

INSERT INTO store.category(category)
VALUES
('phone'),
('laptop'),
('headphone'),
('mouse'),
('monitor'),
('accessories')
ON CONFLICT (category) DO NOTHING   -- it skips the row if its email exists in the table and prevent from error
RETURNING *;   

INSERT INTO store.supplier(name)
VALUES
('DELL'),
('SONY'),
('APPLE'),
('Xiaomi'),
('LOGITECH'),
('SAMSUNG')
ON CONFLICT (name) DO NOTHING    -- it skips the row if its email exists in the table and prevent from error
RETURNING *;   

INSERT INTO store.employee(first_name, last_name, email)
VALUES
('Daniel', 'Cormie', 'danielcormie@gmail.com'),
('Steve', 'Jobs', 'stevejobs@gmail.com'),
('Amrish', 'Puri', 'amrishpuri@gmail.com'),
('Raj', 'Kumar', 'rajkumar@gmail.com'),
('Abduqodir', 'Husanov', 'abduqodirhusanov@gmail.com'),
('Jorj', 'Oruell', 'jorjoruell@gmail.com')
ON CONFLICT (email) DO NOTHING    -- it skips the row if its email exists in the table and prevent from error
RETURNING *;   


INSERT INTO store.product(product_name, price, category_id, supplier_id)
SELECT	p.product_name, p.price, c.category_id, s.supplier_id
FROM (VALUES
('DELL g15 gaming', 700.10, 'laptop', 'DELL'),
('Logitech mouse', 25.50, 'mouse', 'LOGITECH' ),
('iPhone 13', 999.99, 'phone', 'APPLE'),
('Samsung Monitor 24"', 180.00, 'monitor', 'SAMSUNG'),
('Sony WH-1000XM4', 300.00, 'headphone', 'SONY'),
('USB-C Charger', 20.00, 'accessories', 'Xiaomi')) AS p(product_name, price, category, supplier)
INNER JOIN store.category c
			ON c.category = p.category
INNER JOIN store.supplier s
			ON s.name = p.supplier
ON CONFLICT(product_name) DO NOTHING -- it skips the row if its email exists in the table and prevent from error
RETURNING *
;

INSERT INTO store.orders(customer_id, employee_id, order_status)
SELECT		c.customer_id, e.employee_id, o.status
FROM (VALUES
('yamackocovali@gmail.com', 'danielcormie@gmail.com', 'pending'),
('vartolusadettin49@gmail.com', 'stevejobs@gmail.com', 'pending'),
('jumalikucovali@gmail.com', 'amrishpuri@gmail.com', 'pending'),
('alicoban@gmail.com', 'rajkumar@gmail.com', 'pending'),
('cengizerdenet@gmail.com', 'abduqodirhusanov@gmail.com', 'pending'),
('akinkocovali@gmail.com', 'jorjoruell@gmail.com', 'pending')) AS o(customer_email, employee_email, status)
INNER JOIN store.customer c
			ON c.email = o.customer_email
INNER JOIN store.employee e
			ON e.email = o.employee_email
RETURNING *;

INSERT INTO store.product_order(order_id, product_id, units)
SELECT	o.order_id, p.product_id, op.units
FROM (
VALUES
('yamackocovali@gmail.com', 'danielcormie@gmail.com', 'DELL g15 gaming', 1),
('yamackocovali@gmail.com', 'danielcormie@gmail.com', 'iPhone 13', 1),
('jumalikucovali@gmail.com', 'amrishpuri@gmail.com', 'USB-C Charger', 3),
('jumalikucovali@gmail.com', 'amrishpuri@gmail.com', 'Logitech mouse', 1),
('vartolusadettin49@gmail.com', 'stevejobs@gmail.com', 'DELL g15 gaming', 5),
('vartolusadettin49@gmail.com', 'stevejobs@gmail.com', 'Logitech mouse', 5 ),
('vartolusadettin49@gmail.com', 'stevejobs@gmail.com', 'iPhone 13', 5),
('alicoban@gmail.com', 'rajkumar@gmail.com', 'USB-C Charger', 10),
('cengizerdenet@gmail.com', 'abduqodirhusanov@gmail.com', 'iPhone 13', 1),
('akinkocovali@gmail.com', 'jorjoruell@gmail.com', 'iPhone 13', 4)

) AS op(customer_email, employee_email, product_name, units)
INNER JOIN store.customer c
		ON c.email = op.customer_email
INNER JOIN store.employee e
		ON e.email = op.employee_email
INNER JOIN store.orders o
		ON o.customer_id = c.customer_id AND o.employee_id = e.employee_id
INNER JOIN store.product p
		ON p.product_name = op.product_name
ON CONFLICT (order_id, product_id) DO NOTHING
RETURNING *;

-- ON CONFLICT.. is not used since one product can occur in multiple inventories
INSERT INTO store.inventory(product_id, quantity)
SELECT   p.product_id, i.quantity
FROM(
VALUES
('DELL g15 gaming', 500),
('Logitech mouse',  2000),
('iPhone 13', 1000),
('Samsung Monitor 24"', 700),
('USB-C Charger', 3000),
('Sony WH-1000XM4', 1250)
) AS i(product_name, quantity)
INNER JOIN store.product p
		ON p.product_name = i.product_name
RETURNING *;


INSERT INTO store.customer_address(customer_id, address_id)
SELECT
    c.customer_id,
    a.address_id
FROM (
    VALUES
    ('yamackocovali@gmail.com', '12 Mustaqillik Street, Qarshi, Qashqadarya Region'),
    ('vartolusadettin49@gmail.com', '45 Nasaf Street, Qarshi, Qashqadarya Region'),
    ('jumalikucovali@gmail.com', '7A Amir Temur Street, Qarshi, Qashqadarya Region'),
    ('alicoban@gmail.com', '103 Alisher Navoi Street, Qarshi, Qashqadarya Region'),
    ('cengizerdenet@gmail.com', '28 Bobur Street, Qarshi, Qashqadarya Region'),
    ('akinkocovali@gmail.com', '66 Shahrisabz Street, Qarshi, Qashqadarya Region'),
    ('yamackocovali@gmail.com', '91B Istiqlol Street, Qarshi, Qashqadarya Region'),
    ('vartolusadettin49@gmail.com', '14 Gulshan Neighborhood, Qarshi, Qashqadarya Region'),
    ('jumalikucovali@gmail.com', '39 Navruz Street, Qarshi, Qashqadarya Region'),
    ('alicoban@gmail.com', '5 Yangi Hayot Street, Qarshi, Qashqadarya Region'),
    ('cengizerdenet@gmail.com', '77 Temiryolchilar Street, Qarshi, Qashqadarya Region'),
    ('akinkocovali@gmail.com', '22 Bogbonlar Street, Qarshi, Qashqadarya Region')
) AS ea(email, address)
INNER JOIN store.customer c
    ON c.email = ea.email
INNER JOIN store.address a
			ON ea.address = a.name
ON CONFLICT (customer_id, address_id) DO NOTHING
RETURNING *;

-- 5. Create the following functions.
-- 5.1  Create a function that updates data in one of your tables

INSERT INTO store.supplier(name)  -- I added new value first to update it with function
VALUES
('PANASONIC')
ON CONFLICT(name) DO NOTHING
RETURNING *;

CREATE OR REPLACE FUNCTION add_supplier(id BIGINT, new_value TEXT)
RETURNS SETOF store.supplier
AS $$
UPDATE store.supplier
SET name = new_value
WHERE supplier_id = id
RETURNING *
$$
LANGUAGE SQL;

SELECT add_supplier(7, 'MOTOROLLA');

drop function add_product
--5.2 Create a function that adds a new transaction to your transaction table. 
CREATE OR REPLACE FUNCTION add_product(
    p_product_name VARCHAR(50),
    p_price DECIMAL,
    p_category TEXT,
    p_supplier TEXT
)
RETURNS TEXT
LANGUAGE SQL
AS $$
INSERT INTO store.product ( product_name, price, category_id, supplier_id)
SELECT 
        p_product_name,
        p_price,
        c.category_id,
        s.supplier_id
FROM store.category c
JOIN store.supplier s
        ON s.name = p_supplier
WHERE c.category = p_category;
SELECT 'Product inserted successfully';
$$;

SELECT add_product('Iphone 8', 400.50, 'phone', 'APPLE')

--6. Create a view that presents analytics for the most recently added quarter in your database. Ensure that the result
--excludes irrelevant fields such as surrogate keys and duplicate entries.

CREATE OR REPLACE VIEW store.latest_quarter_sales AS
SELECT	p.product_name, SUM(po.units) AS units_sold, SUM(po.units * p.price) AS total_price
FROM	store.product p
INNER JOIN store.product_order po
			ON po.product_id = p.product_id
INNER JOIN store.orders o
			ON o.order_id = po.order_id
WHERE o.order_date >= DATE_TRUNC('quarter', CURRENT_DATE)			
GROUP BY    p.product_name;

SELECT * 
FROM  store.latest_quarter_sales;

-- 7. Create a read-only role for the manager. This role should have permission to perform SELECT queries on the database
--tables, and also be able to log in. Please ensure that you adhere to best practices for database security when defining
--this role
CREATE ROLE manager;

GRANT ALL ON SCHEMA store TO manager;

