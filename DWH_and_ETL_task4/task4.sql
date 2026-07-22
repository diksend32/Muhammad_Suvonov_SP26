-- 1. READING THE PLAN

-- 1.1 TASK 1 – TABLE WITHOUT INDEX

-- B-tree index

CREATE TABLE IF NOT EXISTS labs.test_index_plan (
num float NOT NULL,
load_date timestamptz NOT NULL
);


INSERT INTO labs.test_index_plan(num, load_date)
SELECT random(), x
FROM generate_series('2017-01-01 0:00'::timestamptz,
'2021-12-31 23:59:59'::timestamptz, '10 seconds'::interval) x;


SET max_parallel_workers_per_gather = 0;


EXPLAIN
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00' AND '2021-10-31
11:59:59'
ORDER BY 1;

EXPLAIN ANALYZE
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00' AND '2021-10-31
11:59:59'
ORDER BY 1;


EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00' AND '2021-10-31
11:59:59'
ORDER BY 1;



-- 1.2 TASK 2 – ADDING INDEX
--Create B-Tree Index 

CREATE INDEX  btree_index
ON  labs.test_index_plan(load_date);

SET max_parallel_workers_per_gather = 0;


EXPLAIN
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00' AND '2021-10-31
11:59:59'
ORDER BY 1;




EXPLAIN ANALYZE
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00' AND '2021-10-31
11:59:59'
ORDER BY 1;


EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00' AND '2021-10-31
11:59:59'
ORDER BY 1;


DROP INDEX  labs.btree_index;

-- BRIN index


CREATE INDEX brin_index
ON labs.test_index_plan
USING BRIN (load_date);


SET max_parallel_workers_per_gather = 0;


EXPLAIN
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00'
                    AND '2021-10-31 11:59:59'
ORDER BY 1;


EXPLAIN ANALYZE
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00'
                    AND '2021-10-31 11:59:59'
ORDER BY 1;



EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM labs.test_index_plan
WHERE load_date BETWEEN '2021-09-01 0:00'
                    AND '2021-10-31 11:59:59'
ORDER BY 1;


--2. ADDING DATA WITH INSERT AND COPY
--2.1 TASK 3 BULK INSERT

CREATE TABLE IF NOT EXISTS labs.test_inserts (
num float NOT NULL,
load_date timestamptz NOT NULL
);

CREATE INDEX btree_index
ON labs.test_inserts(load_date);


INSERT INTO labs.test_inserts
SELECT num, load_date
FROM labs.test_index_plan;

CREATE TABLE IF NOT EXISTS labs.emp (
empno NUMERIC(4) NOT NULL CONSTRAINT emp_pk PRIMARY KEY,
ename VARCHAR(10) UNIQUE,
job VARCHAR(9),
mgr NUMERIC(4),
hiredate DATE
);



INSERT INTO labs.emp (empno, ename, job, mgr, hiredate)
VALUES
(1, 'SMITH',  'CLERK',     13, '1980-12-17'),
(2, 'ALLEN',  'SALESMAN',   6, '1981-02-20'),
(3, 'WARD',   'SALESMAN',   6, '1981-02-22'),
(4, 'JONES',  'MANAGER',    9, '1981-04-02'),
(5, 'MARTIN', 'SALESMAN',   6, '1981-09-28'),
(6, 'BLAKE',  'MANAGER',    9, '1981-05-01'),
(7, 'CLARK',  'MANAGER',    9, '1981-06-09'),
(8, 'SCOTT',  'ANALYST',    4, '1987-04-19'),
(9, 'KING',   'PRESIDENT', NULL, '1981-11-17'),
(10,'TURNER', 'SALESMAN',   6, '1981-09-08'),
(11,'ADAMS',  'CLERK',      8, '1987-05-23'),
(12,'JAMES',  'CLERK',      6, '1981-12-03'),
(13,'FORD',   'ANALYST',    4, '1981-12-03'),
(14,'MILLER', 'CLERK',      7, '1982-01-23');


-- 2.2 TASK 4 COPY COMMAND

COPY labs.test_index_plan TO
'C:\epam\dwh\dwh2\DWH_and_ETL_task4\test_index_plan.csv' DELIMITER ',' CSV HEADER;


COPY labs.test_index_plan
TO 'C:\epam\dwh\dwh2\DWH_and_ETL_task4\test_index_plan.csv'
WITH (
    FORMAT CSV,
    HEADER,
    DELIMITER ',',
    FORCE_QUOTE (load_date)
);

COPY (
    SELECT *
    FROM labs.test_index_plan
    WHERE load_date BETWEEN
          '2021-09-01 00:00:00'
      AND '2021-09-01 11:59:59'
)
TO 'C:\epam\dwh\dwh2\DWH_and_ETL_task4\test_index_plan_short.csv'
WITH (
    FORMAT CSV,
    HEADER,
    DELIMITER ','
);


CREATE TABLE labs.test_copy (
    num float NOT NULL,
    load_date timestamptz NOT NULL
);

CREATE INDEX idx_test_copy_load_date
ON labs.test_copy (load_date);


COPY labs.test_copy
FROM 'C:\epam\dwh\dwh2\DWH_and_ETL_task4\test_index_plan.csv'
WITH (
    FORMAT CSV,
    HEADER,
    DELIMITER ','
);


SELECT *
FROM labs.test_copy
LIMIT 10;


--2.3 TASK 5 UPSERT

INSERT INTO labs.emp (empno, ename, job, mgr, hiredate)
VALUES
(1, 'SMITH', 'MANAGER', 13, '2021-12-01'),
(14, 'KELLY', 'CLERK', 1, '2021-12-01'),
(15, 'HANNAH', 'CLERK', 1, '2021-12-01'),
(11, 'ADAMS', 'SALESMAN', 8, '2021-12-01'),
(4, 'JONES', 'ANALIST', 9, '2021-12-01')
ON CONFLICT (empno)
DO UPDATE
SET
    ename = EXCLUDED.ename,
    job = EXCLUDED.job,
    mgr = EXCLUDED.mgr,
    hiredate = EXCLUDED.hiredate;

SELECT * 
FROM labs.emp
