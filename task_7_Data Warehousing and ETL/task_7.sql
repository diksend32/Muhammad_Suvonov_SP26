CREATE SCHEMA IF NOT EXISTS bl_dm;

-- Sequences
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_customers_surr_id;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_products_surr_id;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_suppliers_surr_id;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_employees_surr_id;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_branches_surr_id;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_payments_surr_id;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_time_day_surr_id;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_fct_orders_dd_surr_id;

-- Dimension tables

CREATE TABLE IF NOT EXISTS bl_dm.DIM_CUSTOMERS_SCD (
    CUSTOMER_SURR_ID  BIGINT PRIMARY KEY,
    customer_src_id   VARCHAR(50)  NOT NULL,
    customer_name     VARCHAR(50)  NOT NULL,
    customer_email    VARCHAR(100) NOT NULL,
    gender            VARCHAR(20)  NOT NULL CHECK (gender IN ('Male','Female','Unknown')),
    customer_address  VARCHAR(100) NOT NULL,
    date_of_birth     DATE         NOT NULL,
    start_dt          DATE         NOT NULL,
    end_dt            DATE         NOT NULL,
    is_active         CHAR(1)      NOT NULL CHECK (is_active IN ('Y','N')),
    source_entity     VARCHAR(50)  NOT NULL,
    source_system     VARCHAR(50)  NOT NULL,
    insert_dt         TIMESTAMP    NOT NULL,
    update_dt         TIMESTAMP    NOT NULL,
    UNIQUE (customer_src_id, start_dt)
);

