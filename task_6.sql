supplieridinsert_dtsource_entitysupplier_src_idbl_3nf.ce_suppliersCREATE SCHEMA IF NOT EXISTS bl_3nf;

CREATE SEQUENCE bl_3nf.seq_ce_geography_sk;
CREATE SEQUENCE bl_3nf.seq_ce_customers_sk;
CREATE SEQUENCE bl_3nf.seq_ce_products_sk;
CREATE SEQUENCE bl_3nf.seq_ce_suppliers_sk;
CREATE SEQUENCE bl_3nf.seq_ce_employees_sk;
CREATE SEQUENCE bl_3nf.seq_ce_branches_sk;
CREATE SEQUENCE bl_3nf.seq_ce_payments_sk;
CREATE SEQUENCE bl_3nf.seq_ce_orders_sk;
CREATE SEQUENCE bl_3nf.seq_ce_order_items_sk;

CREATE TABLE IF NOT EXISTS  bl_3nf.ce_geography(
city_sk BIGINT PRIMARY KEY,
city_src_id VARCHAR(50)  UNIQUE NOT NULL,
city VARCHAR(50)  UNIQUE NOT NULL,
country VARCHAR(50) NOT NULL,
region  VARCHAR(50) NOT NULL,
continent VARCHAR(50) NOT NULL,
postal_code VARCHAR(50) UNIQUE NOT NULL,
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);




CREATE TABLE IF NOT EXISTS bl_3nf.ce_payments(
payment_sk BIGINT PRIMARY KEY,
payment_src_id VARCHAR(50)  UNIQUE NOT NULL,
payment_type VARCHAR(50) NOT NULL,
currency VARCHAR(50)  NOT NULL,
usd_rate DECIMAL(5,2),
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS  bl_3nf.ce_customers_scd (
    customer_sk BIGINT PRIMARY KEY,
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
employee_sk BIGINT PRIMARY KEY,
employee_src_id  VARCHAR(50) NOT NULL,
employee_name  VARCHAR(50)   NOT NULL,
employee_email VARCHAR(100) CHECK (employee_email LIKE '%@uzbekland.com'),
gender TEXT CHECK (gender IN ('Male', 'Female', 'Unknown')),
employee_role VARCHAR(50)  NOT NULL CHECK (employee_role IN ('Seller', 'Courier')),
date_of_birth DATE NOT NULL,
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);



CREATE TABLE IF NOT EXISTS bl_3nf.ce_suppliers(
supplier_sk BIGINT PRIMARY KEY,
supplier_src_id  VARCHAR(50) NOT NULL,
supplier_name  VARCHAR(50)   NOT NULL,
supplier_email VARCHAR(100) CHECK (supplier_email LIKE '%@gmail.com'),
street_address VARCHAR(50) NOT NULL,
supplier_city  VARCHAR(50) NOT NULL,
supplier_country VARCHAR(50) NOT NULL,
source_entity VARCHAR(50) NOT NULL,
source_system VARCHAR(50) NOT NULL,
supplier_primary_industry VARCHAR(50) NOT NULL,
insert_dt TIMESTAMP NOT NULL,
update_dt TIMESTAMP NOT NULL
);



CREATE TABLE IF NOT EXISTS bl_3nf.ce_products(
product_sk BIGINT PRIMARY KEY,
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




CREATE TABLE bl_3nf.ce_branches (
    branch_sk BIGINT PRIMARY KEY,
    branch_src_id VARCHAR(50) UNIQUE NOT NULL,
    branch_name VARCHAR(200) NOT NULL,
    branch_address VARCHAR(300) NOT NULL,
    city_sk BIGINT NOT NULL
    REFERENCES bl_3nf.ce_geography(city_sk),
    opened_year INT,
    branch_size_sqm NUMERIC(12,2),
    manager_src_id VARCHAR(50) NOT NULL,
    manager_name VARCHAR(200) NOT NULL,
    manager_email VARCHAR(200),
    manager_gender VARCHAR(20) CHECK (manager_gender IN ('Male','Female','Unknown')),
    manager_birth_date DATE NOT NULL,
    source_entity VARCHAR(50) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    insert_dt TIMESTAMP NOT NULL,
    update_dt TIMESTAMP NOT NULL
);




CREATE TABLE IF NOT EXISTS bl_3nf.ce_orders(
    order_sk BIGINT PRIMARY KEY,
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
order_item_sk BIGINT PRIMARY KEY,
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

---------------------------------------------------------------

-- Adding Default Rows

INSERT INTO bl_3nf.ce_geography (city_sk, city_src_id, city, country, region, continent, postal_code, source_entity, source_system, insert_dt, update_dt
)
SELECT
    -1, 'n.a.', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown',
    'MANUAL', 'MANUAL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_geography WHERE city_sk = -1
);


INSERT INTO bl_3nf.ce_payments (payment_sk, payment_src_id, payment_type, currency, usd_rate, source_entity, source_system, insert_dt, update_dt
    )
SELECT
    -1, 'n.a.', 'Unknown', 'Unknown', 1.00,
    'MANUAL', 'MANUAL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_payments WHERE payment_sk = -1
);


INSERT INTO bl_3nf.ce_customers_scd (
    customer_sk, customer_src_id, customer_name, customer_email,
    gender, customer_address, date_of_birth,
    source_entity, source_system, insert_dt, update_dt,
    start_dt, end_dt, is_active
)
SELECT
    -1, 'n.a.', 'Unknown', 'unknown@unknown.com',
    'Unknown', 'Unknown', DATE '1900-01-01',
    'MANUAL', 'MANUAL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    DATE '1900-01-01', DATE '9999-12-31', 'Y'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_customers_scd WHERE customer_sk = -1
);

