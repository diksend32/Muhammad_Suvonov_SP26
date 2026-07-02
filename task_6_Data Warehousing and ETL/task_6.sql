CREATE SCHEMA IF NOT EXISTS bl_3nf;

CREATE TABLE IF NOT EXISTS  bl_3nf.ce_geography(
city_sk BIGSERIAL PRIMARY KEY,
city_src_id VARCHAR(50)  UNIQUE NOT NULL,
city VARCHAR(50)  UNIQUE NOT NULL,
country VARCHAR(50) NOT NULL,
region  VARCHAR(50) NOT NULL,
continent VARCHAR(50) NOT NULL,
postal_code VARCHAR(50) UNIQUE NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_3nf.ce_payments(
payment_sk BIGSERIAL PRIMARY KEY,
payment_src_id VARCHAR(50)  UNIQUE NOT NULL,
payment_type VARCHAR(50) NOT NULL,
currency VARCHAR(50)  NOT NULL,
usd_rate DECIMAL(5,2),
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);


CREATE TABLE bl_3nf.ce_customers_scd (
    customer_sk BIGSERIAL PRIMARY KEY,
    customer_src_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(50) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('Male', 'Female', 'Unknown')),
    customer_address VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    source_entity VARCHAR(50) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    insert_dt TIMESTAMP NOT NULL,
    update_dt TIMESTAMP NOT NULL,
    start_dt DATE NOT NULL,
    end_dt DATE NOT NULL,
    is_active CHAR(1) NOT NULL CHECK (is_active IN ('Y', 'N'))
);

CREATE TABLE IF NOT EXISTS bl_3nf.ce_employees(
employee_sk BIGSERIAL PRIMARY KEY,
employee_src_id  VARCHAR(50) NOT NULL,
employee_name  VARCHAR(50)   NOT NULL,
employee_email VARCHAR(100) CHECK (employee_email LIKE '%@uzbekland.com'),
gender TEXT CHECK (gender IN ('Male', 'Female')),
employee_role VARCHAR(50)  NOT NULL CHECK (employee_role IN ('Seller', 'Courier')),
date_of_birth DATE NOT NULL,
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);



CREATE TABLE IF NOT EXISTS bl_3nf.ce_suppliers(
supplier_sk BIGSERIAL PRIMARY KEY,
supplier_src_id  VARCHAR(50) NOT NULL,
supplier_name  VARCHAR(50)   NOT NULL,
supplier_email VARCHAR(100) CHECK (supplier_email LIKE '%@gmail.com'),
street_address VARCHAR(50) NOT NULL,
supplier_city  VARCHAR(50) NOT NULL,
supplier_country VARCHAR(50) NOT NULL,
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);



CREATE TABLE IF NOT EXISTS bl_3nf.ce_products(
product_sk BIGSERIAL PRIMARY KEY,
product_src_id VARCHAR(50) NOT NULL,
supplier_sk BIGINT REFERENCES bl_3nf.ce_suppliers(supplier_sk),
product_name VARCHAR(50) NOT NULL,
category VARCHAR(50) NOT NULL,
brand  VARCHAR(50) NOT NULL,
made_in VARCHAR(50) NOT NULL,
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);



CREATE TABLE IF NOT EXISTS  bl_3nf.ce_branches(
branch_sk BIGSERIAL PRIMARY KEY,
branch_src_id VARCHAR(50)  UNIQUE NOT NULL,
branch_name VARCHAR(50)  UNIQUE NOT NULL,
branch_address VARCHAR(50)  UNIQUE NOT NULL,
city_sk BIGINT REFERENCES bl_3nf.ce_geography(city_sk),
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);




CREATE TABLE IF NOT EXISTS bl_3nf.ce_orders(
    order_sk BIGSERIAL PRIMARY KEY,
    order_src_id VARCHAR(50) NOT NULL,
    customer_sk BIGINT REFERENCES bl_3nf.ce_customers_scd(customer_sk),
    employee_sk BIGINT REFERENCES bl_3nf.ce_employees(employee_sk),
    payment_sk BIGINT REFERENCES bl_3nf.ce_payments(payment_sk),
    branch_sk BIGINT REFERENCES bl_3nf.ce_branches(branch_sk),
    order_date DATE NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    order_type VARCHAR(50) NOT NULL,
    source_entity VARCHAR(50) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    insert_dt TIMESTAMP NOT NULL,
    update_dt TIMESTAMP NOT NULL
);




