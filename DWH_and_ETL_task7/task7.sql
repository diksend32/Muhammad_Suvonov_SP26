
CREATE SCHEMA IF NOT EXISTS bl_cl;

GRANT USAGE  ON SCHEMA sa_offline_sales TO CURRENT_USER;
GRANT USAGE  ON SCHEMA sa_online_sales  TO CURRENT_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA sa_offline_sales TO CURRENT_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA sa_online_sales  TO CURRENT_USER;

GRANT USAGE  ON SCHEMA bl_3nf TO CURRENT_USER;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_3nf TO CURRENT_USER;
GRANT USAGE  ON ALL SEQUENCES IN SCHEMA bl_3nf TO CURRENT_USER;

GRANT USAGE  ON SCHEMA bl_cl TO CURRENT_USER;
GRANT ALL    ON ALL TABLES IN SCHEMA bl_cl TO CURRENT_USER;

-- 1 CENTRALIZED LOGGING TABLE

CREATE SEQUENCE IF NOT EXISTS bl_cl.seq_load_log;

CREATE TABLE IF NOT EXISTS bl_cl.load_log (
    log_id          BIGINT PRIMARY KEY DEFAULT nextval('bl_cl.seq_load_log'),
    log_dt          TIMESTAMP NOT NULL DEFAULT NOW(),
    procedure_name  VARCHAR(100) NOT NULL,
    rows_affected   INT NOT NULL,
    status          VARCHAR(20)  NOT NULL CHECK (status IN ('SUCCESS','ERROR')),
    message         VARCHAR(1000)
);

CREATE OR REPLACE PROCEDURE bl_cl.sp_write_log(
    p_procedure_name VARCHAR,
    p_rows_affected  INT,
    p_status         VARCHAR,
    p_message        VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO bl_cl.load_log(procedure_name, rows_affected, status, message)
    VALUES (p_procedure_name, p_rows_affected, p_status, p_message);
END;
$$;

-- 2 GEOGRAPHY  (CE_GEOGRAPHY)  
CREATE OR REPLACE FUNCTION bl_cl.fn_new_geography()
RETURNS TABLE (
    city_src_id VARCHAR,
    city        VARCHAR,
    country     VARCHAR,
    region      VARCHAR,
    continent   VARCHAR,
    postal_code VARCHAR,
    source_entity VARCHAR,
    source_system VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.cityid)
           u.cityid, u.city, u.country, u.region, u.continent, u.postalcode,
           u.source_entity, u.source_system
    FROM (
        SELECT cityid, city, country, region, continent, postalcode,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(cityid),'') IS NOT NULL
        UNION ALL
        SELECT cityid, city, country, region, continent, postalcode,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(cityid),'') IS NOT NULL
    ) u
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.ce_geography g WHERE g.city_src_id = u.cityid
    )
    ORDER BY u.cityid;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_geography()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_new_geography() LOOP
        INSERT INTO bl_3nf.ce_geography (
            city_sk, city_src_id, city, country, region, continent,
            postal_code, source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_3nf.seq_ce_geography_sk'), rec.city_src_id, rec.city,
            rec.country, rec.region, rec.continent, rec.postal_code,
            rec.source_entity, rec.source_system, NOW(), NOW()
        )
        ON CONFLICT (city_src_id) DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_geography', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new geography rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_geography', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 3. PAYMENTS 
CREATE OR REPLACE FUNCTION bl_cl.fn_new_payments()
RETURNS TABLE (
    payment_src_id VARCHAR,
    payment_type   VARCHAR,
    currency       VARCHAR,
    usd_rate       NUMERIC,
    source_entity  VARCHAR,
    source_system  VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.paymentid)
           u.paymentid, u.paymenttype, u.currency,
           NULLIF(u.usdrate,'')::NUMERIC(5,2),
           u.source_entity, u.source_system
    FROM (
        SELECT paymentid, paymenttype, currency, usdrate,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(paymentid),'') IS NOT NULL
        UNION ALL
        SELECT paymentid, paymenttype, currency, usdrate,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(paymentid),'') IS NOT NULL
    ) u
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.ce_payments p WHERE p.payment_src_id = u.paymentid
    )
    ORDER BY u.paymentid;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_payments()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_new_payments() LOOP
        INSERT INTO bl_3nf.ce_payments (
            payment_sk, payment_src_id, payment_type, currency, usd_rate,
            source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_3nf.seq_ce_payments_sk'), rec.payment_src_id, rec.payment_type,
            rec.currency, rec.usd_rate, rec.source_entity, rec.source_system, NOW(), NOW()
        )
        ON CONFLICT (payment_src_id) DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_payments', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new payment rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_payments', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


