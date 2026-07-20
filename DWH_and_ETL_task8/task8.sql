GRANT USAGE  ON SCHEMA bl_3nf TO CURRENT_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA bl_3nf TO CURRENT_USER;

GRANT USAGE  ON SCHEMA bl_dm TO CURRENT_USER;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_dm TO CURRENT_USER;
GRANT USAGE  ON ALL SEQUENCES IN SCHEMA bl_dm TO CURRENT_USER;

GRANT USAGE  ON SCHEMA bl_cl TO CURRENT_USER;
GRANT ALL    ON ALL TABLES IN SCHEMA bl_cl TO CURRENT_USER;

-- 1BL_DM SEQUENCES + TABLES
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_geography_sk;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_payments_sk;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_suppliers_sk;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_products_sk;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_employees_sk;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_branches_sk;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_customers_sk;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_time_day_sk;

-- SCD1 dimension
CREATE TABLE IF NOT EXISTS bl_dm.dim_geography (
    city_surr_id  BIGINT PRIMARY KEY,
    city_src_id   VARCHAR(50) UNIQUE NOT NULL,
    city          VARCHAR(50) NOT NULL,
    country       VARCHAR(50) NOT NULL,
    region        VARCHAR(50) NOT NULL,
    continent     VARCHAR(50) NOT NULL,
    postal_code   VARCHAR(50) NOT NULL,
    source_entity VARCHAR(50) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    insert_dt     TIMESTAMP NOT NULL,
    update_dt     TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_payments (
    payment_surr_id BIGINT PRIMARY KEY,
    payment_src_id  VARCHAR(50) UNIQUE NOT NULL,
    payment_type    VARCHAR(50) NOT NULL,
    currency        VARCHAR(50) NOT NULL,
    usd_rate        DECIMAL(5,2),
    source_entity   VARCHAR(50) NOT NULL,
    source_system   VARCHAR(50) NOT NULL,
    insert_dt       TIMESTAMP NOT NULL,
    update_dt       TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_suppliers (
    supplier_surr_id BIGINT PRIMARY KEY,
    supplier_src_id  VARCHAR(50) UNIQUE NOT NULL,
    supplier_name    VARCHAR(50) NOT NULL,
    supplier_email   VARCHAR(100),
    street_address   VARCHAR(50) NOT NULL,
    supplier_city    VARCHAR(50) NOT NULL,
    supplier_country VARCHAR(50) NOT NULL,
    supplier_primary_industry VARCHAR(50) NOT NULL,
    source_entity    VARCHAR(50) NOT NULL,
    source_system    VARCHAR(50) NOT NULL,
    insert_dt        TIMESTAMP NOT NULL,
    update_dt        TIMESTAMP NOT NULL
);

-- Product dimension
CREATE TABLE IF NOT EXISTS bl_dm.dim_products (
    product_surr_id  BIGINT PRIMARY KEY,
    product_src_id   VARCHAR(50) UNIQUE NOT NULL,
    product_name     VARCHAR(50) NOT NULL,
    category         VARCHAR(50) NOT NULL,
    brand            VARCHAR(50) NOT NULL,
    made_in          VARCHAR(50) NOT NULL,
    supplier_src_id  VARCHAR(50),
    supplier_name    VARCHAR(50),
    supplier_city    VARCHAR(50),
    supplier_country VARCHAR(50),
    supplier_primary_industry VARCHAR(50),
    source_entity    VARCHAR(50) NOT NULL,
    source_system    VARCHAR(50) NOT NULL,
    insert_dt        TIMESTAMP NOT NULL,
    update_dt        TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_employees (
    employee_surr_id BIGINT PRIMARY KEY,
    employee_src_id  VARCHAR(50) UNIQUE NOT NULL,
    employee_name    VARCHAR(50) NOT NULL,
    employee_email   VARCHAR(100),
    gender           VARCHAR(20),
    employee_role    VARCHAR(50) NOT NULL,
    date_of_birth    DATE NOT NULL,
    source_entity    VARCHAR(50) NOT NULL,
    source_system    VARCHAR(50) NOT NULL,
    insert_dt        TIMESTAMP NOT NULL,
    update_dt        TIMESTAMP NOT NULL
);

-- Branch dimension
CREATE TABLE IF NOT EXISTS bl_dm.dim_branches (
    branch_surr_id  BIGINT PRIMARY KEY,
    branch_src_id   VARCHAR(50) UNIQUE NOT NULL,
    branch_name     VARCHAR(200) NOT NULL,
    branch_address  VARCHAR(300) NOT NULL,
    city_src_id     VARCHAR(50),
    city            VARCHAR(50),
    country         VARCHAR(50),
    region          VARCHAR(50),
    continent       VARCHAR(50),
    opened_year     INT,
    branch_size_sqm NUMERIC(12,2),
    manager_src_id  VARCHAR(50) NOT NULL,
    manager_name    VARCHAR(200) NOT NULL,
    manager_email   VARCHAR(200),
    manager_gender  VARCHAR(20),
    manager_birth_date DATE NOT NULL,
    source_entity   VARCHAR(50) NOT NULL,
    source_system   VARCHAR(50) NOT NULL,
    insert_dt       TIMESTAMP NOT NULL,
    update_dt       TIMESTAMP NOT NULL
);

-- SCD2 dimension 
CREATE TABLE IF NOT EXISTS bl_dm.dim_customers_scd (
    customer_surr_id BIGINT NOT NULL,
    customer_src_id  VARCHAR(50) NOT NULL,
    customer_name    VARCHAR(50) NOT NULL,
    customer_email   VARCHAR(100) NOT NULL,
    gender           VARCHAR(20) NOT NULL,
    customer_address VARCHAR(100) NOT NULL,
    date_of_birth    DATE NOT NULL,
    start_dt         DATE NOT NULL,
    end_dt           DATE NOT NULL,
    is_active        CHAR(1) NOT NULL CHECK (is_active IN ('Y','N')),
    source_entity    VARCHAR(50) NOT NULL,
    source_system    VARCHAR(50) NOT NULL,
    insert_dt        TIMESTAMP NOT NULL,
    update_dt        TIMESTAMP NOT NULL,

    PRIMARY KEY (customer_surr_id, start_dt)
);

-- Calendar dimension, daily granularity 
CREATE TABLE IF NOT EXISTS bl_dm.dim_time_day (
    time_surr_id BIGINT PRIMARY KEY,
    full_dt      DATE UNIQUE NOT NULL,
    day_num      INT NOT NULL,
    month_num    INT NOT NULL,
    month_name   VARCHAR(20) NOT NULL,
    quarter_num  INT NOT NULL,
    year_num     INT NOT NULL,
    day_of_week  VARCHAR(20) NOT NULL,
    is_weekend   CHAR(1) NOT NULL CHECK (is_weekend IN ('Y','N')),
    insert_dt    TIMESTAMP NOT NULL,
    update_dt    TIMESTAMP NOT NULL
);

-- 2 COMPOSITE TYPES
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 't_branch_hierarchy') THEN
        CREATE TYPE bl_cl.t_branch_hierarchy AS (
            branch_src_id      VARCHAR,
            branch_name        VARCHAR,
            branch_address     VARCHAR,
            city_src_id        VARCHAR,
            city               VARCHAR,
            country            VARCHAR,
            region             VARCHAR,
            continent          VARCHAR,
            opened_year        INT,
            branch_size_sqm    NUMERIC,
            manager_src_id     VARCHAR,
            manager_name       VARCHAR,
            manager_email      VARCHAR,
            manager_gender     VARCHAR,
            manager_birth_date DATE,
            source_entity      VARCHAR,
            source_system      VARCHAR
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 't_customer_attrs') THEN
        CREATE TYPE bl_cl.t_customer_attrs AS (
            customer_name    VARCHAR,
            customer_email   VARCHAR,
            gender           VARCHAR,
            customer_address VARCHAR,
            date_of_birth    DATE
        );
    END IF;
END $$;

-- 3. DIM_GEOGRAPHY  
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_geography()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows INT := 0;
    v_affected INT;
BEGIN
    FOR rec IN SELECT city_src_id, city, country, region, continent, postal_code,
                      source_entity, source_system
               FROM bl_3nf.ce_geography
    LOOP
        INSERT INTO bl_dm.dim_geography (
            city_surr_id, city_src_id, city, country, region, continent,
            postal_code, source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_dm.seq_dim_geography_sk'), rec.city_src_id, rec.city, rec.country,
            rec.region, rec.continent, rec.postal_code, rec.source_entity,
            rec.source_system, NOW(), NOW()
        )
        ON CONFLICT (city_src_id) DO UPDATE
        SET city = EXCLUDED.city, country = EXCLUDED.country, region = EXCLUDED.region,
            continent = EXCLUDED.continent, postal_code = EXCLUDED.postal_code,
            update_dt = NOW()
        WHERE (bl_dm.dim_geography.city, bl_dm.dim_geography.country,
               bl_dm.dim_geography.region, bl_dm.dim_geography.continent,
               bl_dm.dim_geography.postal_code)
              IS DISTINCT FROM (EXCLUDED.city, EXCLUDED.country, EXCLUDED.region,
                                 EXCLUDED.continent, EXCLUDED.postal_code);
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.sp_write_log('load_dim_geography', v_rows, 'SUCCESS',
        'Upserted ' || v_rows || ' dim_geography rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_dim_geography', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 4 DIM_PAYMENTS 
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_payments()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows INT := 0;
    v_affected INT;
BEGIN
    FOR rec IN SELECT payment_src_id, payment_type, currency, usd_rate,
                      source_entity, source_system
               FROM bl_3nf.ce_payments
    LOOP
        INSERT INTO bl_dm.dim_payments (
            payment_surr_id, payment_src_id, payment_type, currency, usd_rate,
            source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_dm.seq_dim_payments_sk'), rec.payment_src_id, rec.payment_type,
            rec.currency, rec.usd_rate, rec.source_entity, rec.source_system, NOW(), NOW()
        )
        ON CONFLICT (payment_src_id) DO UPDATE
        SET payment_type = EXCLUDED.payment_type, currency = EXCLUDED.currency,
            usd_rate = EXCLUDED.usd_rate, update_dt = NOW()
        WHERE (bl_dm.dim_payments.payment_type, bl_dm.dim_payments.currency,
               bl_dm.dim_payments.usd_rate)
              IS DISTINCT FROM (EXCLUDED.payment_type, EXCLUDED.currency, EXCLUDED.usd_rate);
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.sp_write_log('load_dim_payments', v_rows, 'SUCCESS',
        'Upserted ' || v_rows || ' dim_payments rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_dim_payments', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 5 DIM_SUPPLIERS 
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_suppliers()
LANGUAGE plpgsql
AS $$
DECLARE
    cur_suppliers CURSOR FOR
        SELECT supplier_src_id, supplier_name, supplier_email, street_address,
               supplier_city, supplier_country, supplier_primary_industry,
               source_entity, source_system
        FROM bl_3nf.ce_suppliers;
    rec RECORD;
    v_rows INT := 0;
    v_affected INT;
BEGIN
    FOR rec IN cur_suppliers LOOP
        INSERT INTO bl_dm.dim_suppliers (
            supplier_surr_id, supplier_src_id, supplier_name, supplier_email,
            street_address, supplier_city, supplier_country, supplier_primary_industry,
            source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_dm.seq_dim_suppliers_sk'), rec.supplier_src_id, rec.supplier_name,
            rec.supplier_email, rec.street_address, rec.supplier_city, rec.supplier_country,
            rec.supplier_primary_industry, rec.source_entity, rec.source_system, NOW(), NOW()
        )
        ON CONFLICT (supplier_src_id) DO UPDATE
        SET supplier_name = EXCLUDED.supplier_name, supplier_email = EXCLUDED.supplier_email,
            street_address = EXCLUDED.street_address, supplier_city = EXCLUDED.supplier_city,
            supplier_country = EXCLUDED.supplier_country,
            supplier_primary_industry = EXCLUDED.supplier_primary_industry, update_dt = NOW()
        WHERE (bl_dm.dim_suppliers.supplier_name, bl_dm.dim_suppliers.supplier_email,
               bl_dm.dim_suppliers.street_address, bl_dm.dim_suppliers.supplier_city,
               bl_dm.dim_suppliers.supplier_country, bl_dm.dim_suppliers.supplier_primary_industry)
              IS DISTINCT FROM
              (EXCLUDED.supplier_name, EXCLUDED.supplier_email, EXCLUDED.street_address,
               EXCLUDED.supplier_city, EXCLUDED.supplier_country, EXCLUDED.supplier_primary_industry);
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.sp_write_log('load_dim_suppliers', v_rows, 'SUCCESS',
        'Upserted ' || v_rows || ' dim_suppliers rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_dim_suppliers', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 6 DIM_PRODUCTS  (dynamic EXECUTE upsert, hierarchy flattened)
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_products()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_sql TEXT;
    v_rows INT := 0;
    v_affected INT;
BEGIN
    FOR rec IN
        SELECT p.product_src_id, p.product_name, p.category, p.brand, p.made_in,
               s.supplier_src_id, s.supplier_name, s.supplier_city, s.supplier_country,
               s.supplier_primary_industry, p.source_entity, p.source_system
        FROM bl_3nf.ce_products p
        LEFT JOIN bl_3nf.ce_suppliers s ON s.supplier_sk = p.supplier_sk
    LOOP
        v_sql := format(
            'INSERT INTO bl_dm.dim_products (
                 product_surr_id, product_src_id, product_name, category, brand, made_in,
                 supplier_src_id, supplier_name, supplier_city, supplier_country,
                 supplier_primary_industry, source_entity, source_system, insert_dt, update_dt
             )
             VALUES (nextval(%L), %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, NOW(), NOW())
             ON CONFLICT (product_src_id) DO UPDATE
             SET product_name = EXCLUDED.product_name, category = EXCLUDED.category,
                 brand = EXCLUDED.brand, made_in = EXCLUDED.made_in,
                 supplier_src_id = EXCLUDED.supplier_src_id, supplier_name = EXCLUDED.supplier_name,
                 supplier_city = EXCLUDED.supplier_city, supplier_country = EXCLUDED.supplier_country,
                 supplier_primary_industry = EXCLUDED.supplier_primary_industry, update_dt = NOW()
             WHERE (bl_dm.dim_products.product_name, bl_dm.dim_products.category,
                    bl_dm.dim_products.brand, bl_dm.dim_products.made_in,
                    bl_dm.dim_products.supplier_src_id, bl_dm.dim_products.supplier_name,
                    bl_dm.dim_products.supplier_city, bl_dm.dim_products.supplier_country,
                    bl_dm.dim_products.supplier_primary_industry)
                   IS DISTINCT FROM
                   (EXCLUDED.product_name, EXCLUDED.category, EXCLUDED.brand, EXCLUDED.made_in,
                    EXCLUDED.supplier_src_id, EXCLUDED.supplier_name, EXCLUDED.supplier_city,
                    EXCLUDED.supplier_country, EXCLUDED.supplier_primary_industry);',
            'bl_dm.seq_dim_products_sk', rec.product_src_id, rec.product_name, rec.category,
            rec.brand, rec.made_in, rec.supplier_src_id, rec.supplier_name, rec.supplier_city,
            rec.supplier_country, rec.supplier_primary_industry, rec.source_entity, rec.source_system
        );
        EXECUTE v_sql;
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.sp_write_log('load_dim_products', v_rows, 'SUCCESS',
        'Upserted ' || v_rows || ' dim_products rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_dim_products', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 7 DIM_EMPLOYEES  (upsert)
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows INT := 0;
    v_affected INT;
BEGIN
    FOR rec IN SELECT employee_src_id, employee_name, employee_email, gender,
                      employee_role, date_of_birth, source_entity, source_system
               FROM bl_3nf.ce_employees
    LOOP
        INSERT INTO bl_dm.dim_employees (
            employee_surr_id, employee_src_id, employee_name, employee_email, gender,
            employee_role, date_of_birth, source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_dm.seq_dim_employees_sk'), rec.employee_src_id, rec.employee_name,
            rec.employee_email, rec.gender, rec.employee_role, rec.date_of_birth,
            rec.source_entity, rec.source_system, NOW(), NOW()
        )
        ON CONFLICT (employee_src_id) DO UPDATE
        SET employee_name = EXCLUDED.employee_name, employee_email = EXCLUDED.employee_email,
            gender = EXCLUDED.gender, employee_role = EXCLUDED.employee_role,
            date_of_birth = EXCLUDED.date_of_birth, update_dt = NOW()
        WHERE (bl_dm.dim_employees.employee_name, bl_dm.dim_employees.employee_email,
               bl_dm.dim_employees.gender, bl_dm.dim_employees.employee_role,
               bl_dm.dim_employees.date_of_birth)
              IS DISTINCT FROM
              (EXCLUDED.employee_name, EXCLUDED.employee_email, EXCLUDED.gender,
               EXCLUDED.employee_role, EXCLUDED.date_of_birth);
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.sp_write_log('load_dim_employees', v_rows, 'SUCCESS',
        'Upserted ' || v_rows || ' dim_employees rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_dim_employees', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 8 DIM_BRANCHES  
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_branches()
LANGUAGE plpgsql
AS $$
DECLARE
    v_cur   REFCURSOR;                 -- cursor variable
    rec     bl_cl.t_branch_hierarchy;  -- composite type
    v_sql   TEXT;
    v_rows  INT := 0;
    v_affected INT;
BEGIN
    v_sql := 'SELECT b.branch_src_id, b.branch_name, b.branch_address,
                     g.city_src_id, g.city, g.country, g.region, g.continent,
                     b.opened_year, b.branch_size_sqm, b.manager_src_id, b.manager_name,
                     b.manager_email, b.manager_gender, b.manager_birth_date,
                     b.source_entity, b.source_system
              FROM bl_3nf.ce_branches b
              LEFT JOIN bl_3nf.ce_geography g ON g.city_sk = b.city_sk';

    OPEN v_cur FOR EXECUTE v_sql;      -- dynamic query via EXECUTE, opened into a cursor variable
    LOOP
        FETCH v_cur INTO rec;
        EXIT WHEN NOT FOUND;

        INSERT INTO bl_dm.dim_branches (
            branch_surr_id, branch_src_id, branch_name, branch_address,
            city_src_id, city, country, region, continent,
            opened_year, branch_size_sqm, manager_src_id, manager_name, manager_email,
            manager_gender, manager_birth_date, source_entity, source_system,
            insert_dt, update_dt
        )
        VALUES (
            nextval('bl_dm.seq_dim_branches_sk'), rec.branch_src_id, rec.branch_name,
            rec.branch_address, rec.city_src_id, rec.city, rec.country, rec.region, rec.continent,
            rec.opened_year, rec.branch_size_sqm, rec.manager_src_id, rec.manager_name,
            rec.manager_email, rec.manager_gender, rec.manager_birth_date,
            rec.source_entity, rec.source_system, NOW(), NOW()
        )
        ON CONFLICT (branch_src_id) DO UPDATE
        SET branch_name = EXCLUDED.branch_name, branch_address = EXCLUDED.branch_address,
            city_src_id = EXCLUDED.city_src_id, city = EXCLUDED.city, country = EXCLUDED.country,
            region = EXCLUDED.region, continent = EXCLUDED.continent,
            opened_year = EXCLUDED.opened_year, branch_size_sqm = EXCLUDED.branch_size_sqm,
            manager_src_id = EXCLUDED.manager_src_id, manager_name = EXCLUDED.manager_name,
            manager_email = EXCLUDED.manager_email, manager_gender = EXCLUDED.manager_gender,
            manager_birth_date = EXCLUDED.manager_birth_date, update_dt = NOW()
        WHERE (bl_dm.dim_branches.branch_name, bl_dm.dim_branches.branch_address,
               bl_dm.dim_branches.city, bl_dm.dim_branches.manager_name,
               bl_dm.dim_branches.manager_email, bl_dm.dim_branches.manager_gender)
              IS DISTINCT FROM
              (EXCLUDED.branch_name, EXCLUDED.branch_address, EXCLUDED.city,
               EXCLUDED.manager_name, EXCLUDED.manager_email, EXCLUDED.manager_gender);
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;
    CLOSE v_cur;

    CALL bl_cl.sp_write_log('load_dim_branches', v_rows, 'SUCCESS',
        'Upserted ' || v_rows || ' dim_branches rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_dim_branches', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


-- 9 DIM_CUSTOMERS_SCD

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_customers_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    cur_customers CURSOR FOR
        SELECT customer_src_id, customer_name, customer_email, gender, customer_address,
               date_of_birth, source_entity, source_system
        FROM bl_3nf.ce_customers_scd
        WHERE is_active = 'Y';
    rec RECORD;
    v_active_attrs   bl_cl.t_customer_attrs;
    v_incoming_attrs bl_cl.t_customer_attrs;
    v_active_surr_id BIGINT;
    v_rows INT := 0;
BEGIN
    FOR rec IN cur_customers LOOP

        v_incoming_attrs := ROW(rec.customer_name, rec.customer_email, rec.gender,
                                 rec.customer_address, rec.date_of_birth)::bl_cl.t_customer_attrs;

        SELECT ROW(customer_name, customer_email, gender, customer_address, date_of_birth)::bl_cl.t_customer_attrs,
               customer_surr_id
        INTO v_active_attrs, v_active_surr_id
        FROM bl_dm.dim_customers_scd
        WHERE customer_src_id = rec.customer_src_id AND is_active = 'Y';

        IF NOT FOUND THEN
            INSERT INTO bl_dm.dim_customers_scd (
                customer_surr_id, customer_src_id, customer_name, customer_email, gender,
                customer_address, date_of_birth, start_dt, end_dt, is_active,
                source_entity, source_system, insert_dt, update_dt
            )
            VALUES (
                nextval('bl_dm.seq_dim_customers_sk'), rec.customer_src_id, rec.customer_name,
                rec.customer_email, rec.gender, rec.customer_address, rec.date_of_birth,
                DATE '1990-01-01', DATE '9999-12-31', 'Y',
                rec.source_entity, rec.source_system, NOW(), NOW()
            );
            v_rows := v_rows + 1;

        ELSIF v_active_attrs IS DISTINCT FROM v_incoming_attrs THEN
            -- attribute change on 3NF SCD2 -> propagate as a new DM version
            UPDATE bl_dm.dim_customers_scd
            SET end_dt = CURRENT_DATE - 1, is_active = 'N', update_dt = NOW()
            WHERE customer_surr_id = v_active_surr_id AND is_active = 'Y';

            INSERT INTO bl_dm.dim_customers_scd (
                customer_surr_id, customer_src_id, customer_name, customer_email, gender,
                customer_address, date_of_birth, start_dt, end_dt, is_active,
                source_entity, source_system, insert_dt, update_dt
            )
            VALUES (
                nextval('bl_dm.seq_dim_customers_sk'), rec.customer_src_id, rec.customer_name,
                rec.customer_email, rec.gender, rec.customer_address, rec.date_of_birth,
                CURRENT_DATE, DATE '9999-12-31', 'Y',
                rec.source_entity, rec.source_system, NOW(), NOW()
            );
            v_rows := v_rows + 1;
        END IF;
    END LOOP;

    CALL bl_cl.sp_write_log('load_dim_customers_scd', v_rows, 'SUCCESS',
        'Versioned ' || v_rows || ' dim_customers_scd rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_dim_customers_scd', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 10 DIM_TIME_DAY
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_time_day(p_start DATE, p_end DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT := 0;
BEGIN
    INSERT INTO bl_dm.dim_time_day (
        time_surr_id, full_dt, day_num, month_num, month_name, quarter_num,
        year_num, day_of_week, is_weekend, insert_dt, update_dt
    )
    SELECT nextval('bl_dm.seq_dim_time_day_sk'), d::date,
           EXTRACT(DAY FROM d)::INT, EXTRACT(MONTH FROM d)::INT, TO_CHAR(d,'Month'),
           EXTRACT(QUARTER FROM d)::INT, EXTRACT(YEAR FROM d)::INT, TO_CHAR(d,'Day'),
           CASE WHEN EXTRACT(ISODOW FROM d) IN (6,7) THEN 'Y' ELSE 'N' END,
           NOW(), NOW()
    FROM generate_series(p_start, p_end, INTERVAL '1 day') d
    ON CONFLICT (full_dt) DO NOTHING;

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    CALL bl_cl.sp_write_log('load_dim_time_day', v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' dim_time_day rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_dim_time_day', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 11 MASTER ORCHESTRATION PROCEDURE

CREATE OR REPLACE PROCEDURE bl_cl.load_all_dm()
LANGUAGE plpgsql
AS $$
BEGIN
    CALL bl_cl.load_dim_geography();
    CALL bl_cl.load_dim_payments();
    CALL bl_cl.load_dim_suppliers();
    CALL bl_cl.load_dim_products();
    CALL bl_cl.load_dim_employees();
    CALL bl_cl.load_dim_branches();
    CALL bl_cl.load_dim_customers_scd();
    CALL bl_cl.load_dim_time_day(DATE '2020-01-01', DATE '2030-12-31');
END;
$$;