CREATE TABLE IF NOT EXISTS bl_3nf.ce_order_item(
order_item_sk BIGSERIAL PRIMARY KEY,
order_src_id VARCHAR(50) NOT NULL,
order_sk BIGINT REFERENCES  bl_3nf.ce_orders(order_sk),
product_sk BIGINT REFERENCES  bl_3nf.ce_products(product_sk),
quantity INT NOT NULL CHECK(quantity > 0),
unit_price_usd DECIMAL(5,2) CHECK(unit_price_usd > 0),
total_price_usd DECIMAL(5,2) CHECK(total_price_usd > 0), 
unit_price_local DECIMAL(5,2) CHECK(unit_price_local > 0),
total_price_local DECIMAL(5,2) CHECK(total_price_local > 0), 
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);




CREATE TABLE  IF NOT EXISTS  bl_3nf.source1_offline (
    order_id VARCHAR(50),
    order_date DATE,
    order_status VARCHAR(50),
    order_type VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(50),
    customer_email VARCHAR(100),
    product_id VARCHAR(50),
    product_name VARCHAR(100),
    category VARCHAR(100),
    brand VARCHAR(100),
    made_in VARCHAR(100),
    payment_id VARCHAR(50),
    payment_type VARCHAR(50),
    quantity INT,
    unit_price_in_usd DECIMAL(12,2),
    total_amount_usd DECIMAL(12,2),
    currency VARCHAR(50),
    usd_rate DECIMAL(10,4),
    unit_price_in_local_currency DECIMAL(12,2),
    total_price_in_local_currency DECIMAL(12,2),
    branch_id VARCHAR(50),
    branch_name VARCHAR(100),
    branch_address VARCHAR(100),
    branch_opened_year INT,
    branch_size_sqm INT,
    branch_manager_id VARCHAR(50),
    branch_manager_name VARCHAR(100),
    branch_manager_email VARCHAR(100),
    branch_manager_gender VARCHAR(50),
    branch_manager_birth_date DATE,
    city_id VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(100),
    region VARCHAR(100),
    continent VARCHAR(100),
    postal_code VARCHAR(50),
    supplier_id VARCHAR(50),
    supplier VARCHAR(100),
    supplier_email VARCHAR(100),
    supplier_street_address VARCHAR(100),
    supplier_city VARCHAR(100),
    supplier_country VARCHAR(100),
    supplier_primary_industry VARCHAR(100),
    seller_id VARCHAR(50),
    seller_name VARCHAR(100),
    seller_email VARCHAR(100),
    seller_gender VARCHAR(50),
    seller_birth_date DATE
);


SELECT * FROM bl_3nf.source1_offline



CREATE TABLE IF NOT EXISTS  bl_3nf.source2_online (
    order_id VARCHAR(50),
    order_date DATE,
    order_status VARCHAR(50),
    order_type VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    customer_birth_date DATE,
    customer_address VARCHAR(100),
    customer_gender VARCHAR(50),
    product_id VARCHAR(50),
    product_name VARCHAR(100),
    product_category VARCHAR(100),
    product_brand VARCHAR(100),
    product_made_in VARCHAR(100),
    payment_id VARCHAR(50),
    quantity INT,
    unit_price_in_usd DECIMAL(12,2),
    total_amount_in_usd DECIMAL(12,2),
    payment_type VARCHAR(50),
    currency VARCHAR(50),
    usd_rate DECIMAL(10,4),
    unit_price_in_local_currency DECIMAL(12,2),
    total_price_in_local_currency DECIMAL(12,2),
    city_id VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(100),
    region VARCHAR(100),
    continent VARCHAR(100),
    postal_code VARCHAR(50),
    supplier_id VARCHAR(50),
    supplier VARCHAR(100),
    supplier_email VARCHAR(100),
    supplier_street_address VARCHAR(100),
    supplier_city VARCHAR(100),
    supplier_country VARCHAR(100),
    supplier_primary_industry VARCHAR(100),
    courier_id VARCHAR(50),
    courier_name VARCHAR(100),
    courier_email VARCHAR(100),
    courier_gender VARCHAR(50),
    courier_birth_date DATE,
    branch_id VARCHAR(50),
    branch_name VARCHAR(100),
    branch_address VARCHAR(100),
    branch_opened_year INT,
    branch_size_sqm INT,
    branch_manager_id VARCHAR(50),
    branch_manager_name VARCHAR(100),
    branch_manager_email VARCHAR(100),
    branch_manager_gender VARCHAR(50),
    branch_manager_birth_date DATE
);