-- 4. SUPPLIERS 
CREATE OR REPLACE FUNCTION bl_cl.fn_new_suppliers()
RETURNS TABLE (
    supplier_src_id VARCHAR,
    supplier_name   VARCHAR,
    supplier_email  VARCHAR,
    street_address  VARCHAR,
    supplier_city   VARCHAR,
    supplier_country VARCHAR,
    supplier_primary_industry VARCHAR,
    source_entity   VARCHAR,
    source_system   VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.supplierid)
           u.supplierid, u.supplier, u.supplieremail, u.supplierstreetaddress,
           u.suppliercity, u.suppliercountry, u.supplierprimaryindustry,
           u.source_entity, u.source_system
    FROM (
        SELECT supplierid, supplier, supplieremail, supplierstreetaddress,
               suppliercity, suppliercountry, supplierprimaryindustry,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(supplierid),'') IS NOT NULL
        UNION ALL
        SELECT supplierid, supplier, supplieremail, supplierstreetaddress,
               suppliercity, suppliercountry, supplierprimaryindustry,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(supplierid),'') IS NOT NULL
    ) u
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.ce_suppliers s WHERE s.supplier_src_id = u.supplierid
    )
    ORDER BY u.supplierid;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_suppliers()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_new_suppliers() LOOP
        INSERT INTO bl_3nf.ce_suppliers (
            supplier_sk, supplier_src_id, supplier_name, supplier_email,
            street_address, supplier_city, supplier_country,
            source_entity, source_system, supplier_primary_industry,
            insert_dt, update_dt
        )
        VALUES (
            nextval('bl_3nf.seq_ce_suppliers_sk'), rec.supplier_src_id, rec.supplier_name,
            rec.supplier_email, rec.street_address, rec.supplier_city, rec.supplier_country,
            rec.source_entity, rec.source_system, rec.supplier_primary_industry,
            NOW(), NOW()
        );
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_suppliers', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new supplier rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_suppliers', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 5 PRODUCTS
CREATE OR REPLACE FUNCTION bl_cl.fn_new_products()
RETURNS TABLE (
    product_src_id VARCHAR,
    supplier_src_id VARCHAR,
    product_name   VARCHAR,
    category       VARCHAR,
    brand          VARCHAR,
    made_in        VARCHAR,
    source_entity  VARCHAR,
    source_system  VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.productid)
           u.productid, u.supplierid, u.productname, u.category, u.brand, u.madein,
           u.source_entity, u.source_system
    FROM (
        SELECT productid, supplierid, productname, category, brand, madein,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(productid),'') IS NOT NULL
        UNION ALL
        SELECT productid, supplierid, productname AS productname,
               productcategory AS category, productbrand AS brand, productmadein AS madein,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(productid),'') IS NOT NULL
    ) u
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.ce_products p WHERE p.product_src_id = u.productid
    )
    ORDER BY u.productid;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_products()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_supplier_sk BIGINT;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_new_products() LOOP
        SELECT supplier_sk INTO v_supplier_sk
        FROM bl_3nf.ce_suppliers
        WHERE supplier_src_id = rec.supplier_src_id;

        INSERT INTO bl_3nf.ce_products (
            product_sk, product_src_id, supplier_sk, product_name, category,
            brand, made_in, source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_3nf.seq_ce_products_sk'), rec.product_src_id, v_supplier_sk,
            rec.product_name, rec.category, rec.brand, rec.made_in,
            rec.source_entity, rec.source_system, NOW(), NOW()
        );
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_products', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new product rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_products', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


-- 6 EMPLOYEES  