CREATE TABLE IF NOT EXISTS bl_dm.DIM_EMPLOYEES (
    EMPLOYEE_SURR_ID  BIGINT PRIMARY KEY,
    employee_src_id   VARCHAR(50) UNIQUE NOT NULL,
    employee_name     VARCHAR(50)  NOT NULL,
    employee_email    VARCHAR(100) NOT NULL,                      
    gender            VARCHAR(20)  NOT NULL CHECK (gender IN ('Male','Female','Unknown')),
    employee_role     VARCHAR(50)  NOT NULL CHECK (employee_role IN ('Seller','Courier','n.a')),
    date_of_birth     DATE         NOT NULL,
    source_entity     VARCHAR(50)  NOT NULL,
    source_system     VARCHAR(50)  NOT NULL,
    insert_dt         TIMESTAMP    NOT NULL,
    update_dt         TIMESTAMP    NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.DIM_SUPPLIERS (
    SUPPLIER_SURR_ID  BIGINT PRIMARY KEY,
    supplier_src_id   VARCHAR(50) UNIQUE NOT NULL,
    supplier_name     VARCHAR(50) NOT NULL,
    supplier_email    VARCHAR(100),
    street_address    VARCHAR(50) NOT NULL,
    supplier_city     VARCHAR(50) NOT NULL,
    supplier_country  VARCHAR(50) NOT NULL,
    source_entity     VARCHAR(50) NOT NULL,
    source_system     VARCHAR(50) NOT NULL,
    insert_dt         TIMESTAMP   NOT NULL,
    update_dt         TIMESTAMP   NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.DIM_PRODUCTS (
    PRODUCT_SURR_ID   BIGINT PRIMARY KEY,
    product_src_id    VARCHAR(50) UNIQUE NOT NULL,
    product_name      VARCHAR(50) NOT NULL,
    category          VARCHAR(50) NOT NULL,
    brand             VARCHAR(50) NOT NULL,
    made_in           VARCHAR(50) NOT NULL,
    supplier_name     VARCHAR(50) NOT NULL,
    supplier_country  VARCHAR(50) NOT NULL,
    source_entity     VARCHAR(50) NOT NULL,
    source_system     VARCHAR(50) NOT NULL,
    insert_dt         TIMESTAMP   NOT NULL,
    update_dt         TIMESTAMP   NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.DIM_BRANCHES (
    BRANCH_SURR_ID    BIGINT PRIMARY KEY,
    branch_src_id     VARCHAR(50) UNIQUE NOT NULL,
    branch_name       VARCHAR(50) NOT NULL,
    branch_address    VARCHAR(50) NOT NULL,
    city              VARCHAR(50) NOT NULL,
    country           VARCHAR(50) NOT NULL,
    region            VARCHAR(50) NOT NULL,
    continent         VARCHAR(50) NOT NULL,
    postal_code       VARCHAR(50) NOT NULL,
    source_entity     VARCHAR(50) NOT NULL,
    source_system     VARCHAR(50) NOT NULL,
    insert_dt         TIMESTAMP   NOT NULL,
    update_dt         TIMESTAMP   NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.DIM_PAYMENTS (
    PAYMENT_SURR_ID   BIGINT PRIMARY KEY,
    payment_src_id    VARCHAR(50) UNIQUE NOT NULL,
    payment_type      VARCHAR(50) NOT NULL,
    currency          VARCHAR(50) NOT NULL,
    usd_rate          DECIMAL(10,2) NOT NULL,                    
    source_entity     VARCHAR(50) NOT NULL,
    source_system     VARCHAR(50) NOT NULL,
    insert_dt         TIMESTAMP   NOT NULL,
    update_dt         TIMESTAMP   NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.DIM_TIME_DAY (
    DATE_SURR_ID      BIGINT PRIMARY KEY,
    date_value        DATE UNIQUE NOT NULL,
    day_num           INT NOT NULL,
    month_num         INT NOT NULL,
    quarter_num       INT NOT NULL,
    year_num          INT NOT NULL,
    month_name        VARCHAR(20) NOT NULL,
    day_name          VARCHAR(20) NOT NULL,
    is_weekend        CHAR(1) NOT NULL CHECK (is_weekend IN ('Y','N'))
);

COMMIT;

-- Default rows


INSERT INTO bl_dm.DIM_CUSTOMERS_SCD
(CUSTOMER_SURR_ID, customer_src_id, customer_name, customer_email, gender, customer_address,
 date_of_birth, start_dt, end_dt, is_active, source_entity, source_system, insert_dt, update_dt)
SELECT -1,
       'n.a','n.a','n.a@gmail.com','Unknown','n.a', DATE '1900-01-01',
       DATE '1900-01-01', DATE '9999-12-31', 'Y', 'n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.DIM_CUSTOMERS_SCD WHERE customer_src_id = 'n.a');

INSERT INTO bl_dm.DIM_EMPLOYEES
(EMPLOYEE_SURR_ID, employee_src_id, employee_name, employee_email, gender, employee_role,
 date_of_birth, source_entity, source_system, insert_dt, update_dt)
SELECT -1,
       'n.a','n.a','n.a@uzbekland.com','Unknown','n.a', DATE '1900-01-01',
       'n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.DIM_EMPLOYEES WHERE employee_src_id = 'n.a');

INSERT INTO bl_dm.DIM_SUPPLIERS
(SUPPLIER_SURR_ID, supplier_src_id, supplier_name, supplier_email, street_address, supplier_city,
 supplier_country, source_entity, source_system, insert_dt, update_dt)
SELECT -1,
       'n.a','n.a','n.a@gmail.com','n.a','n.a','n.a','n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.DIM_SUPPLIERS WHERE supplier_src_id = 'n.a');

INSERT INTO bl_dm.DIM_PRODUCTS
(PRODUCT_SURR_ID, product_src_id, product_name, category, brand, made_in, supplier_name,
 supplier_country, source_entity, source_system, insert_dt, update_dt)
SELECT -1,
       'n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.DIM_PRODUCTS WHERE product_src_id = 'n.a');

INSERT INTO bl_dm.DIM_BRANCHES
(BRANCH_SURR_ID, branch_src_id, branch_name, branch_address, city, country, region, continent,
 postal_code, source_entity, source_system, insert_dt, update_dt)
SELECT -1,
       'n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.DIM_BRANCHES WHERE branch_src_id = 'n.a');

INSERT INTO bl_dm.DIM_PAYMENTS
(PAYMENT_SURR_ID, payment_src_id, payment_type, currency, usd_rate, source_entity, source_system, insert_dt, update_dt)
SELECT -1,
       'n.a','n.a','n.a', -1.0, 'n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.DIM_PAYMENTS WHERE payment_src_id = 'n.a');

INSERT INTO bl_dm.DIM_TIME_DAY
(DATE_SURR_ID, date_value, day_num, month_num, quarter_num, year_num, month_name, day_name, is_weekend)
SELECT -1,
       DATE '1900-01-01', 1, 1, 1, 1900, 'n.a', 'n.a', 'N'
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.DIM_TIME_DAY WHERE date_value = DATE '1900-01-01');

COMMIT;

-- Fact table

CREATE TABLE IF NOT EXISTS bl_dm.FCT_ORDERS_DD (
    ORDER_SURR_ID      BIGINT PRIMARY KEY,
    order_src_id       VARCHAR(50) NOT NULL,
    CUSTOMER_SURR_ID   BIGINT REFERENCES bl_dm.DIM_CUSTOMERS_SCD(CUSTOMER_SURR_ID),
    EMPLOYEE_SURR_ID   BIGINT REFERENCES bl_dm.DIM_EMPLOYEES(EMPLOYEE_SURR_ID),
    PAYMENT_SURR_ID    BIGINT REFERENCES bl_dm.DIM_PAYMENTS(PAYMENT_SURR_ID),
    BRANCH_SURR_ID     BIGINT REFERENCES bl_dm.DIM_BRANCHES(BRANCH_SURR_ID),
    PRODUCT_SURR_ID    BIGINT REFERENCES bl_dm.DIM_PRODUCTS(PRODUCT_SURR_ID),
    DATE_SURR_ID       BIGINT REFERENCES bl_dm.DIM_TIME_DAY(DATE_SURR_ID),
    order_status       VARCHAR(50) NOT NULL,
    order_type         VARCHAR(50) NOT NULL,
    quantity           INT NOT NULL CHECK (quantity > 0),
    unit_price_usd     DECIMAL(10,2) CHECK (unit_price_usd > 0),
    total_price_usd    DECIMAL(10,2) CHECK (total_price_usd > 0),
    unit_price_local   DECIMAL(10,2) CHECK (unit_price_local > 0),
    total_price_local  DECIMAL(10,2) CHECK (total_price_local > 0),
    source_entity      VARCHAR(50) NOT NULL,
    source_system      VARCHAR(50) NOT NULL,
    insert_dt          TIMESTAMP   NOT NULL,
    update_dt          TIMESTAMP   NOT NULL,
    UNIQUE (order_src_id, PRODUCT_SURR_ID)
);

COMMIT;

-- Load dimensions from BL_3NF


INSERT INTO bl_dm.DIM_CUSTOMERS_SCD
(CUSTOMER_SURR_ID, customer_src_id, customer_name, customer_email, gender, customer_address,
 date_of_birth, start_dt, end_dt, is_active, source_entity, source_system, insert_dt, update_dt)
SELECT
    nextval('bl_dm.seq_dim_customers_surr_id'),
    c.customer_src_id,
    c.customer_name,
    c.customer_email,
    c.gender,
    c.customer_address,
    c.date_of_birth,
    c.start_dt,
    c.end_dt,
    c.is_active,
    c.source_entity,
    c.source_system,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT DISTINCT ON (COALESCE(customer_src_id, 'n.a'), COALESCE(start_dt, DATE '1900-01-01'))
        COALESCE(customer_src_id, 'n.a')           AS customer_src_id,
        COALESCE(customer_name, 'n.a')             AS customer_name,
        COALESCE(customer_email, 'n.a@gmail.com')  AS customer_email,
        COALESCE(gender, 'Unknown')                AS gender,
        COALESCE(customer_address, 'n.a')          AS customer_address,
        COALESCE(date_of_birth, DATE '1900-01-01') AS date_of_birth,
        COALESCE(start_dt, DATE '1900-01-01')      AS start_dt,
        COALESCE(end_dt, DATE '9999-12-31')        AS end_dt,
        COALESCE(is_active, 'Y')                   AS is_active,
        COALESCE(source_entity, 'n.a')             AS source_entity,
        COALESCE(source_system, 'n.a')             AS source_system,
        customer_sk
    FROM bl_3nf.ce_customers_scd
    ORDER BY COALESCE(customer_src_id, 'n.a'), COALESCE(start_dt, DATE '1900-01-01'), customer_sk DESC
) c
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.DIM_CUSTOMERS_SCD d
    WHERE d.customer_src_id = c.customer_src_id
      AND d.start_dt = c.start_dt
);

COMMIT;

INSERT INTO bl_dm.DIM_EMPLOYEES
(EMPLOYEE_SURR_ID, employee_src_id, employee_name, employee_email, gender, employee_role,
 date_of_birth, source_entity, source_system, insert_dt, update_dt)
SELECT
    nextval('bl_dm.seq_dim_employees_surr_id'),
    COALESCE(e.employee_src_id, 'n.a'),
    COALESCE(e.employee_name, 'n.a'),
    COALESCE(e.employee_email, 'n.a@uzbekland.com'),
    COALESCE(e.gender, 'Unknown'),
    COALESCE(e.employee_role, 'n.a'),
    COALESCE(e.date_of_birth, DATE '1900-01-01'),
    COALESCE(e.source_entity, 'n.a'),
    COALESCE(e.source_system, 'n.a'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.ce_employees e
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.DIM_EMPLOYEES d
    WHERE d.employee_src_id = e.employee_src_id
);

COMMIT;

INSERT INTO bl_dm.DIM_SUPPLIERS
(SUPPLIER_SURR_ID, supplier_src_id, supplier_name, supplier_email, street_address, supplier_city,
 supplier_country, source_entity, source_system, insert_dt, update_dt)
SELECT
    nextval('bl_dm.seq_dim_suppliers_surr_id'),
    s.supplier_src_id,
    s.supplier_name,
    s.supplier_email,
    s.street_address,
    s.supplier_city,
    s.supplier_country,
    s.source_entity,
    s.source_system,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
    SELECT DISTINCT ON (COALESCE(supplier_src_id, 'n.a'))
        COALESCE(supplier_src_id, 'n.a')          AS supplier_src_id,
        COALESCE(supplier_name, 'n.a')            AS supplier_name,
        COALESCE(supplier_email, 'n.a@gmail.com') AS supplier_email,
        COALESCE(street_address, 'n.a')           AS street_address,
        COALESCE(supplier_city, 'n.a')            AS supplier_city,
        COALESCE(supplier_country, 'n.a')         AS supplier_country,
        COALESCE(source_entity, 'n.a')            AS source_entity,
        COALESCE(source_system, 'n.a')             AS source_system,
        supplier_sk
    FROM bl_3nf.ce_suppliers
    ORDER BY COALESCE(supplier_src_id, 'n.a'), supplier_sk DESC
) s
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.DIM_SUPPLIERS d
    WHERE d.supplier_src_id = s.supplier_src_id
);