-- ADDING DATA FROM source1 and source2

INSERT INTO bl_3nf.ce_geography(city_src_id, city, country, region, continent, postal_code, insert_dt, update_dt)
SELECT
    COALESCE(s.city_id, 'n.a'),
    COALESCE(s.city, 'n.a'),
    COALESCE(s.country, 'n.a'),
    COALESCE(s.region, 'n.a'),
    COALESCE(s.continent, 'n.a'),
    COALESCE(s.postal_code, 'n.a'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM
(
    SELECT city_id, city, country, region, continent, postal_code
    FROM bl_3nf.source1_offline

    UNION

    SELECT city_id, city, country, region, continent, postal_code
    FROM bl_3nf.source2_online
) s
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_geography g
    WHERE g.city_src_id = s.city_id
);

COMMIT;


INSERT INTO bl_3nf.ce_payments(payment_src_id, payment_type, currency, usd_rate, source_entity, source_system, insert_dt, update_dt)
SELECT 
	  COALESCE(a.payment_id, 'n.a'), 
	  COALESCE(a.payment_type,  'n.a'), 
	  COALESCE(a.currency, 'n.a'), 
	  COALESCE(a.usd_rate, -1.0), 
	   'source1',
	   'offline',
	   CURRENT_TIMESTAMP,
	   CURRENT_TIMESTAMP
FROM  bl_3nf.source1_offline a

WHERE NOT EXISTS(
	SELECT 1
	FROM bl_3nf.ce_payments b
	WHERE b.payment_src_id = a.payment_id
);
COMMIT;



INSERT INTO bl_3nf.ce_payments(payment_src_id, payment_type, currency, usd_rate, source_entity, source_system, insert_dt, update_dt)
SELECT 
	  COALESCE(a.payment_id), 
	  COALESCE(a.payment_id, 'n.a'), 
	  COALESCE(a.payment_type,  'n.a'), 
	  COALESCE(a.currency, 'n.a'), 
	  COALESCE(a.usd_rate, -1.0), 
	   'source2',
	   'online',
	   CURRENT_TIMESTAMP,
	   CURRENT_TIMESTAMP
FROM  bl_3nf.source2_online a

WHERE NOT EXISTS(
	SELECT 1
	FROM bl_3nf.ce_payments b
	WHERE b.payment_src_id = a.payment_id
);
COMMIT;


INSERT INTO bl_3nf.ce_customers_scd
(
    customer_src_id,
    customer_name,
    customer_email,
    gender,
    customer_address,
    date_of_birth,
    source_entity,
    source_system,
    insert_dt,
    update_dt,
    start_dt,
    end_dt,
    is_active
)
SELECT
    COALESCE(a.customer_id, 'n.a'),
    COALESCE(a.customer_name, 'n.a'),
    COALESCE(a.customer_email, 'n.a@gmail.com'),
	'Unknown',
    COALESCE(a.gender, 'Unknown'),
	'9999-12-31',
	'source1',
    'offline',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CURRENT_DATE,
    DATE '9999-12-31',
    'Y'
FROM bl_3nf.source1_offline a
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_customers_scd b
    WHERE b.customer_src_id = a.customer_id
      AND b.is_active = 'Y'
);

COMMIT;



INSERT INTO bl_3nf.ce_customers_scd
(
    customer_src_id,
    customer_name,
    customer_email,
    gender,
    customer_address,
    date_of_birth,
    source_entity,
    source_system,
    insert_dt,
    update_dt,
    start_dt,
    end_dt,
    is_active
)
SELECT
    COALESCE(a.customer_id, 'n.a'),
    COALESCE(a.customer_name, 'n.a'),
    COALESCE(a.customer_email, 'n.a@gmail.com'),
    COALESCE(a.customer_gender, 'Male'),
    COALESCE(a.customer_address, 'n.a'),
    COALESCE(a.customer_birth_date, DATE '1900-01-01'),
    'source2',
    'online',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CURRENT_DATE,
    DATE '9999-12-31',
    'Y'
FROM bl_3nf.source2_online a
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_customers_scd b
    WHERE b.customer_src_id = a.customer_id
      AND b.is_active = 'Y'
);

COMMIT;