CREATE OR REPLACE FUNCTION bl_cl.fn_new_employees()
RETURNS TABLE (
    employee_src_id VARCHAR,
    employee_name   VARCHAR,
    employee_email  VARCHAR,
    gender          VARCHAR,
    employee_role   VARCHAR,
    date_of_birth   DATE,
    source_entity   VARCHAR,
    source_system   VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.employee_src_id)
           u.employee_src_id, u.employee_name, u.employee_email, u.gender,
           u.employee_role, u.date_of_birth, u.source_entity, u.source_system
    FROM (
        SELECT sellerid AS employee_src_id, sellername AS employee_name,
               selleremail AS employee_email, sellergender AS gender,
               'Seller' AS employee_role,
               TO_DATE(NULLIF(sellerbirthdate,''), 'MM/DD/YYYY') AS date_of_birth,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(sellerid),'') IS NOT NULL
        UNION ALL
        SELECT courierid AS employee_src_id, couriername AS employee_name,
               courieremail AS employee_email, couriergender AS gender,
               'Courier' AS employee_role,
               TO_DATE(NULLIF(courierbirthdate,''), 'MM/DD/YYYY') AS date_of_birth,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(courierid),'') IS NOT NULL
    ) u
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.ce_employees e WHERE e.employee_src_id = u.employee_src_id
    )
    ORDER BY u.employee_src_id;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_new_employees() LOOP
        INSERT INTO bl_3nf.ce_employees (
            employee_sk, employee_src_id, employee_name, employee_email, gender,
            employee_role, date_of_birth, source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_3nf.seq_ce_employees_sk'), rec.employee_src_id, rec.employee_name,
            rec.employee_email, rec.gender, rec.employee_role, rec.date_of_birth,
            rec.source_entity, rec.source_system, NOW(), NOW()
        );
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_employees', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new employee rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_employees', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


-- 7. BRANCHES 
CREATE OR REPLACE FUNCTION bl_cl.fn_new_branches()
RETURNS TABLE (
    branch_src_id   VARCHAR,
    branch_name     VARCHAR,
    branch_address  VARCHAR,
    city_src_id     VARCHAR,
    opened_year     INT,
    branch_size_sqm NUMERIC,
    manager_src_id  VARCHAR,
    manager_name    VARCHAR,
    manager_email   VARCHAR,
    manager_gender  VARCHAR,
    manager_birth_date DATE,
    source_entity   VARCHAR,
    source_system   VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.branchid)
           u.branchid, u.branchname, u.branchaddress, u.cityid,
           NULLIF(u.branchopenedyear,'')::INT,
           NULLIF(u.branchsizesqm,'')::NUMERIC(12,2),
           u.branchmanagerid, u.branchmanagername, u.branchmanageremail,
           u.branchmanagergender,
           TO_DATE(NULLIF(u.branchmanagerbirthdate,''), 'MM/DD/YYYY'),
           u.source_entity, u.source_system
    FROM (
        SELECT branchid, branchname, branchaddress, cityid, branchopenedyear,
               branchsizesqm, branchmanagerid, branchmanagername, branchmanageremail,
               branchmanagergender, branchmanagerbirthdate,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(branchid),'') IS NOT NULL
        UNION ALL
        SELECT branchid, branchname, branchaddress, cityid, branchopenedyear,
               branchsizesqm, branchmanagerid, branchmanagername, branchmanageremail,
               branchmanagergender, branchmanagerbirthdate,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(branchid),'') IS NOT NULL
    ) u
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.ce_branches b WHERE b.branch_src_id = u.branchid
    )
    ORDER BY u.branchid;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_branches()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_city_sk BIGINT;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_new_branches() LOOP
        SELECT city_sk INTO v_city_sk
        FROM bl_3nf.ce_geography
        WHERE city_src_id = rec.city_src_id;

        INSERT INTO bl_3nf.ce_branches (
            branch_sk, branch_src_id, branch_name, branch_address, city_sk,
            opened_year, branch_size_sqm, manager_src_id, manager_name, manager_email,
            manager_gender, manager_birth_date, source_entity, source_system,
            insert_dt, update_dt
        )
        VALUES (
            nextval('bl_3nf.seq_ce_branches_sk'), rec.branch_src_id, rec.branch_name,
            rec.branch_address, v_city_sk, rec.opened_year, rec.branch_size_sqm,
            rec.manager_src_id, rec.manager_name, rec.manager_email, rec.manager_gender,
            rec.manager_birth_date, rec.source_entity, rec.source_system, NOW(), NOW()
        )
        ON CONFLICT (branch_src_id) DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_branches', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new branch rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_branches', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 8. CUSTOMERS  

