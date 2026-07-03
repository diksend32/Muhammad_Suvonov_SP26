CREATE SCHEMA IF NOT EXISTS bl_dm;

CREATE TABLE IF NOT EXISTS bl_dm.dm_customer (
    customer_sk       BIGSERIAL PRIMARY KEY,
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

CREATE TABLE IF NOT EXISTS bl_dm.dm_employee (
    employee_sk       BIGSERIAL PRIMARY KEY,
    employee_src_id   VARCHAR(50) UNIQUE NOT NULL,
    employee_name     VARCHAR(50) NOT NULL,
    employee_email    VARCHAR(100),
    gender            VARCHAR(20),
    employee_role     VARCHAR(50) NOT NULL CHECK (employee_role IN ('Seller','Courier','n.a')),
    date_of_birth     DATE        NOT NULL,
    source_entity     VARCHAR(50) NOT NULL,
    source_system     VARCHAR(50) NOT NULL,
    insert_dt         TIMESTAMP   NOT NULL,
    update_dt         TIMESTAMP   NOT NULL
);


CREATE TABLE IF NOT EXISTS bl_dm.dm_supplier (
    supplier_sk       BIGSERIAL PRIMARY KEY,
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


CREATE TABLE IF NOT EXISTS bl_dm.dm_product (
    product_sk        BIGSERIAL PRIMARY KEY,
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


CREATE TABLE IF NOT EXISTS bl_dm.dm_branch (
    branch_sk         BIGSERIAL PRIMARY KEY,
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

CREATE TABLE IF NOT EXISTS bl_dm.dm_payment (
    payment_sk        BIGSERIAL PRIMARY KEY,
    payment_src_id    VARCHAR(50) UNIQUE NOT NULL,
    payment_type      VARCHAR(50) NOT NULL,
    currency          VARCHAR(50) NOT NULL,
    usd_rate          DECIMAL(5,2),
    source_entity     VARCHAR(50) NOT NULL,
    source_system     VARCHAR(50) NOT NULL,
    insert_dt         TIMESTAMP   NOT NULL,
    update_dt         TIMESTAMP   NOT NULL
);


CREATE TABLE IF NOT EXISTS bl_dm.dm_date (
    date_sk           BIGSERIAL PRIMARY KEY,
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



INSERT INTO bl_dm.dm_customer
(customer_src_id, customer_name, customer_email, gender, customer_address,
 date_of_birth, start_dt, end_dt, is_active, source_entity, source_system, insert_dt, update_dt)
SELECT 'n.a','n.a','n.a@gmail.com','Unknown','n.a', DATE '1900-01-01',
       DATE '1900-01-01', DATE '9999-12-31', 'Y', 'n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dm_customer WHERE customer_src_id = 'n.a');

INSERT INTO bl_dm.dm_employee
(employee_src_id, employee_name, employee_email, gender, employee_role,
 date_of_birth, source_entity, source_system, insert_dt, update_dt)
SELECT 'n.a','n.a','n.a@uzbekland.com','Unknown','n.a', DATE '1900-01-01',
       'n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dm_employee WHERE employee_src_id = 'n.a');

INSERT INTO bl_dm.dm_supplier
(supplier_src_id, supplier_name, supplier_email, street_address, supplier_city,
 supplier_country, source_entity, source_system, insert_dt, update_dt)
SELECT 'n.a','n.a','n.a@gmail.com','n.a','n.a','n.a','n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dm_supplier WHERE supplier_src_id = 'n.a');

INSERT INTO bl_dm.dm_product
(product_src_id, product_name, category, brand, made_in, supplier_name,
 supplier_country, source_entity, source_system, insert_dt, update_dt)
SELECT 'n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dm_product WHERE product_src_id = 'n.a');

INSERT INTO bl_dm.dm_branch
(branch_src_id, branch_name, branch_address, city, country, region, continent,
 postal_code, source_entity, source_system, insert_dt, update_dt)
SELECT 'n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dm_branch WHERE branch_src_id = 'n.a');

INSERT INTO bl_dm.dm_payment
(payment_src_id, payment_type, currency, usd_rate, source_entity, source_system, insert_dt, update_dt)
SELECT 'n.a','n.a','n.a', -1.0, 'n.a','n.a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dm_payment WHERE payment_src_id = 'n.a');

INSERT INTO bl_dm.dm_date
(date_value, day_num, month_num, quarter_num, year_num, month_name, day_name, is_weekend)
SELECT DATE '1900-01-01', 1, 1, 1, 1900, 'n.a', 'n.a', 'N'
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dm_date WHERE date_value = DATE '1900-01-01');

COMMIT;


CREATE TABLE IF NOT EXISTS bl_dm.fct_orders (
    fct_order_sk       BIGSERIAL PRIMARY KEY,
    order_src_id       VARCHAR(50) NOT NULL,
    customer_sk        BIGINT REFERENCES bl_dm.dm_customer(customer_sk),
    employee_sk        BIGINT REFERENCES bl_dm.dm_employee(employee_sk),
    payment_sk         BIGINT REFERENCES bl_dm.dm_payment(payment_sk),
    branch_sk          BIGINT REFERENCES bl_dm.dm_branch(branch_sk),
    product_sk         BIGINT REFERENCES bl_dm.dm_product(product_sk),
    date_sk             BIGINT REFERENCES bl_dm.dm_date(date_sk),
    order_status       VARCHAR(50) NOT NULL,
    order_type         VARCHAR(50) NOT NULL,
    quantity           INT NOT NULL CHECK (quantity > 0),
    unit_price_usd     DECIMAL(5,2) CHECK (unit_price_usd > 0),
    total_price_usd    DECIMAL(5,2) CHECK (total_price_usd > 0),
    unit_price_local   DECIMAL(5,2) CHECK (unit_price_local > 0),
    total_price_local  DECIMAL(5,2) CHECK (total_price_local > 0),
    source_entity      VARCHAR(50) NOT NULL,
    source_system      VARCHAR(50) NOT NULL,
    insert_dt          TIMESTAMP   NOT NULL,
    update_dt          TIMESTAMP   NOT NULL,
    UNIQUE (order_src_id, product_sk)
);

COMMIT;


INSERT INTO bl_dm.dm_customer
(customer_src_id, customer_name, customer_email, gender, customer_address,
 date_of_birth, start_dt, end_dt, is_active, source_entity, source_system, insert_dt, update_dt)
SELECT
    COALESCE(c.customer_src_id, 'n.a'),
    COALESCE(c.customer_name, 'n.a'),
    COALESCE(c.customer_email, 'n.a@gmail.com'),
    COALESCE(c.gender, 'Unknown'),
    COALESCE(c.customer_address, 'n.a'),
    COALESCE(c.date_of_birth, DATE '1900-01-01'),
    COALESCE(c.start_dt, DATE '1900-01-01'),
    COALESCE(c.end_dt, DATE '9999-12-31'),
    COALESCE(c.is_active, 'Y'),
    COALESCE(c.source_entity, 'n.a'),
    COALESCE(c.source_system, 'n.a'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.ce_customers_scd c
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.dm_customer d
    WHERE d.customer_src_id = c.customer_src_id
      AND d.start_dt = c.start_dt
);

COMMIT;

INSERT INTO bl_dm.dm_employee
(employee_src_id, employee_name, employee_email, gender, employee_role,
 date_of_birth, source_entity, source_system, insert_dt, update_dt)
SELECT
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
    SELECT 1 FROM bl_dm.dm_employee d
    WHERE d.employee_src_id = e.employee_src_id
);

COMMIT;


INSERT INTO bl_dm.dm_supplier
(supplier_src_id, supplier_name, supplier_email, street_address, supplier_city,
 supplier_country, source_entity, source_system, insert_dt, update_dt)
SELECT
    COALESCE(s.supplier_src_id, 'n.a'),
    COALESCE(s.supplier_name, 'n.a'),
    COALESCE(s.supplier_email, 'n.a@gmail.com'),
    COALESCE(s.street_address, 'n.a'),
    COALESCE(s.supplier_city, 'n.a'),
    COALESCE(s.supplier_country, 'n.a'),
    COALESCE(s.source_entity, 'n.a'),
    COALESCE(s.source_system, 'n.a'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.ce_suppliers s
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.dm_supplier d
    WHERE d.supplier_src_id = s.supplier_src_id
);

COMMIT;

INSERT INTO bl_dm.dm_product
(product_src_id, product_name, category, brand, made_in, supplier_name,
 supplier_country, source_entity, source_system, insert_dt, update_dt)
SELECT
    COALESCE(p.product_src_id, 'n.a'),
    COALESCE(p.product_name, 'n.a'),
    COALESCE(p.category, 'n.a'),
    COALESCE(p.brand, 'n.a'),
    COALESCE(p.made_in, 'n.a'),
    COALESCE(s.supplier_name, 'n.a'),
    COALESCE(s.supplier_country, 'n.a'),
    COALESCE(p.source_entity, 'n.a'),
    COALESCE(p.source_system, 'n.a'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM bl_3nf.ce_products p
LEFT JOIN bl_3nf.ce_suppliers s
       ON s.supplier_sk = p.supplier_sk
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.dm_product d
    WHERE d.product_src_id = p.product_src_id
);

COMMIT;


INSERT INTO bl_dm.dm_branch
(branch_src_id, branch_name, branch_address, city, country, region, continent,
 postal_code, source_entity, source_system, insert_dt, update_dt)
SELECT
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
    SELECT 1 FROM bl_dm.dm_branch d
    WHERE d.branch_src_id = b.branch_src_id
);

COMMIT;

INSERT INTO bl_dm.dm_payment
(payment_src_id, payment_type, currency, usd_rate, source_entity, source_system, insert_dt, update_dt)
SELECT
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
    SELECT 1 FROM bl_dm.dm_payment d
    WHERE d.payment_src_id = p.payment_src_id
);

COMMIT;

INSERT INTO bl_dm.dm_date
(date_value, day_num, month_num, quarter_num, year_num, month_name, day_name, is_weekend)
SELECT
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
    SELECT 1 FROM bl_dm.dm_date d
    WHERE d.date_value = o.order_date
);