INSERT INTO bl_3nf.ce_employees
(
    employee_src_id,
    employee_name,
    employee_email,
    gender,
    employee_role,
    date_of_birth,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT DISTINCT
    COALESCE(a.seller_id, 'n.a'),
    COALESCE(a.seller_name, 'n.a'),
    COALESCE(a.seller_email, 'n.a@uzbekland.com'),
    COALESCE(a.seller_gender, 'Unknown'),
    'Seller',
    COALESCE(a.seller_birth_date, DATE '1900-01-01'),
    'source1',
    'offline',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source1_offline a
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_employees b
    WHERE b.employee_src_id = a.seller_id
);

COMMIT;




INSERT INTO bl_3nf.ce_employees
(
    employee_src_id,
    employee_name,
    employee_email,
    gender,
    employee_role,
    date_of_birth,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT DISTINCT
    COALESCE(a.courier_id, 'n.a'),
    COALESCE(a.courier_name, 'n.a'),
    COALESCE(a.courier_email, '%@uzbekland.com'),
    COALESCE(a.courier_gender, 'Unknown'),
    'Courier',
    COALESCE(a.courier_birth_date, DATE '1900-01-01'),
    'source2',
    'online',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source2_online a
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_employees b
    WHERE b.employee_src_id = a.courier_id
);

COMMIT;

INSERT INTO bl_3nf.ce_suppliers
(
    supplier_src_id,
    supplier_name,
    supplier_email,
    street_address,
    supplier_city,
    supplier_country,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    COALESCE(a.supplier_id, 'n.a'),
    COALESCE(a.supplier, 'n.a'),
    COALESCE(a.supplier_email, 'n.a@gmail.com'),
    COALESCE(a.supplier_street_address, 'n.a'),
    COALESCE(a.supplier_city, 'n.a'),
    COALESCE(a.supplier_country, 'n.a'),
    'source1',
    'offline',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source1_offline a
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_suppliers b
    WHERE b.supplier_src_id = a.supplier_id
);

COMMIT;


INSERT INTO bl_3nf.ce_suppliers
(
    supplier_src_id,
    supplier_name,
    supplier_email,
    street_address,
    supplier_city,
    supplier_country,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    COALESCE(a.supplier_id, 'n.a'),
    COALESCE(a.supplier, 'n.a'),
    COALESCE(a.supplier_email, 'n.a@gmail.com'),
    COALESCE(a.supplier_street_address, 'n.a'),
    COALESCE(a.supplier_city, 'n.a'),
    COALESCE(a.supplier_country, 'n.a'),
    'source2',
    'online',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source2_online a
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_suppliers b
    WHERE b.supplier_src_id = a.supplier_id
);

COMMIT;

INSERT INTO bl_3nf.ce_products
(
    product_src_id,
    supplier_sk,
    product_name,
    category,
    brand,
    made_in,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT DISTINCT
    COALESCE(a.product_id, 'n.a'),
    COALESCE(s.supplier_sk, -1),
    COALESCE(a.product_name, 'n.a'),
    COALESCE(a.category, 'n.a'),
    COALESCE(a.brand, 'n.a'),
    COALESCE(a.made_in, 'n.a'),
    'source1',
    'offline',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source1_offline a
LEFT JOIN bl_3nf.ce_suppliers s
    ON s.supplier_src_id = a.supplier_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_products p
    WHERE p.product_src_id = a.product_id
);

COMMIT;

INSERT INTO bl_3nf.ce_products
(
    product_src_id,
    supplier_sk,
    product_name,
    category,
    brand,
    made_in,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT DISTINCT
    COALESCE(a.product_id, 'n.a'),
    COALESCE(s.supplier_sk, -1),
    COALESCE(a.product_name, 'n.a'),
    COALESCE(a.category, 'n.a'),
    COALESCE(a.brand, 'n.a'),
    COALESCE(a.made_in, 'n.a'),
    'source2',
    'online',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source2_online a
LEFT JOIN bl_3nf.ce_suppliers s
    ON s.supplier_src_id = a.supplier_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_products p
    WHERE p.product_src_id = a.product_id
);

COMMIT;

INSERT INTO bl_3nf.ce_branches
(
    branch_src_id,
    branch_name,
    branch_address,
    city_sk,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT DISTINCT 
    COALESCE(a.branch_id, 'n.a'),
    COALESCE(a.branch_name, 'n.a'),
    COALESCE(a.branch_address, 'n.a'),
    COALESCE(g.city_sk, 1),
    'source1',
    'offline',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source1_offline a
LEFT JOIN bl_3nf.ce_geography g
    ON g.city_src_id = a.city_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_branches b
    WHERE b.branch_src_id = a.branch_id
);

COMMIT;