COMMIT;

INSERT INTO bl_dm.DIM_PRODUCTS
(PRODUCT_SURR_ID, product_src_id, product_name, category, brand, made_in, supplier_name,
 supplier_country, source_entity, source_system, insert_dt, update_dt)
SELECT
    nextval('bl_dm.seq_dim_products_surr_id'),
    p.product_src_id,
    p.product_name,
    p.category,
    p.brand,
    p.made_in,
    COALESCE(s.supplier_name, 'n.a'),
    COALESCE(s.supplier_country, 'n.a'),
    p.source_entity,
    p.source_system,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM (
  
    SELECT DISTINCT ON (COALESCE(product_src_id, 'n.a'))
        COALESCE(product_src_id, 'n.a') AS product_src_id,
        COALESCE(product_name, 'n.a')   AS product_name,
        COALESCE(category, 'n.a')       AS category,
        COALESCE(brand, 'n.a')          AS brand,
        COALESCE(made_in, 'n.a')        AS made_in,
        COALESCE(source_entity, 'n.a')  AS source_entity,
        COALESCE(source_system, 'n.a')  AS source_system,
        supplier_sk,
        product_sk
    FROM bl_3nf.ce_products
    ORDER BY COALESCE(product_src_id, 'n.a'), product_sk DESC
) p
LEFT JOIN bl_3nf.ce_suppliers s
       ON s.supplier_sk = p.supplier_sk
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.DIM_PRODUCTS d
    WHERE d.product_src_id = p.product_src_id
);

