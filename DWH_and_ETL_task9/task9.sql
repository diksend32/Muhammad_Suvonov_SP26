GRANT USAGE ON SCHEMA bl_3nf TO CURRENT_USER;
GRANT USAGE ON SCHEMA bl_dm  TO CURRENT_USER;
GRANT USAGE ON SCHEMA bl_cl  TO CURRENT_USER;

CREATE TABLE IF NOT EXISTS bl_dm.fct_order_items_dd (
    event_dt              DATE   NOT NULL,
    product_surr_id       BIGINT NOT NULL,
    customer_surr_id      BIGINT NOT NULL,
    employee_surr_id      BIGINT NOT NULL,
    payment_surr_id       BIGINT NOT NULL,
    branch_surr_id        BIGINT NOT NULL,
    order_src_id          VARCHAR(50) NOT NULL,
    product_src_id        VARCHAR(50) NOT NULL,
    fct_quantity          INT,
    fct_unit_price_usd    NUMERIC(10,2),
    fct_total_price_usd   NUMERIC(10,2),
    fct_unit_price_local  NUMERIC(10,2),
    fct_total_price_local NUMERIC(10,2),
    insert_dt             TIMESTAMP NOT NULL,
    update_dt             TIMESTAMP NOT NULL,

    CONSTRAINT uq_fct_order_items_dd UNIQUE (event_dt, order_src_id, product_src_id)
) PARTITION BY RANGE (event_dt);

CREATE TABLE IF NOT EXISTS bl_dm.fct_order_items_dd_default
    PARTITION OF bl_dm.fct_order_items_dd DEFAULT;