CREATE OR REPLACE FUNCTION bl_cl.fn_stg_customers()
RETURNS TABLE (
    customer_src_id VARCHAR,
    customer_name   VARCHAR,
    customer_email  VARCHAR,
    gender          VARCHAR,
    customer_address VARCHAR,
    date_of_birth   DATE,
    source_entity   VARCHAR,
    source_system   VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.customerid)
           u.customerid, u.customername, u.customeremail, u.gender,
           u.customeraddress, u.dob, u.source_entity, u.source_system
    FROM (
        SELECT customerid, customername, customeremail, gender,
               'n.a.' AS customeraddress,
               TO_DATE(NULLIF(dateofbirth,''), 'MM/DD/YYYY') AS dob,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(customerid),'') IS NOT NULL
        UNION ALL
        SELECT customerid, customername, customeremail, customergender AS gender,
               customeraddress,
               TO_DATE(NULLIF(customerbirthdate,''), 'MM/DD/YYYY') AS dob,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(customerid),'') IS NOT NULL
    ) u
    ORDER BY u.customerid;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_customers_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_active RECORD;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_stg_customers() LOOP

        SELECT * INTO v_active
        FROM bl_3nf.ce_customers_scd
        WHERE customer_src_id = rec.customer_src_id
          AND is_active = 'Y';

        IF NOT FOUND THEN
            -- brand new customer
            INSERT INTO bl_3nf.ce_customers_scd (
                customer_sk, customer_src_id, customer_name, customer_email, gender,
                customer_address, date_of_birth, source_entity, source_system,
                insert_dt, update_dt, start_dt, end_dt, is_active
            )
            VALUES (
                nextval('bl_3nf.seq_ce_customers_sk'), rec.customer_src_id, rec.customer_name,
                rec.customer_email, rec.gender, rec.customer_address, rec.date_of_birth,
                rec.source_entity, rec.source_system, NOW(), NOW(),
                DATE '1990-01-01', DATE '9999-12-31', 'Y'
            );
            v_rows := v_rows + 1;

        ELSIF v_active.customer_name    IS DISTINCT FROM rec.customer_name
           OR v_active.customer_email   IS DISTINCT FROM rec.customer_email
           OR v_active.gender           IS DISTINCT FROM rec.gender
           OR v_active.customer_address IS DISTINCT FROM rec.customer_address
           OR v_active.date_of_birth    IS DISTINCT FROM rec.date_of_birth
        THEN
            UPDATE bl_3nf.ce_customers_scd
            SET end_dt = CURRENT_DATE - 1, is_active = 'N', update_dt = NOW()
            WHERE customer_sk = v_active.customer_sk;

            INSERT INTO bl_3nf.ce_customers_scd (
                customer_sk, customer_src_id, customer_name, customer_email, gender,
                customer_address, date_of_birth, source_entity, source_system,
                insert_dt, update_dt, start_dt, end_dt, is_active
            )
            VALUES (
                nextval('bl_3nf.seq_ce_customers_sk'), rec.customer_src_id, rec.customer_name,
                rec.customer_email, rec.gender, rec.customer_address, rec.date_of_birth,
                rec.source_entity, rec.source_system, NOW(), NOW(),
                CURRENT_DATE, DATE '9999-12-31', 'Y'
            );
            v_rows := v_rows + 1;
        END IF;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_customers_scd', v_rows, 'SUCCESS',
        'Loaded/versioned ' || v_rows || ' customer rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_customers_scd', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 9. ORDERS

CREATE OR REPLACE FUNCTION bl_cl.fn_new_orders()
RETURNS TABLE (
    order_src_id    VARCHAR,
    customer_src_id VARCHAR,
    employee_src_id VARCHAR,
    payment_src_id  VARCHAR,
    branch_src_id   VARCHAR,
    order_date      DATE,
    order_status    VARCHAR,
    order_type      VARCHAR,
    source_entity   VARCHAR,
    source_system   VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.orderid)
           u.orderid, u.customerid, u.employeeid, u.paymentid, u.branchid,
           TO_DATE(NULLIF(u.orderdate,''), 'MM/DD/YYYY'),
           u.orderstatus, u.ordertype, u.source_entity, u.source_system
    FROM (
        SELECT orderid, customerid, sellerid AS employeeid, paymentid, branchid,
               orderdate, orderstatus, ordertype,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(orderid),'') IS NOT NULL
        UNION ALL
        SELECT orderid, customerid, courierid AS employeeid, paymentid, branchid,
               orderdate, orderstatus, ordertype,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(orderid),'') IS NOT NULL
    ) u
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.ce_orders o WHERE o.order_src_id = u.orderid
    )
    ORDER BY u.orderid;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_orders()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_customer_sk BIGINT;
    v_employee_sk BIGINT;
    v_payment_sk  BIGINT;
    v_branch_sk   BIGINT;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_new_orders() LOOP

        SELECT customer_sk INTO v_customer_sk
        FROM bl_3nf.ce_customers_scd
        WHERE customer_src_id = rec.customer_src_id AND is_active = 'Y';

        SELECT employee_sk INTO v_employee_sk
        FROM bl_3nf.ce_employees
        WHERE employee_src_id = rec.employee_src_id;

        SELECT payment_sk INTO v_payment_sk
        FROM bl_3nf.ce_payments
        WHERE payment_src_id = rec.payment_src_id;

        SELECT branch_sk INTO v_branch_sk
        FROM bl_3nf.ce_branches
        WHERE branch_src_id = rec.branch_src_id;

        INSERT INTO bl_3nf.ce_orders (
            order_sk, order_src_id, customer_sk, employee_sk, payment_sk, branch_sk,
            order_date, order_status, order_type, source_entity, source_system,
            insert_dt, update_dt
        )
        VALUES (
            nextval('bl_3nf.seq_ce_orders_sk'), rec.order_src_id, v_customer_sk, v_employee_sk,
            v_payment_sk, v_branch_sk, rec.order_date, rec.order_status, rec.order_type,
            rec.source_entity, rec.source_system, NOW(), NOW()
        );
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_orders', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new order rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_orders', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