COMMIT;

INSERT INTO bl_dm.DIM_BRANCHES
(BRANCH_SURR_ID, branch_src_id, branch_name, branch_address, city, country, region, continent,
 postal_code, source_entity, source_system, insert_dt, update_dt)
SELECT
    nextval('bl_dm.seq_dim_branches_surr_id'),
    COALESCE(b.branch_src_id, 'n.a'),
    COALESCE(b.branch_name, 'n.a'),
    COALESCE(b.branch_address, 'n.a'),
    COALESCE(g.city, 'n.a'),
    COALESCE(g.country, 'n.a'),
    COALESCE(g.region, 'n.a'),
    COALESCE(g.continent, 'n.a'),
    COALESCE(g.postal_code, 'n.a'),
    COALESCE(b.source_entity, 'n.a'),
    COALESCE(b.source_system, 'n.a'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.ce_branches b
LEFT JOIN bl_3nf.ce_geography g
       ON g.city_sk = b.city_sk
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.DIM_BRANCHES d
    WHERE d.branch_src_id = b.branch_src_id
);

COMMIT;

INSERT INTO bl_dm.DIM_PAYMENTS
(PAYMENT_SURR_ID, payment_src_id, payment_type, currency, usd_rate, source_entity, source_system, insert_dt, update_dt)
SELECT
    nextval('bl_dm.seq_dim_payments_surr_id'),
    COALESCE(p.payment_src_id, 'n.a'),
    COALESCE(p.payment_type, 'n.a'),
    COALESCE(p.currency, 'n.a'),
    COALESCE(p.usd_rate, -1.0),
    COALESCE(p.source_entity, 'n.a'),
    COALESCE(p.source_system, 'n.a'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.ce_payments p
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.DIM_PAYMENTS d
    WHERE d.payment_src_id = p.payment_src_id
);