CREATE OR REPLACE PROCEDURE bl_cl.load_fct_order_items_dd(
    p_month DATE DEFAULT date_trunc('month', CURRENT_DATE)::date
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start     DATE := date_trunc('month', p_month)::date;
    v_end       DATE := (v_start + INTERVAL '1 month')::date;
    v_partition VARCHAR := 'fct_order_items_dd_' || to_char(v_start, 'YYYYMM');
    v_table_exists BOOLEAN;
    v_attached     BOOLEAN;
    v_sql       TEXT;
    v_rows      INT := 0;
BEGIN

    SELECT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'bl_dm' AND c.relname = v_partition
    ) INTO v_table_exists;

    IF NOT v_table_exists THEN
        EXECUTE format(
            'CREATE TABLE bl_dm.%I (LIKE bl_dm.fct_order_items_dd INCLUDING ALL)',
            v_partition
        );
    END IF;

    EXECUTE format($f$
        INSERT INTO bl_dm.%I (
            event_dt, product_surr_id, customer_surr_id, employee_surr_id,
            payment_surr_id, branch_surr_id, order_src_id, product_src_id,
            fct_quantity, fct_unit_price_usd, fct_total_price_usd,
            fct_unit_price_local, fct_total_price_local, insert_dt, update_dt
        )
        SELECT
            o.order_date, dp.product_surr_id, dc.customer_surr_id, de.employee_surr_id,
            dpay.payment_surr_id, dbr.branch_surr_id, o.order_src_id, p.product_src_id,
            oi.quantity, oi.unit_price_usd, oi.total_price_usd,
            oi.unit_price_local, oi.total_price_local, NOW(), NOW()
        FROM bl_3nf.ce_order_item oi
        JOIN bl_3nf.ce_orders   o   ON o.order_sk    = oi.order_sk
        JOIN bl_3nf.ce_products p   ON p.product_sk  = oi.product_sk
        LEFT JOIN bl_3nf.ce_customers_scd c ON c.customer_sk = o.customer_sk
        LEFT JOIN bl_3nf.ce_employees     e ON e.employee_sk = o.employee_sk
        LEFT JOIN bl_3nf.ce_payments    pay ON pay.payment_sk = o.payment_sk
        LEFT JOIN bl_3nf.ce_branches     br ON br.branch_sk   = o.branch_sk
        LEFT JOIN bl_dm.dim_products         dp   ON dp.product_src_id  = p.product_src_id
        LEFT JOIN bl_dm.dim_customers_scd    dc   ON dc.customer_src_id = c.customer_src_id AND dc.is_active = 'Y'
        LEFT JOIN bl_dm.dim_employees        de   ON de.employee_src_id = e.employee_src_id
        LEFT JOIN bl_dm.dim_payments         dpay ON dpay.payment_src_id = pay.payment_src_id
        LEFT JOIN bl_dm.dim_branches         dbr  ON dbr.branch_src_id   = br.branch_src_id
        WHERE o.order_date >= %L AND o.order_date < %L
        ON CONFLICT (event_dt, order_src_id, product_src_id) DO UPDATE
        SET fct_quantity          = EXCLUDED.fct_quantity,
            fct_unit_price_usd    = EXCLUDED.fct_unit_price_usd,
            fct_total_price_usd   = EXCLUDED.fct_total_price_usd,
            fct_unit_price_local  = EXCLUDED.fct_unit_price_local,
            fct_total_price_local = EXCLUDED.fct_total_price_local,
            update_dt             = NOW()
        WHERE (fct_quantity, fct_unit_price_usd, fct_total_price_usd,
               fct_unit_price_local, fct_total_price_local)
              IS DISTINCT FROM
              (EXCLUDED.fct_quantity, EXCLUDED.fct_unit_price_usd, EXCLUDED.fct_total_price_usd,
               EXCLUDED.fct_unit_price_local, EXCLUDED.fct_total_price_local);
    $f$, v_partition, v_start, v_end);

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    SELECT EXISTS (
        SELECT 1
        FROM pg_inherits i
        JOIN pg_class child  ON child.oid  = i.inhrelid
        JOIN pg_class parent ON parent.oid = i.inhparent
        WHERE parent.relname = 'fct_order_items_dd' AND child.relname = v_partition
    ) INTO v_attached;

    IF NOT v_attached THEN
        EXECUTE format(
            'ALTER TABLE bl_dm.fct_order_items_dd ATTACH PARTITION bl_dm.%I FOR VALUES FROM (%L) TO (%L)',
            v_partition, v_start, v_end
        );
    END IF;

    CALL bl_cl.sp_write_log('load_fct_order_items_dd', v_rows, 'SUCCESS',
        'Upserted ' || v_rows || ' rows into partition ' || v_partition);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('load_fct_order_items_dd', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.detach_old_fct_order_items_partitions(
    p_keep_months INT DEFAULT 3
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff DATE := date_trunc('month', CURRENT_DATE)::date - (p_keep_months || ' months')::interval;
    rec RECORD;
    v_rows INT := 0;
BEGIN
    FOR rec IN
        SELECT child.relname
        FROM pg_inherits i
        JOIN pg_class child  ON child.oid  = i.inhrelid
        JOIN pg_class parent ON parent.oid = i.inhparent
        WHERE parent.relname = 'fct_order_items_dd'
          AND child.relname ~ '^fct_order_items_dd_[0-9]{6}$'
          AND to_date(substring(child.relname FROM '[0-9]{6}$'), 'YYYYMM') < v_cutoff
    LOOP
        EXECUTE format('ALTER TABLE bl_dm.fct_order_items_dd DETACH PARTITION bl_dm.%I', rec.relname);
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.sp_write_log('detach_old_fct_order_items_partitions', v_rows, 'SUCCESS',
        'Detached ' || v_rows || ' partition(s) older than ' || p_keep_months || ' months');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.sp_write_log('detach_old_fct_order_items_partitions', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.refresh_fct_order_items_dd(p_keep_months INT DEFAULT 3)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
BEGIN

    CALL bl_cl.load_ce_order_item();

    FOR i IN REVERSE (p_keep_months - 1)..0 LOOP
        CALL bl_cl.load_fct_order_items_dd(
            (date_trunc('month', CURRENT_DATE) - (i || ' months')::interval)::date
        );
    END LOOP;

    CALL bl_cl.detach_old_fct_order_items_partitions(p_keep_months);
END;
$$;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_dm TO CURRENT_USER;