-- 10 ORDER ITEMS

CREATE OR REPLACE FUNCTION bl_cl.fn_new_order_items()
RETURNS TABLE (
    order_src_id       VARCHAR,
    product_src_id     VARCHAR,
    quantity           INT,
    unit_price_usd     NUMERIC,
    total_price_usd    NUMERIC,
    unit_price_local   NUMERIC,
    total_price_local  NUMERIC,
    source_entity      VARCHAR,
    source_system      VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.orderid, u.productid)
           u.orderid, u.productid,
           NULLIF(u.quantity,'')::INT,
           NULLIF(u.unitpriceinusd,'')::NUMERIC(5,2),
           NULLIF(u.totalamountusd,'')::NUMERIC(5,2),
           NULLIF(u.unitpriceinlocalcurrency,'')::NUMERIC(5,2),
           NULLIF(u.totalpriceinlocalcurrency,'')::NUMERIC(5,2),
           u.source_entity, u.source_system
    FROM (
        SELECT orderid, productid, quantity, unitpriceinusd, totalamountusd,
               unitpriceinlocalcurrency, totalpriceinlocalcurrency,
               'src_offline_sales' AS source_entity, 'offline_sales' AS source_system
        FROM sa_offline_sales.src_offline_sales
        WHERE NULLIF(TRIM(orderid),'') IS NOT NULL
        UNION ALL
        SELECT orderid, productid, quantity, unitpriceinusd,
               totalamountinusd AS totalamountusd,
               unitpriceinlocalcurrency, totalpriceinlocalcurrency,
               'src_online_sales' AS source_entity, 'online_sales' AS source_system
        FROM sa_online_sales.src_online_sales
        WHERE NULLIF(TRIM(orderid),'') IS NOT NULL
    ) u
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.ce_order_item oi
        JOIN bl_3nf.ce_orders o ON o.order_sk = oi.order_sk
        JOIN bl_3nf.ce_products p ON p.product_sk = oi.product_sk
        WHERE o.order_src_id = u.orderid AND p.product_src_id = u.productid
    )
    ORDER BY u.orderid, u.productid;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_order_item()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_order_sk   BIGINT;
    v_product_sk BIGINT;
    v_rows INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.fn_new_order_items() LOOP

        SELECT order_sk INTO v_order_sk
        FROM bl_3nf.ce_orders WHERE order_src_id = rec.order_src_id;

        SELECT product_sk INTO v_product_sk
        FROM bl_3nf.ce_products WHERE product_src_id = rec.product_src_id;

        CONTINUE WHEN v_order_sk IS NULL OR v_product_sk IS NULL;

        INSERT INTO bl_3nf.ce_order_item (
            order_item_sk, order_src_id, order_sk, product_sk, quantity,
            unit_price_usd, total_price_usd, unit_price_local, total_price_local,
            source_entity, source_system, insert_dt, update_dt
        )
        VALUES (
            nextval('bl_3nf.seq_ce_order_items_sk'), rec.order_src_id, v_order_sk, v_product_sk,
            rec.quantity, rec.unit_price_usd, rec.total_price_usd,
            rec.unit_price_local, rec.total_price_local,
            rec.source_entity, rec.source_system, NOW(), NOW()
        );
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('load_ce_order_item', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new order item rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_ce_order_item', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE bl_cl.load_all_3nf()
LANGUAGE plpgsql
AS $$
BEGIN
    CALL bl_cl.load_ce_geography();
    CALL bl_cl.load_ce_payments();
    CALL bl_cl.load_ce_suppliers();
    CALL bl_cl.load_ce_products();
    CALL bl_cl.load_ce_employees();
    CALL bl_cl.load_ce_branches();
    CALL bl_cl.load_ce_customers_scd();
    CALL bl_cl.load_ce_orders();
    CALL bl_cl.load_ce_order_item();
END;
$$;