COMMIT;

INSERT INTO bl_dm.DIM_TIME_DAY
(DATE_SURR_ID, date_value, day_num, month_num, quarter_num, year_num, month_name, day_name, is_weekend)
SELECT
    nextval('bl_dm.seq_dim_time_day_surr_id'),
    o.order_date,
    EXTRACT(DAY   FROM o.order_date)::INT,
    EXTRACT(MONTH FROM o.order_date)::INT,
    EXTRACT(QUARTER FROM o.order_date)::INT,
    EXTRACT(YEAR  FROM o.order_date)::INT,
    TO_CHAR(o.order_date, 'Month'),
    TO_CHAR(o.order_date, 'Day'),
    CASE WHEN EXTRACT(ISODOW FROM o.order_date) IN (6,7) THEN 'Y' ELSE 'N' END
FROM (SELECT DISTINCT order_date FROM bl_3nf.ce_orders WHERE order_date IS NOT NULL) o
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.DIM_TIME_DAY d
    WHERE d.date_value = o.order_date
);

COMMIT;


-- Load fact table

INSERT INTO bl_dm.FCT_ORDERS_DD
(ORDER_SURR_ID, order_src_id, CUSTOMER_SURR_ID, EMPLOYEE_SURR_ID, PAYMENT_SURR_ID, BRANCH_SURR_ID, PRODUCT_SURR_ID, DATE_SURR_ID,
 order_status, order_type, quantity, unit_price_usd, total_price_usd,
 unit_price_local, total_price_local, source_entity, source_system, insert_dt, update_dt)