INSERT INTO bl_3nf.ce_employees ( employee_sk, employee_src_id, employee_name, employee_email, gender, employee_role, date_of_birth,
source_entity, source_system, insert_dt, update_dt
)
SELECT
    -1, 'n.a.', 'Unknown', 'unknown@uzbekland.com',
    'Unknown', 'Seller', DATE '1900-01-01',
    'MANUAL', 'MANUAL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_employees WHERE employee_sk = -1
);


INSERT INTO bl_3nf.ce_suppliers (supplier_sk, supplier_src_id, supplier_name, supplier_email,
street_address, supplier_city, supplier_country, supplier_primary_industry, source_entity, source_system, insert_dt, update_dt
)
SELECT
    -1, 'n.a.', 'Unknown', 'unknown@gmail.com',
    'Unknown', 'Unknown', 'Unknown', 'Unknown',
    'MANUAL', 'MANUAL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_suppliers WHERE supplier_sk = -1
);

INSERT INTO bl_3nf.ce_products (
    product_sk, product_src_id, supplier_sk,
    product_name, category, brand, made_in,
    source_entity, source_system, insert_dt, update_dt
)
SELECT
    -1, 'n.a.', -1,
    'Unknown', 'Unknown', 'Unknown', 'Unknown',
    'MANUAL', 'MANUAL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_products WHERE product_sk = -1
);

INSERT INTO bl_3nf.ce_branches (
    branch_sk,
    branch_src_id,
    branch_name,
    branch_address,
    city_sk,
    opened_year,
    branch_size_sqm,
    manager_src_id,
    manager_name,
    manager_email,
    manager_gender,
    manager_birth_date,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    -1,
    'n.a.',
    'Unknown',
    'Unknown',
    -1,
    0,
    0,
    'n.a.',
    'Unknown',
    'unknown@uzbekland.com',
    'Unknown',
    DATE '1900-01-01',
    'MANUAL',
    'MANUAL',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_branches
    WHERE branch_sk = -1
);

COMMIT;


SELECT	*
FROM	sa_offline_sales.src_offline_sales;

SELECT	*
FROM	sa_online_sales.src_online_sales;
---------------------------------------------------------------


-- Data loading, 
-- LEFT JOIN with WHERE ... IS NULL inserts only new records that do not already exist in the target table.
-- DISTINCT removes duplicate rows from the source before loading data into the target table.

--  bl_3nf.ce_geography