INSERT INTO bl_3nf.ce_orders
(
    order_src_id,
    customer_sk,
    employee_sk,
    payment_sk,
    branch_sk,
    order_date,
    order_status,
    order_type,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    COALESCE(a.order_id, 'n.a'),
    COALESCE(c.customer_sk, 1),
    COALESCE(e.employee_sk, 1),
    COALESCE(p.payment_sk, 1),
    COALESCE(b.branch_sk, 1),
    COALESCE(a.order_date, DATE '1900-01-01'),
    COALESCE(a.order_status, 'n.a'),
    COALESCE(a.order_type, 'n.a'),
    'source1',
    'offline',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source1_offline a
LEFT JOIN bl_3nf.ce_customers_scd c
    ON c.customer_src_id = a.customer_id
   AND c.is_active = 'Y'
LEFT JOIN bl_3nf.ce_employees e
    ON e.employee_src_id = a.seller_id
LEFT JOIN bl_3nf.ce_payments p
    ON p.payment_src_id = a.payment_id
LEFT JOIN bl_3nf.ce_branches b
    ON b.branch_src_id = a.branch_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_orders o
    WHERE o.order_src_id = a.order_id
);

COMMIT;


INSERT INTO bl_3nf.ce_orders
(
    order_src_id,
    customer_sk,
    employee_sk,
    payment_sk,
    branch_sk,
    order_date,
    order_status,
    order_type,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    COALESCE(a.order_id, 'n.a'),
    COALESCE(c.customer_sk, 1),
    COALESCE(e.employee_sk, 1),
    COALESCE(p.payment_sk, 1),
    COALESCE(b.branch_sk, 1),
    COALESCE(a.order_date, DATE '1900-01-01'),
    COALESCE(a.order_status, 'n.a'),
    COALESCE(a.order_type, 'n.a'),
    'source2',
    'online',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source2_online a
LEFT JOIN bl_3nf.ce_customers_scd c
    ON c.customer_src_id = a.customer_id
   AND c.is_active = 'Y'
LEFT JOIN bl_3nf.ce_employees e
    ON e.employee_src_id = a.courier_id
LEFT JOIN bl_3nf.ce_payments p
    ON p.payment_src_id = a.payment_id
LEFT JOIN bl_3nf.ce_branches b
    ON b.branch_src_id = a.branch_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_orders o
    WHERE o.order_src_id = a.order_id
);

COMMIT;

INSERT INTO bl_3nf.ce_order_item
(
    order_src_id,
    order_sk,
    product_sk,
    quantity,
    unit_price_usd,
    total_price_usd,
    unit_price_local,
    total_price_local,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    COALESCE(a.order_id, 'n.a'),
    COALESCE(o.order_sk, 1),
    COALESCE(p.product_sk, 1),
    COALESCE(a.quantity, -1),
    COALESCE(a.unit_price_in_usd, -1.0),
    COALESCE(a.total_amount_in_usd, -1.0),
    COALESCE(a.unit_price_in_local_currency, -1.0),
    COALESCE(a.total_price_in_local_currency, -1.0),
    'source1',
    'offline',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source1_offline a
LEFT JOIN bl_3nf.ce_orders o
    ON o.order_src_id = a.order_id
LEFT JOIN bl_3nf.ce_products p
    ON p.product_src_id = a.product_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_order_item oi
    WHERE oi.order_src_id = a.order_id
      AND oi.product_sk = p.product_sk
);

COMMIT;


INSERT INTO bl_3nf.ce_order_item
(
    order_src_id,
    order_sk,
    product_sk,
    quantity,
    unit_price_usd,
    total_price_usd,
    unit_price_local,
    total_price_local,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    COALESCE(a.order_id, 'n.a'),
    COALESCE(o.order_sk, 1),
    COALESCE(p.product_sk, 1),
    COALESCE(a.quantity, -1),
    COALESCE(a.unit_price_in_usd, -1.0),
    COALESCE(a.total_amount_in_usd, -1.0),
    COALESCE(a.unit_price_in_local_currency, -1.0),
    COALESCE(a.total_price_in_local_currency, -1.0),
    'source2',
    'online',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.source2_online a
LEFT JOIN bl_3nf.ce_orders o
    ON o.order_src_id = a.order_id
LEFT JOIN bl_3nf.ce_products p
    ON p.product_src_id = a.product_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM bl_3nf.ce_order_item oi
    WHERE oi.order_src_id = a.order_id
      AND oi.product_sk = p.product_sk
);

COMMIT;