SELECT
    nextval('bl_dm.seq_fct_orders_dd_surr_id'),
    COALESCE(o.order_src_id, 'n.a'),
    COALESCE(dc.CUSTOMER_SURR_ID, (SELECT CUSTOMER_SURR_ID FROM bl_dm.DIM_CUSTOMERS_SCD WHERE customer_src_id = 'n.a')),
    COALESCE(de.EMPLOYEE_SURR_ID, (SELECT EMPLOYEE_SURR_ID FROM bl_dm.DIM_EMPLOYEES WHERE employee_src_id = 'n.a')),
    COALESCE(dp.PAYMENT_SURR_ID,  (SELECT PAYMENT_SURR_ID  FROM bl_dm.DIM_PAYMENTS  WHERE payment_src_id  = 'n.a')),
    COALESCE(db.BRANCH_SURR_ID,   (SELECT BRANCH_SURR_ID   FROM bl_dm.DIM_BRANCHES   WHERE branch_src_id   = 'n.a')),
    COALESCE(dpr.PRODUCT_SURR_ID, (SELECT PRODUCT_SURR_ID  FROM bl_dm.DIM_PRODUCTS  WHERE product_src_id  = 'n.a')),
    COALESCE(dd.DATE_SURR_ID,     (SELECT DATE_SURR_ID     FROM bl_dm.DIM_TIME_DAY  WHERE date_value      = DATE '1900-01-01')),
    COALESCE(o.order_status, 'n.a'),
    COALESCE(o.order_type, 'n.a'),
    COALESCE(oi.quantity, -1),
    COALESCE(oi.unit_price_usd, -1.0),
    COALESCE(oi.total_price_usd, -1.0),
    COALESCE(oi.unit_price_local, -1.0),
    COALESCE(oi.total_price_local, -1.0),
    COALESCE(oi.source_entity, o.source_entity, 'n.a'),
    COALESCE(oi.source_system, o.source_system, 'n.a'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.ce_orders o
JOIN bl_3nf.ce_order_item oi
     ON oi.order_sk = o.order_sk
LEFT JOIN bl_3nf.ce_customers_scd c ON c.customer_sk = o.customer_sk
LEFT JOIN bl_dm.DIM_CUSTOMERS_SCD dc ON dc.customer_src_id = c.customer_src_id
                                     AND dc.start_dt = c.start_dt
LEFT JOIN bl_3nf.ce_employees e     ON e.employee_sk = o.employee_sk
LEFT JOIN bl_dm.DIM_EMPLOYEES de    ON de.employee_src_id = e.employee_src_id
LEFT JOIN bl_3nf.ce_payments p      ON p.payment_sk = o.payment_sk
LEFT JOIN bl_dm.DIM_PAYMENTS dp     ON dp.payment_src_id = p.payment_src_id
LEFT JOIN bl_3nf.ce_branches b      ON b.branch_sk = o.branch_sk
LEFT JOIN bl_dm.DIM_BRANCHES db     ON db.branch_src_id = b.branch_src_id
LEFT JOIN bl_3nf.ce_products pr     ON pr.product_sk = oi.product_sk
LEFT JOIN bl_dm.DIM_PRODUCTS dpr    ON dpr.product_src_id = pr.product_src_id
LEFT JOIN bl_dm.DIM_TIME_DAY dd     ON dd.date_value = o.order_date
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.FCT_ORDERS_DD f
    WHERE f.order_src_id = o.order_src_id
      AND f.PRODUCT_SURR_ID = dpr.PRODUCT_SURR_ID
);

COMMIT;