-- online source
INSERT INTO bl_3nf.ce_geography(
    city_sk,
    city_src_id,
    city,
    country,
    region,
    continent,
    postal_code,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT  
		nextval('bl_3nf.seq_ce_geography_sk'),
 		s.cityid,
    	COALESCE(s.city,'n.a.'),
    	COALESCE(s.country,'n.a.'),
    	COALESCE(s.region,'n.a.'),
    	COALESCE(s.continent,'n.a.'),
    	COALESCE(s.postalcode,'n.a.'),
    	'src_online_sales',
    	'SA_ONLINE',
    	CURRENT_TIMESTAMP,
    	CURRENT_TIMESTAMP
		
FROM(SELECT DISTINCT
        cityid,
        city,
        country,
        region,
        continent,
        postalcode
    FROM sa_online_sales.src_online_sales) s
LEFT JOIN bl_3nf.ce_geography g
		ON g.city_src_id = s.cityid
WHERE g.city_src_id IS NULL;

-- offline source
INSERT INTO bl_3nf.ce_geography(
    city_sk,
    city_src_id,
    city,
    country,
    region,
    continent,
    postal_code,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT  
		nextval('bl_3nf.seq_ce_geography_sk'),
 		s.cityid,
    	COALESCE(s.city,'n.a.'),
    	COALESCE(s.country,'n.a.'),
    	COALESCE(s.region,'n.a.'),
    	COALESCE(s.continent,'n.a.'),
    	COALESCE(s.postalcode,'n.a.'),
    	'src_offline_sales',
    	'SA_OFFLINE',
    	CURRENT_TIMESTAMP,
    	CURRENT_TIMESTAMP
		
FROM(SELECT DISTINCT
        cityid,
        city,
        country,
        region,
        continent,
        postalcode
    FROM sa_offline_sales.src_offline_sales) s
LEFT JOIN bl_3nf.ce_geography g
		ON g.city_src_id = s.cityid
WHERE g.city_src_id IS NULL;

-- Update

UPDATE bl_3nf.ce_geography g
SET
    city = COALESCE(s.city,'n.a.'),
    country = COALESCE(s.country,'n.a.'),
    region = COALESCE(s.region,'n.a.'),
    continent = COALESCE(s.continent,'n.a.'),
    postal_code = COALESCE(s.postalcode,'n.a.'),
    update_dt = CURRENT_TIMESTAMP
FROM (

    SELECT DISTINCT
        cityid,
        city,
        country,
        region,
        continent,
        postalcode
    FROM sa_online_sales.src_online_sales

    UNION     -- UNION combines records from both source systems and removes duplicate rows.

    SELECT DISTINCT
        cityid,
        city,
        country,
        region,
        continent,
        postalcode
    FROM sa_offline_sales.src_offline_sales

) s

WHERE g.city_src_id = s.cityid
AND (
       g.city <> COALESCE(s.city,'n.a.')
    OR g.country <> COALESCE(s.country,'n.a.')
    OR g.region <> COALESCE(s.region,'n.a.')
    OR g.continent <> COALESCE(s.continent,'n.a.')
    OR g.postal_code <> COALESCE(s.postalcode,'n.a.')
);

COMMIT;

-- bl_3nf.ce_payments
SELECT *
FROM bl_3nf.ce_payments

-- online payments

INSERT INTO bl_3nf.ce_payments(
		payment_sk,
		payment_src_id,
		payment_type,
		currency,
		usd_rate,
		source_entity,
		source_system,
		insert_dt,
		update_dt)


SELECT
		nextval('bl_3nf.seq_ce_payments_sk'),
		s.paymentid,
		COALESCE(s.paymenttype, 'Unknown'),
		COALESCE(s.currency, 'Unknown'),
		COALESCE(NULLIF(s.usdrate, '#N/A')::DECIMAL(5,2), 1.00),   -- -- NULLIF replaces '#N/A' with NULL before type casting to avoid conversion errors.
   		'src_online_sales',
    	'SA_ONLINE',
    	CURRENT_TIMESTAMP,
    	CURRENT_TIMESTAMP
FROM(
SELECT DISTINCT
		paymentid, paymenttype, currency, usdrate
FROM sa_online_sales.src_online_sales
) AS s
LEFT JOIN bl_3nf.ce_payments p
		ON p.payment_src_id = s.paymentid
WHERE p.payment_src_id IS NULL;


-- offline payments
INSERT INTO bl_3nf.ce_payments(
		payment_sk,
		payment_src_id,
		payment_type,
		currency,
		usd_rate,
		source_entity,
		source_system,
		insert_dt,
		update_dt)


SELECT
		nextval('bl_3nf.seq_ce_payments_sk'),
		s.paymentid,
		COALESCE(s.paymenttype, 'Unknown'),
		COALESCE(s.currency, 'Unknown'),
		COALESCE(NULLIF(s.usdrate, '#N/A')::DECIMAL(5,2), 1.00),   -- -- NULLIF replaces '#N/A' with NULL before type casting to avoid conversion errors.
   		'src_offline_sales',
    	'SA_OFFLINE',
    	CURRENT_TIMESTAMP,
    	CURRENT_TIMESTAMP
FROM(
SELECT DISTINCT
		paymentid, paymenttype, currency, usdrate
FROM sa_offline_sales.src_offline_sales
) AS s
LEFT JOIN bl_3nf.ce_payments p
		ON p.payment_src_id = s.paymentid
WHERE p.payment_src_id IS NULL;


-- UPDATE
UPDATE bl_3nf.ce_payments p
SET
	payment_type = COALESCE(s.paymenttype, 'Unknown'),
	currency = COALESCE(s.currency,  'Unknown'),
	usd_rate = COALESCE(NULLIF(s.usdrate, '#N/A')::DECIMAL(5,2), 1.00),
	update_dt = CURRENT_TIMESTAMP


FROM(
SELECT DISTINCT 
				paymentid,
				paymenttype,
				currency,
				usdrate
FROM 	sa_online_sales.src_online_sales

UNION       -- UNION combines records from both source systems and removes duplicate rows.

SELECT DISTINCT 
				paymentid,
				paymenttype,
				currency,
				usdrate
FROM 	sa_offline_sales.src_offline_sales			
) AS s
WHERE p.payment_src_id = s.paymentid AND        -- <> is used to take only the rows only where some values are changed 
(	  s.paymenttype <> p.payment_type OR
	  s.currency <> p.currency OR
	  COALESCE(NULLIF(s.usdrate, '#N/A')::DECIMAL(5,2),1.00) <> p.usd_rate
	  );
COMMIT;




-- suppliers

--online source
SELECT * FROM bl_3nf.ce_suppliers

INSERT INTO bl_3nf.ce_suppliers(
		supplier_sk,
		supplier_src_id,
		supplier_name,
		supplier_email,
		street_address,
		supplier_city,
		supplier_country,
		supplier_primary_industry,
		source_entity,
		source_system,
		insert_dt,
		update_dt
)

SELECT
		nextval('bl_3nf.seq_ce_suppliers_sk'),
		COALESCE(s.supplierid, 'n.a.'),
		COALESCE(s.supplier, 'Unknown'),
		COALESCE(NULLIF(s.supplieremail, '#N/A'), 'unknown@gmail.com'),
		COALESCE(s.supplierstreetaddress, 'Unknown'),
		COALESCE(s.suppliercity, 'Unknown'),
		COALESCE(s.suppliercountry, 'Unknown'),
		COALESCE(s.supplierprimaryindustry, 'Unknown'),
		'src_online_sales',
    	'SA_ONLINE',
    	CURRENT_TIMESTAMP,
    	CURRENT_TIMESTAMP
		
		
FROM(
SELECT DISTINCT
	   supplierid,
	   supplier,
	   supplieremail,
	   supplierstreetaddress,
	   suppliercity,
	   suppliercountry,
	   supplierprimaryindustry
FROM	sa_online_sales.src_online_sales
) s
LEFT JOIN  bl_3nf.ce_suppliers sp
		ON s.supplierid = sp.supplier_src_id
WHERE  sp.supplier_src_id IS NULL;


--offilne sources
INSERT INTO bl_3nf.ce_suppliers(
		supplier_sk,
		supplier_src_id,
		supplier_name,
		supplier_email,
		street_address,
		supplier_city,
		supplier_country,
		supplier_primary_industry,
		source_entity,
		source_system,
		insert_dt,
		update_dt
)

SELECT
		nextval('bl_3nf.seq_ce_suppliers_sk'),
		COALESCE(s.supplierid, 'n.a.'),
		COALESCE(s.supplier, 'Unknown'),
		COALESCE(NULLIF(s.supplieremail, '#N/A'), 'unknown@gmail.com'),
		COALESCE(s.supplierstreetaddress, 'Unknown'),
		COALESCE(s.suppliercity, 'Unknown'),
		COALESCE(s.suppliercountry, 'Unknown'),
		COALESCE(s.supplierprimaryindustry, 'Unknown'),
	    'src_offline_sales',
    	'SA_OFFLINE',
    	CURRENT_TIMESTAMP,
    	CURRENT_TIMESTAMP
		
		
FROM(
SELECT DISTINCT
	   supplierid,
	   supplier,
	   supplieremail,
	   supplierstreetaddress,
	   suppliercity,
	   suppliercountry,
	   supplierprimaryindustry
FROM	sa_offline_sales.src_offline_sales
) s
LEFT JOIN  bl_3nf.ce_suppliers sp
		ON s.supplierid = sp.supplier_src_id
WHERE  sp.supplier_src_id IS NULL;

-- UPDATE
UPDATE bl_3nf.ce_suppliers sp
SET
	supplier_name = COALESCE(NULLIF(s.supplier, '#N/A'), 'Unknown'),
	supplier_email = COALESCE(NULLIF(s.supplieremail, '#N/A'), 'unknown@gmail.com'),
	street_address = COALESCE(NULLIF(s.supplierstreetaddress, '#N/A'), 'Unknown'),
	supplier_city = COALESCE(NULLIF(s.suppliercity, '#N/A'), 'Unknown'),
	supplier_country = COALESCE(NULLIF(s.suppliercountry, '#N/A'), 'Unknown'),
	supplier_primary_industry = COALESCE(NULLIF(s.supplierprimaryindustry, '#N/A'), 'Unknown'),
	update_dt =  CURRENT_TIMESTAMP
	
FROM(
SELECT DISTINCT
	   supplierid,
	   supplier,
	   supplieremail,
	   supplierstreetaddress,
	   suppliercity,
	   suppliercountry,
	   supplierprimaryindustry
FROM	sa_offline_sales.src_offline_sales

UNION
SELECT DISTINCT
	   supplierid,
	   supplier,
	   supplieremail,
	   supplierstreetaddress,
	   suppliercity,
	   suppliercountry,
	   supplierprimaryindustry
FROM	sa_online_sales.src_online_sales

) AS s
WHERE sp.supplier_src_id = s.supplierid AND
	  (s.supplier <> sp.supplier_name OR
	  s.supplieremail <> sp.supplier_email OR
	  s.supplierstreetaddress <> sp.street_address OR
	  s.suppliercity <> sp.supplier_city OR
	  s. suppliercountry <> sp.supplier_country OR
	  s.supplierprimaryindustry <> sp.supplier_primary_industry);
COMMIT;


-- employees

-- online source

INSERT INTO bl_3nf.ce_employees (
    employee_sk,
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
SELECT
    nextval('bl_3nf.seq_ce_employees_sk'),
    COALESCE(s.courierid, 'n.a.'),
    COALESCE(s.couriername, 'Unknown'),
    COALESCE(NULLIF(s.courieremail, '#N/A'), 'unknown@uzbekland.com'),
    COALESCE(s.couriergender, 'Unknown'),
    'Courier',
    COALESCE(s.courierbirthdate, DATE '1900-01-01'),
    'src_online_sales',
    'SA_ONLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
SELECT DISTINCT
    courierid,
    couriername,
    courieremail,
    NULLIF(couriergender, '#N/A') AS couriergender,
    NULLIF(courierbirthdate, '#N/A')::DATE AS courierbirthdate
FROM sa_online_sales.src_online_sales
) s
LEFT JOIN bl_3nf.ce_employees e
    ON e.employee_src_id = s.courierid
WHERE e.employee_src_id IS NULL;


-- offline source

INSERT INTO bl_3nf.ce_employees (
    employee_sk,
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
SELECT
    nextval('bl_3nf.seq_ce_employees_sk'),
    COALESCE(s.sellerid, 'n.a.'),
    COALESCE(s.sellername, 'Unknown'),
    COALESCE(s.selleremail, 'unknown@uzbekland.com'),
    COALESCE(s.sellergender, 'Unknown'),
    'Seller',
    COALESCE(s.sellerbirthdate, DATE '1900-01-01'),
    'src_offline_sales',
    'SA_OFFLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT DISTINCT
        sellerid,
        sellername,
        NULLIF(selleremail, '#N/A') AS selleremail,
        NULLIF(sellergender, '#N/A') AS sellergender,
        NULLIF(sellerbirthdate, '#N/A')::DATE AS sellerbirthdate
    FROM sa_offline_sales.src_offline_sales
) s
LEFT JOIN bl_3nf.ce_employees e
    ON e.employee_src_id = s.sellerid
WHERE e.employee_src_id IS NULL;

-- Update
UPDATE bl_3nf.ce_employees e
SET
    employee_name = COALESCE(s.employee_name, 'Unknown'),
    employee_email = COALESCE(s.employee_email, 'unknown@uzbekland.com'),
    gender = COALESCE(s.gender, 'Unknown'),
    employee_role = s.employee_role,
    date_of_birth = COALESCE(s.date_of_birth, DATE '1900-01-01'),
    update_dt = CURRENT_TIMESTAMP
FROM (

    SELECT DISTINCT
        courierid AS employee_src_id,
        couriername AS employee_name,
        NULLIF(courieremail, '#N/A') AS employee_email,
        NULLIF(couriergender, '#N/A') AS gender,
        'Courier' AS employee_role,
        NULLIF(courierbirthdate, '#N/A')::DATE AS date_of_birth
    FROM sa_online_sales.src_online_sales

    UNION

    SELECT DISTINCT
        sellerid AS employee_src_id,
        sellername AS employee_name,
        NULLIF(selleremail, '#N/A') AS employee_email,
        NULLIF(sellergender, '#N/A') AS gender,
        'Seller' AS employee_role,
        NULLIF(sellerbirthdate, '#N/A')::DATE AS date_of_birth
    FROM sa_offline_sales.src_offline_sales

) s
WHERE e.employee_src_id = s.employee_src_id
AND (
       e.employee_name <> COALESCE(s.employee_name, 'Unknown')
    OR e.employee_email <> COALESCE(s.employee_email, 'unknown@uzbekland.com')
    OR e.gender <> COALESCE(s.gender, 'Unknown')
    OR e.employee_role <> s.employee_role
    OR e.date_of_birth <> COALESCE(s.date_of_birth, DATE '1900-01-01')
);


-- Products 

-- online source

INSERT INTO bl_3nf.ce_products (
    product_sk,
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
SELECT
    nextval('bl_3nf.seq_ce_products_sk'),
    COALESCE(s.productid, 'n.a.'),
    COALESCE(sp.supplier_sk, -1),
    COALESCE(s.productname, 'Unknown'),
    COALESCE(s.productcategory, 'Unknown'),
    COALESCE(s.productbrand, 'Unknown'),
    COALESCE(s.productmadein, 'Unknown'),
    'src_online_sales',
    'SA_ONLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT DISTINCT
        productid,
        supplierid,
        NULLIF(productname, '#N/A') AS productname,
        NULLIF(productcategory, '#N/A') AS productcategory,
        NULLIF(productbrand, '#N/A') AS productbrand,
        NULLIF(productmadein, '#N/A') AS productmadein
    FROM sa_online_sales.src_online_sales
) s
LEFT JOIN bl_3nf.ce_products p
    ON p.product_src_id = s.productid
LEFT JOIN bl_3nf.ce_suppliers sp
    ON sp.supplier_src_id = s.supplierid
WHERE p.product_src_id IS NULL;

-- offline source

INSERT INTO bl_3nf.ce_products (
    product_sk,
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
SELECT
    nextval('bl_3nf.seq_ce_products_sk'),
    COALESCE(s.productid, 'n.a.'),
    COALESCE(sp.supplier_sk, -1),
    COALESCE(s.productname, 'Unknown'),
    COALESCE(s.category, 'Unknown'),
    COALESCE(s.brand, 'Unknown'),
    COALESCE(s.madein, 'Unknown'),
    'src_offline_sales',
    'SA_OFFLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT DISTINCT
        productid,
        supplierid,
        NULLIF(productname, '#N/A') AS productname,
        NULLIF(category, '#N/A') AS category,
        NULLIF(brand, '#N/A') AS brand,
        NULLIF(madein, '#N/A') AS madein
    FROM sa_offline_sales.src_offline_sales
) s
LEFT JOIN bl_3nf.ce_products p
    ON p.product_src_id = s.productid
LEFT JOIN bl_3nf.ce_suppliers sp
    ON sp.supplier_src_id = s.supplierid
WHERE p.product_src_id IS NULL;


-- Update

UPDATE bl_3nf.ce_products p
SET
    supplier_sk = COALESCE(s.supplier_sk, -1),
    product_name = COALESCE(s.product_name, 'Unknown'),
    category = COALESCE(s.category, 'Unknown'),
    brand = COALESCE(s.brand, 'Unknown'),
    made_in = COALESCE(s.made_in, 'Unknown'),
    update_dt = CURRENT_TIMESTAMP
FROM (

    SELECT DISTINCT
        o.productid AS product_src_id,
        sp.supplier_sk,
        NULLIF(o.productname, '#N/A') AS product_name,
        NULLIF(o.productcategory, '#N/A') AS category,
        NULLIF(o.productbrand, '#N/A') AS brand,
        NULLIF(o.productmadein, '#N/A') AS made_in
    FROM sa_online_sales.src_online_sales o
    LEFT JOIN bl_3nf.ce_suppliers sp
        ON sp.supplier_src_id = o.supplierid

    UNION

    SELECT DISTINCT
        f.productid,
        sp.supplier_sk,
        NULLIF(f.productname, '#N/A'),
        NULLIF(f.category, '#N/A'),
        NULLIF(f.brand, '#N/A'),
        NULLIF(f.madein, '#N/A')
    FROM sa_offline_sales.src_offline_sales f
    LEFT JOIN bl_3nf.ce_suppliers sp
        ON sp.supplier_src_id = f.supplierid

) s
WHERE p.product_src_id = s.product_src_id
AND (
       p.supplier_sk <> COALESCE(s.supplier_sk, -1)
    OR p.product_name <> COALESCE(s.product_name, 'Unknown')
    OR p.category <> COALESCE(s.category, 'Unknown')
    OR p.brand <> COALESCE(s.brand, 'Unknown')
    OR p.made_in <> COALESCE(s.made_in, 'Unknown')
);



--  branches

-- online source

INSERT INTO bl_3nf.ce_branches (
    branch_sk,
    branch_src_id,
    branch_name,
    branch_address,
    city_sk,
    opened_year,
    branch_size_sqm,
    manager_src_id,
    manager_name,
    manager_email,
    manager_gender,
    manager_birth_date,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_ce_branches_sk'),
    COALESCE(s.branchid,'n.a.'),
    COALESCE(s.branchname,'Unknown'),
    COALESCE(s.branchaddress,'Unknown'),
    COALESCE(g.city_sk,-1),
    COALESCE(NULLIF(s.branchopenedyear,'#N/A')::INT,0),
    COALESCE(NULLIF(s.branchsizesqm,'#N/A')::NUMERIC(12,2),0),
    COALESCE(s.branchmanagerid,'n.a.'),
    COALESCE(s.branchmanagername,'Unknown'),
    COALESCE(NULLIF(s.branchmanageremail,'#N/A'),'unknown@uzbekland.com'),
    COALESCE(NULLIF(s.branchmanagergender,'#N/A'),'Unknown'),
    COALESCE(NULLIF(s.branchmanagerbirthdate,'#N/A')::DATE,DATE '1900-01-01'),
    'src_online_sales',
    'SA_ONLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT DISTINCT
        branchid,
        NULLIF(branchname,'#N/A') branchname,
        NULLIF(branchaddress,'#N/A') branchaddress,
        branchopenedyear,
        branchsizesqm,
        branchmanagerid,
        NULLIF(branchmanagername,'#N/A') branchmanagername,
        branchmanageremail,
        branchmanagergender,
        branchmanagerbirthdate,
        cityid
    FROM sa_online_sales.src_online_sales
) s
LEFT JOIN bl_3nf.ce_branches b
       ON b.branch_src_id = s.branchid
LEFT JOIN bl_3nf.ce_geography g
       ON g.city_src_id = s.cityid
WHERE b.branch_src_id IS NULL;


-- offline source

INSERT INTO bl_3nf.ce_branches (
    branch_sk,
    branch_src_id,
    branch_name,
    branch_address,
    city_sk,
    opened_year,
    branch_size_sqm,
    manager_src_id,
    manager_name,
    manager_email,
    manager_gender,
    manager_birth_date,
    source_entity,
    source_system,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_ce_branches_sk'),
    COALESCE(s.branchid,'n.a.'),
    COALESCE(s.branchname,'Unknown'),
    COALESCE(s.branchaddress,'Unknown'),
    COALESCE(g.city_sk,-1),
    COALESCE(NULLIF(s.branchopenedyear,'#N/A')::INT,0),
    COALESCE(NULLIF(s.branchsizesqm,'#N/A')::NUMERIC(12,2),0),
    COALESCE(s.branchmanagerid,'n.a.'),
    COALESCE(s.branchmanagername,'Unknown'),
    COALESCE(NULLIF(s.branchmanageremail,'#N/A'),'unknown@uzbekland.com'),
    COALESCE(NULLIF(s.branchmanagergender,'#N/A'),'Unknown'),
    COALESCE(NULLIF(s.branchmanagerbirthdate,'#N/A')::DATE,DATE '1900-01-01'),
    'src_offline_sales',
    'SA_OFFLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
SELECT DISTINCT
        branchid,
        NULLIF(branchname,'#N/A') branchname,
        NULLIF(branchaddress,'#N/A') branchaddress,
        branchopenedyear,
        branchsizesqm,
        branchmanagerid,
        NULLIF(branchmanagername,'#N/A') branchmanagername,
        branchmanageremail,
        branchmanagergender,
        branchmanagerbirthdate,
        cityid
FROM sa_offline_sales.src_offline_sales
) s
LEFT JOIN bl_3nf.ce_branches b
       ON b.branch_src_id = s.branchid
LEFT JOIN bl_3nf.ce_geography g
       ON g.city_src_id = s.cityid
WHERE b.branch_src_id IS NULL;

--UPDATE
UPDATE bl_3nf.ce_branches b
SET
    branch_name = COALESCE(s.branchname,'Unknown'),
    branch_address = COALESCE(s.branchaddress,'Unknown'),
    city_sk = COALESCE(s.city_sk,-1),
    opened_year = COALESCE(NULLIF(s.branchopenedyear,'#N/A')::INT,0),
    branch_size_sqm = COALESCE(NULLIF(s.branchsizesqm,'#N/A')::NUMERIC(12,2),0),
    manager_src_id = COALESCE(s.branchmanagerid,'n.a.'),
    manager_name = COALESCE(s.branchmanagername,'Unknown'),
    manager_email = COALESCE(NULLIF(s.branchmanageremail,'#N/A'),'unknown@uzbekland.com'),
    manager_gender = COALESCE(NULLIF(s.branchmanagergender,'#N/A'),'Unknown'),
    manager_birth_date = COALESCE(NULLIF(s.branchmanagerbirthdate,'#N/A')::DATE,DATE '1900-01-01'),
    update_dt = CURRENT_TIMESTAMP
FROM (
SELECT DISTINCT
        o.branchid,
        NULLIF(o.branchname,'#N/A') branchname,
        NULLIF(o.branchaddress,'#N/A') branchaddress,
        o.branchopenedyear,
        o.branchsizesqm,
        o.branchmanagerid,
        NULLIF(o.branchmanagername,'#N/A') branchmanagername,
        o.branchmanageremail,
        o.branchmanagergender,
        o.branchmanagerbirthdate,
        g.city_sk
FROM sa_online_sales.src_online_sales o
LEFT JOIN bl_3nf.ce_geography g
      ON g.city_src_id = o.cityid

    UNION

SELECT DISTINCT
        f.branchid,
        NULLIF(f.branchname,'#N/A'),
        NULLIF(f.branchaddress,'#N/A'),
        f.branchopenedyear,
        f.branchsizesqm,
        f.branchmanagerid,
        NULLIF(f.branchmanagername,'#N/A'),
        f.branchmanageremail,
        f.branchmanagergender,
        f.branchmanagerbirthdate,
        g.city_sk
FROM sa_offline_sales.src_offline_sales f
    LEFT JOIN bl_3nf.ce_geography g
           ON g.city_src_id = f.cityid

) s
WHERE b.branch_src_id = s.branchid
AND (
       b.branch_name <> COALESCE(s.branchname,'Unknown')
    OR b.branch_address <> COALESCE(s.branchaddress,'Unknown')
    OR b.city_sk <> COALESCE(s.city_sk,-1)
    OR b.opened_year <> COALESCE(NULLIF(s.branchopenedyear,'#N/A')::INT,0)
    OR b.branch_size_sqm <> COALESCE(NULLIF(s.branchsizesqm,'#N/A')::NUMERIC(12,2),0)
    OR b.manager_src_id <> COALESCE(s.branchmanagerid,'n.a.')
    OR b.manager_name <> COALESCE(s.branchmanagername,'Unknown')
    OR b.manager_email <> COALESCE(NULLIF(s.branchmanageremail,'#N/A'),'unknown@uzbekland.com')
    OR b.manager_gender <> COALESCE(NULLIF(s.branchmanagergender,'#N/A'),'Unknown')
    OR b.manager_birth_date <> COALESCE(NULLIF(s.branchmanagerbirthdate,'#N/A')::DATE,DATE '1900-01-01')
);

COMMIT;


-- customers

-- online source

INSERT INTO bl_3nf.ce_customers_scd (
    customer_sk,
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
    nextval('bl_3nf.seq_ce_customers_sk'),
    COALESCE(s.customerid,'n.a.'),
    COALESCE(s.customername,'Unknown'),
    COALESCE(NULLIF(s.customeremail,'#N/A'),'unknown@gmail.com'),
    COALESCE(NULLIF(s.gender,'#N/A'),'Unknown'),
    'Unknown',
    COALESCE(NULLIF(s.dateofbirth,'#N/A')::DATE, DATE '1900-01-01'),
    'src_offline_sales',
    'SA_OFFLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CURRENT_DATE,
    DATE '9999-12-31',
    'Y'

FROM (

    SELECT DISTINCT
        customerid,
        customername,
        customeremail,
        NULLIF(gender,'#N/A') AS gender,
        NULLIF(dateofbirth,'#N/A') AS dateofbirth
    FROM sa_offline_sales.src_offline_sales

) s

LEFT JOIN bl_3nf.ce_customers_scd c
       ON c.customer_src_id = s.customerid
      AND c.is_active = 'Y'
WHERE c.customer_src_id IS NULL;

-- online source

INSERT INTO bl_3nf.ce_customers_scd (
    customer_sk,
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
    nextval('bl_3nf.seq_ce_customers_sk'),
    COALESCE(s.customerid,'n.a.'),
    COALESCE(s.customername,'Unknown'),
    COALESCE(NULLIF(s.customeremail,'#N/A'),'unknown@gmail.com'),
    COALESCE(NULLIF(s.customergender,'#N/A'),'Unknown'),
    COALESCE(NULLIF(s.customeraddress,'#N/A'),'Unknown'),
    COALESCE(NULLIF(s.customerbirthdate,'#N/A')::DATE, DATE '1900-01-01'),
    'src_online_sales',
    'SA_ONLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CURRENT_DATE,
    DATE '9999-12-31',
    'Y'

FROM (

    SELECT DISTINCT
        customerid,
        customername,
        customeremail,
        NULLIF(customergender,'#N/A') AS customergender,
        NULLIF(customeraddress,'#N/A') AS customeraddress,
        NULLIF(customerbirthdate,'#N/A') AS customerbirthdate
    FROM sa_online_sales.src_online_sales

) s

LEFT JOIN bl_3nf.ce_customers_scd c
       ON c.customer_src_id = s.customerid
      AND c.is_active = 'Y'


WHERE c.customer_src_id IS NULL;


-- Close old active customer records
UPDATE bl_3nf.ce_customers_scd c
SET
    is_active = 'N',
    end_dt = CURRENT_DATE - 1,
    update_dt = CURRENT_TIMESTAMP

FROM (

    SELECT DISTINCT
        customerid,
        customername,
        customeremail,
        NULLIF(customergender,'#N/A') AS gender,
        NULLIF(customeraddress,'#N/A') AS customer_address,
        NULLIF(customerbirthdate,'#N/A')::DATE AS date_of_birth
    FROM sa_online_sales.src_online_sales

    UNION

    SELECT DISTINCT
        customerid,
        customername,
        customeremail,
        NULLIF(gender,'#N/A') AS gender,
        'Unknown' AS customer_address,
        NULLIF(dateofbirth,'#N/A')::DATE AS date_of_birth
    FROM sa_offline_sales.src_offline_sales

) s

WHERE c.customer_src_id = s.customerid
AND c.is_active = 'Y' AND (
       c.customer_name <> COALESCE(s.customername,'Unknown')
    OR c.customer_email <> COALESCE(s.customeremail,'unknown@gmail.com')
    OR c.gender <> COALESCE(s.gender,'Unknown')
    OR c.customer_address <> COALESCE(s.customer_address,'Unknown')
    OR c.date_of_birth <> COALESCE(s.date_of_birth, DATE '1900-01-01')
);

-- Insert new versions of changed customers
INSERT INTO bl_3nf.ce_customers_scd (
    customer_sk,
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
    nextval('bl_3nf.seq_ce_customers_sk'),
    s.customerid,
    COALESCE(s.customername,'Unknown'),
    COALESCE(s.customeremail,'unknown@gmail.com'),
    COALESCE(s.gender,'Unknown'),
    COALESCE(s.customer_address,'Unknown'),
    COALESCE(s.date_of_birth, DATE '1900-01-01'),
    s.source_entity,
    s.source_system,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CURRENT_DATE,
    DATE '9999-12-31',
    'Y'

FROM (

    SELECT DISTINCT
        customerid,
        customername,
        customeremail,
        NULLIF(customergender,'#N/A') AS gender,
        NULLIF(customeraddress,'#N/A') AS customer_address,
        NULLIF(customerbirthdate,'#N/A')::DATE AS date_of_birth,
        'src_online_sales' AS source_entity,
        'SA_ONLINE' AS source_system
    FROM sa_online_sales.src_online_sales

    UNION

    SELECT DISTINCT
        customerid,
        customername,
        customeremail,
        NULLIF(gender,'#N/A') AS gender,
        'Unknown' AS customer_address,
        NULLIF(dateofbirth,'#N/A')::DATE AS date_of_birth,
        'src_offline_sales' AS source_entity,
        'SA_OFFLINE' AS source_system
    FROM sa_offline_sales.src_offline_sales

) s

LEFT JOIN bl_3nf.ce_customers_scd c
       ON c.customer_src_id = s.customerid
      AND c.is_active = 'Y'
WHERE c.customer_src_id IS NULL;

COMMIT;

-- orders

-- online source
INSERT INTO bl_3nf.ce_orders (
    order_sk,
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
    nextval('bl_3nf.seq_ce_orders_sk'),
    COALESCE(s.orderid,'n.a.'),
    COALESCE(c.customer_sk,-1),
    COALESCE(e.employee_sk,-1),
    COALESCE(p.payment_sk,-1),
    COALESCE(b.branch_sk,-1),
    COALESCE(NULLIF(s.orderdate,'#N/A')::DATE, DATE '1900-01-01'),
    COALESCE(NULLIF(s.orderstatus,'#N/A'),'Unknown'),
    COALESCE(NULLIF(s.ordertype,'#N/A'),'Unknown'),
    'src_online_sales',
    'SA_ONLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP

FROM (SELECT DISTINCT
        orderid,
        orderdate,
        orderstatus,
        ordertype,
        customerid,
        courierid,
        paymentid,
        branchid
    FROM sa_online_sales.src_online_sales

) s

LEFT JOIN bl_3nf.ce_customers_scd c
       ON c.customer_src_id = s.customerid
      AND c.is_active = 'Y'

LEFT JOIN bl_3nf.ce_employees e
       ON e.employee_src_id = s.courierid

LEFT JOIN bl_3nf.ce_payments p
       ON p.payment_src_id = s.paymentid

LEFT JOIN bl_3nf.ce_branches b
       ON b.branch_src_id = s.branchid

LEFT JOIN bl_3nf.ce_orders o
       ON o.order_src_id = s.orderid
WHERE o.order_src_id IS NULL;

-- offline source

INSERT INTO bl_3nf.ce_orders (
    order_sk,
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
    nextval('bl_3nf.seq_ce_orders_sk'),
    COALESCE(s.orderid,'n.a.'),
    COALESCE(c.customer_sk,-1),
    COALESCE(e.employee_sk,-1),
    COALESCE(p.payment_sk,-1),
    COALESCE(b.branch_sk,-1),
    COALESCE(NULLIF(s.orderdate,'#N/A')::DATE, DATE '1900-01-01'),
    COALESCE(NULLIF(s.orderstatus,'#N/A'),'Unknown'),
    COALESCE(NULLIF(s.ordertype,'#N/A'),'Unknown'),
    'src_offline_sales',
    'SA_OFFLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP

FROM (SELECT DISTINCT
        orderid,
        orderdate,
        orderstatus,
        ordertype,
        customerid,
        sellerid,
        paymentid,
        branchid
    FROM sa_offline_sales.src_offline_sales

) s

LEFT JOIN bl_3nf.ce_customers_scd c
       ON c.customer_src_id = s.customerid
      AND c.is_active = 'Y'

LEFT JOIN bl_3nf.ce_employees e
       ON e.employee_src_id = s.sellerid

LEFT JOIN bl_3nf.ce_payments p
       ON p.payment_src_id = s.paymentid

LEFT JOIN bl_3nf.ce_branches b
       ON b.branch_src_id = s.branchid

LEFT JOIN bl_3nf.ce_orders o
       ON o.order_src_id = s.orderid
WHERE o.order_src_id IS NULL;



COMMIT;

-- Increased decimal precision to match the source data
-- and prevent numeric overflow during data loading.

ALTER TABLE bl_3nf.ce_order_item
ALTER COLUMN unit_price_usd TYPE DECIMAL(18,4);

ALTER TABLE bl_3nf.ce_order_item
ALTER COLUMN total_price_usd TYPE DECIMAL(18,4);

ALTER TABLE bl_3nf.ce_order_item
ALTER COLUMN unit_price_local TYPE DECIMAL(18,4);

ALTER TABLE bl_3nf.ce_order_item
ALTER COLUMN total_price_local TYPE DECIMAL(18,4);

ALTER TABLE bl_3nf.ce_payments
ALTER COLUMN usd_rate TYPE DECIMAL(18,6);

--online source

INSERT INTO bl_3nf.ce_order_item (
    order_item_sk,
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
    nextval('bl_3nf.seq_ce_order_items_sk'),
    s.orderid,
    o.order_sk,
    p.product_sk,
    NULLIF(s.quantity,'#N/A')::INT,
    NULLIF(s.unitpriceinusd,'#N/A')::DECIMAL(18,4),
    NULLIF(s.totalamountinusd,'#N/A')::DECIMAL(18,4),
    NULLIF(s.unitpriceinlocalcurrency,'#N/A')::DECIMAL(18,4),
    NULLIF(s.totalpriceinlocalcurrency,'#N/A')::DECIMAL(18,4),
    'src_online_sales',
    'SA_ONLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP

FROM (SELECT DISTINCT
        orderid,
        productid,
        quantity,
        unitpriceinusd,
        totalamountinusd,
        unitpriceinlocalcurrency,
        totalpriceinlocalcurrency
    FROM sa_online_sales.src_online_sales

) s

LEFT JOIN bl_3nf.ce_orders o
       ON o.order_src_id = s.orderid
LEFT JOIN bl_3nf.ce_products p
       ON p.product_src_id = s.productid
LEFT JOIN bl_3nf.ce_order_item oi
       ON oi.order_src_id = s.orderid
      AND oi.product_sk = p.product_sk
WHERE oi.order_item_sk IS NULL

  
--offline source
INSERT INTO bl_3nf.ce_order_item (
    order_item_sk,
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
    nextval('bl_3nf.seq_ce_order_items_sk'),
    s.orderid,
    o.order_sk,
    p.product_sk,
    NULLIF(s.quantity,'#N/A')::INT,
    NULLIF(s.unitpriceinusd,'#N/A')::DECIMAL(18,4),
    NULLIF(s.totalamountusd,'#N/A')::DECIMAL(18,4),
    NULLIF(s.unitpriceinlocalcurrency,'#N/A')::DECIMAL(18,4),
    NULLIF(s.totalpriceinlocalcurrency,'#N/A')::DECIMAL(18,4),
    'src_offline_sales',
    'SA_OFFLINE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP

FROM (

    SELECT DISTINCT
        orderid,
        productid,
        quantity,
        unitpriceinusd,
        totalamountusd,
        unitpriceinlocalcurrency,
        totalpriceinlocalcurrency
    FROM sa_offline_sales.src_offline_sales

) s

LEFT JOIN bl_3nf.ce_orders o
       ON o.order_src_id = s.orderid

LEFT JOIN bl_3nf.ce_products p
       ON p.product_src_id = s.productid
LEFT JOIN bl_3nf.ce_order_item oi
       ON oi.order_src_id = s.orderid
      AND oi.product_sk = p.product_sk
WHERE oi.order_item_sk IS NULL
  ;