COMMIT;


INSERT INTO bl_dm.fct_orders
(order_src_id, customer_sk, employee_sk, payment_sk, branch_sk, product_sk, date_sk,
 order_status, order_type, quantity, unit_price_usd, total_price_usd,
 unit_price_local, total_price_local, source_entity, source_system, insert_dt, update_dt)
SELECT
    COALESCE(o.order_src_id, 'n.a'),
    COALESCE(dc.customer_sk, (SELECT customer_sk FROM bl_dm.dm_customer WHERE customer_src_id = 'n.a')),
    COALESCE(de.employee_sk, (SELECT employee_sk FROM bl_dm.dm_employee WHERE employee_src_id = 'n.a')),
    COALESCE(dp.payment_sk,  (SELECT payment_sk  FROM bl_dm.dm_payment  WHERE payment_src_id  = 'n.a')),
    COALESCE(db.branch_sk,   (SELECT branch_sk   FROM bl_dm.dm_branch   WHERE branch_src_id   = 'n.a')),
    COALESCE(dpr.product_sk, (SELECT product_sk  FROM bl_dm.dm_product  WHERE product_src_id  = 'n.a')),
    COALESCE(dd.date_sk,     (SELECT date_sk     FROM bl_dm.dm_date     WHERE date_value      = DATE '1900-01-01')),
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
LEFT JOIN bl_dm.dm_customer dc      ON dc.customer_src_id = c.customer_src_id
                                    AND dc.start_dt = c.start_dt
LEFT JOIN bl_3nf.ce_employees e     ON e.employee_sk = o.employee_sk
LEFT JOIN bl_dm.dm_employee de      ON de.employee_src_id = e.employee_src_id
LEFT JOIN bl_3nf.ce_payments p      ON p.payment_sk = o.payment_sk
LEFT JOIN bl_dm.dm_payment dp       ON dp.payment_src_id = p.payment_src_id
LEFT JOIN bl_3nf.ce_branches b      ON b.branch_sk = o.branch_sk
LEFT JOIN bl_dm.dm_branch db        ON db.branch_src_id = b.branch_src_id
LEFT JOIN bl_3nf.ce_products pr     ON pr.product_sk = oi.product_sk
LEFT JOIN bl_dm.dm_product dpr      ON dpr.product_src_id = pr.product_src_id
LEFT JOIN bl_dm.dm_date dd          ON dd.date_value = o.order_date
WHERE NOT EXISTS (
    SELECT 1 FROM bl_dm.fct_orders f
    WHERE f.order_src_id = o.order_src_id
      AND f.product_sk   = dpr.product_sk
);

COMMIT;