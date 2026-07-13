-- 1. JOIN METHODS

-- 1.1. TASK 1: NESTED LOOP JOIN

CREATE TABLE labs.test_joins_a
(
id1 int,
id2 int
);
CREATE TABLE labs.test_joins_b
(
id1 int,
id2 int
);


INSERT INTO labs.test_joins_a values(generate_series(1,10000),3);
INSERT INTO labs.test_joins_b values(generate_series(1,10000),3);


EXPLAIN
SELECT * FROM labs.test_joins_a a, labs.test_joins_b b
WHERE a.id1 > b.id1
;

EXPLAIN
SELECT *
FROM labs.test_joins_a a
CROSS JOIN labs.test_joins_b b;


-- 1.2 TASK 2: HASH JOIN

--1. Rewrite SELECT to instruct the planner to use HASH JOIN method:
SET enable_nestloop = off;
SET enable_mergejoin = off;

EXPLAIN
SELECT * FROM labs.test_joins_a a, labs.test_joins_b b
WHERE a.id1 = b.id1;



--2. Create query with SEMI JOIN between tables to get HASH SEMI JOIN in the plan.

EXPLAIN
SELECT	*
FROM	labs.test_joins_a a
WHERE EXISTS (
	SELECT 1
	FROM	 labs.test_joins_b b
	WHERE  a.id1 = b.id1
)
;


SET enable_hashjoin  = off;

EXPLAIN
SELECT	*
FROM	labs.test_joins_a a
WHERE EXISTS (
	SELECT 1
	FROM	 labs.test_joins_b b
	WHERE  a.id1 = b.id1
)
;

SET enable_hashjoin  = on;

--1.3 TASK 3: MERGE JOIN
SET enable_mergejoin = on;

SET enable_hashjoin = off;
SET enable_nestloop = off;


EXPLAIN
SELECT *
FROM labs.test_joins_a a
 JOIN labs.test_joins_b b
 ON a.id1 = b.id1;


SET enable_mergejoin = off;

EXPLAIN
SELECT *
FROM labs.test_joins_a a
 JOIN labs.test_joins_b b
 ON a.id1 = b.id1;

 SET enable_mergejoin = on;

-- 2. JOIN ORDER AND LATERAL JOIN

-- 2.1 TASK 4: CHANGING JOIN ORDER

CREATE TABLE labs.test_joins_c
(
id1 int,
id2 int
);

INSERT INTO labs.test_joins_c
values(generate_series(1,1000000),(random()*10)::int);

EXPLAIN
SELECT c.id2
FROM labs.test_joins_b b
JOIN labs.test_joins_a a on (b.id1 = a.id1)
LEFT JOIN labs.test_joins_c c on (c.id1 = b.id1);


--3
SET join_collapse_limit = 1;

EXPLAIN
SELECT c.id2
FROM labs.test_joins_b b
JOIN labs.test_joins_a a on (b.id1 = a.id1)
LEFT JOIN labs.test_joins_c c on (c.id1 = b.id1);

SET join_collapse_limit = 8;



--2.2 TASK 5: LATERAL JOIN
 
CREATE TABLE labs.orders AS
SELECT id AS order_id,
(id * 10 * random()*10)::int AS order_cost,
'order number ' || id AS order_num
FROM generate_series(1, 1000) AS id;

CREATE TABLE labs.stores (
store_id int,
store_name text,
max_order_cost int
);


INSERT INTO labs.stores VALUES
(1, 'grossery shop', '800'),
(2, 'bakery', '100'),
(3, 'manufactured goods', '3000')
;

--2 Create a query to find TOP 10 of orders by it cost for each store. 
SELECT
    s.store_id,
    s.store_name,
    o.order_id,
    o.order_num,
    o.order_cost
FROM labs.stores s
CROSS JOIN LATERAL (
SELECT *
FROM labs.orders
WHERE order_cost <= s.max_order_cost
ORDER BY order_cost DESC
LIMIT 10    
) o
ORDER BY s.store_id, o.order_cost DESC;

-- 3. CTES
--3.1 TASK 6: RECURSIVE CTE
SELECT * FROM labs.emp

WITH RECURSIVE rec_emp AS(
SELECT 
		empno, 
		mgr, 
		ename,
		job, 
		1 AS lvl
FROM labs.emp
WHERE mgr IS NULL

UNION ALL

SELECT
		e.empno,
		e.mgr,
		e.ename,
		e.job,
		r.lvl+1
FROM labs.emp e
JOIN rec_emp r
ON e.mgr = r.empno
)

SELECT  *
FROM 	rec_emp
ORDER BY  lvl;


-- 3.2 TASK 7: CHANGING DATA CTE

CREATE TABLE labs.order_log
(
log_id integer primary key generated always as identity,
order_id integer,
order_cost integer,
order_num text,
action_type varchar(1) CHECK (action_type IN ('U','D')),
log_date TIMESTAMPTZ DEFAULT Now()
);

--2. Update all rows for ORDER table:
WITH updated_rows AS (
    UPDATE labs.orders
    SET order_cost = order_cost / 2
    WHERE order_cost BETWEEN 100 AND 1000
    RETURNING order_id, order_cost, order_num
)
INSERT INTO labs.order_log
(order_id, order_cost, order_num, action_type)
SELECT
    order_id,
    order_cost,
    order_num,
    'U'
FROM updated_rows;


WITH deleted_rows AS (
    DELETE FROM labs.orders
    WHERE order_cost < 50
    RETURNING order_id, order_cost, order_num
)
INSERT INTO labs.order_log
(order_id, order_cost, order_num, action_type)
SELECT
    order_id,
    order_cost,
    order_num,
    'D'
FROM deleted_rows;