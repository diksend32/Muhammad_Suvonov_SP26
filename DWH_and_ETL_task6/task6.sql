-- 1.1 TASK 1: USE INHERITANCE

CREATE TABLE labs.SALES_INFO
(
id INTEGER,
category VARCHAR(1),
ischeck BOOLEAN,
eventdate DATE
);

-- Partition 2022
CREATE TABLE labs.sales_info_2022
(CHECK(
        eventdate >= DATE '2022-01-01'
        AND eventdate < DATE '2023-01-01'
    ))
INHERITS (labs.SALES_INFO);


--Partition 2023
CREATE TABLE labs.sales_info_2023
(CHECK( eventdate >= DATE '2023-01-01'
       AND eventdate < DATE '2024-01-01'
    ))
INHERITS (labs.SALES_INFO);


--Partition 2024
CREATE TABLE labs.sales_info_2024
(CHECK(eventdate >= DATE '2024-01-01'
       AND eventdate < DATE '2025-01-01'
    ))
INHERITS (labs.SALES_INFO);

--Partition 2025
CREATE TABLE labs.sales_info_2025
(CHECK(  eventdate >= DATE '2025-01-01'
        AND eventdate < DATE '2026-01-01'
		))
INHERITS (labs.SALES_INFO);

--Default Partition

CREATE TABLE labs.sales_info_other
(CHECK(
   eventdate >= DATE '2026-01-01' )
)
INHERITS (labs.SALES_INFO);


-- Create partition function for your tables.
CREATE OR REPLACE FUNCTION labs.partition_sales_info()
RETURNS TRIGGER
AS
$$
BEGIN

    IF NEW.eventdate >= '2022-01-01'::date
    AND NEW.eventdate < '2023-01-01'::date THEN

        INSERT INTO labs.sales_info_2022 VALUES (NEW.*);

    ELSIF NEW.eventdate >= '2023-01-01'::date
    AND NEW.eventdate < '2024-01-01'::date THEN

        INSERT INTO labs.sales_info_2023 VALUES (NEW.*);

    ELSIF NEW.eventdate >= '2024-01-01'::date
    AND NEW.eventdate < '2025-01-01'::date THEN

        INSERT INTO labs.sales_info_2024 VALUES (NEW.*);

    ELSIF NEW.eventdate >= '2025-01-01'::date
    AND NEW.eventdate < '2026-01-01'::date THEN

        INSERT INTO labs.sales_info_2025 VALUES (NEW.*);

    ELSIF NEW.eventdate >= '2026-01-01'::date THEN

        INSERT INTO labs.sales_info_other VALUES (NEW.*);

    ELSE
        RAISE EXCEPTION 'Out of range';
    END IF;

    RETURN NULL;

END;
$$
LANGUAGE plpgsql;

-- Create trigger for your function and tables.
CREATE TRIGGER partition_sales_info_trigger
BEFORE INSERT
ON labs.sales_info
FOR EACH ROW
EXECUTE FUNCTION labs.partition_sales_info();

--4. Generate test data and insert in SALES_INFO table:
INSERT INTO labs.sales_info(id,category,ischeck,eventdate)
SELECT
    id,
    ('{"A","B","C","D","E","F","G","H","I","J","K"}'::text[])[(random()*10)::int+1],
    (random()>0.5),
    (DATE '2022-01-01' + floor(random()*1460)::int)
FROM generate_series(1,10000000) id;

-- 5. Update some rows in SALES_INFO and set another eventdate.
UPDATE labs.sales_info
SET eventdate='2025-07-10'
WHERE id<=5000;


UPDATE labs.sales_info
SET category='A'
WHERE id BETWEEN 5001 AND 10000;

--6
CREATE TABLE labs.sales_info_simple
(
    id INTEGER,
    category VARCHAR(1),
    ischeck BOOLEAN,
    eventdate DATE
);


INSERT INTO labs.sales_info_simple
SELECT *
FROM labs.sales_info;

-- Compare plans

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info;


EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple;


EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info
WHERE eventdate BETWEEN '2024-01-01' AND '2024-12-31';



EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple
WHERE eventdate BETWEEN '2024-01-01' AND '2024-12-31';

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info
WHERE eventdate='2024-06-15';


EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple
WHERE eventdate='2024-06-15';


EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info;



EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_simple;


EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info
WHERE eventdate BETWEEN '2024-01-01' AND '2024-12-31';



EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_simple
WHERE eventdate BETWEEN '2024-01-01' AND '2024-12-31';


--7. Delete one of partition (the oldest one). Create some general table like sales_info_3000 with
--the same structure as sales_info and add it as new partition.

DROP TABLE labs.sales_info_2022;

CREATE TABLE labs.sales_info_3000
(CHECK
    (  eventdate >= '3000-01-01'::date
      AND eventdate < '3001-01-01'::date
    )
)
INHERITS (labs.sales_info);


SELECT COUNT(*) FROM labs.sales_info_2023;
SELECT COUNT(*) FROM labs.sales_info_2024;
SELECT COUNT(*) FROM labs.sales_info_2025;
SELECT COUNT(*) FROM labs.sales_info_other;



--1.2 TASK2: USE DECLARATIVE PARTITIONING

CREATE TABLE labs.sales_info_dp
(id INTEGER,
  category VARCHAR(1),
  ischeck BOOLEAN,
  eventdate DATE)
PARTITION BY RANGE (eventdate);

CREATE TABLE labs.sales_info_dp_2022
PARTITION OF labs.sales_info_dp
FOR VALUES FROM ('2022-01-01') TO ('2023-01-01')
PARTITION BY LIST(category);

CREATE TABLE labs.sales_info_dp_2022_a
PARTITION OF labs.sales_info_dp_2022
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE labs.sales_info_dp_2022_b
PARTITION OF labs.sales_info_dp_2022
FOR VALUES IN ('F','G','H','I','J','K');

CREATE TABLE labs.sales_info_dp_2022_other
PARTITION OF labs.sales_info_dp_2022
DEFAULT;


--2023 
CREATE TABLE labs.sales_info_dp_2023
PARTITION OF labs.sales_info_dp
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01')
PARTITION BY LIST(category);

CREATE TABLE labs.sales_info_dp_2023_a
PARTITION OF labs.sales_info_dp_2023
FOR VALUES IN ('A','B','C','D','E');


CREATE TABLE labs.sales_info_dp_2023_b
PARTITION OF labs.sales_info_dp_2023
FOR VALUES IN ('F','G','H','I','J','K');


CREATE TABLE labs.sales_info_dp_2023_other
PARTITION OF labs.sales_info_dp_2023
DEFAULT;


--2024

CREATE TABLE labs.sales_info_dp_2024
PARTITION OF labs.sales_info_dp
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01')
PARTITION BY LIST(category);


CREATE TABLE labs.sales_info_dp_2024_a
PARTITION OF labs.sales_info_dp_2024
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE labs.sales_info_dp_2024_b
PARTITION OF labs.sales_info_dp_2024
FOR VALUES IN ('F','G','H','I','J','K');

CREATE TABLE labs.sales_info_dp_2024_other
PARTITION OF labs.sales_info_dp_2024
DEFAULT;

-- 2025
CREATE TABLE labs.sales_info_dp_2025
PARTITION OF labs.sales_info_dp
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01')
PARTITION BY LIST(category);

CREATE TABLE labs.sales_info_dp_2025_a
PARTITION OF labs.sales_info_dp_2025
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE labs.sales_info_dp_2025_b
PARTITION OF labs.sales_info_dp_2025
FOR VALUES IN ('F','G','H','I','J','K');

CREATE TABLE labs.sales_info_dp_2025_other
PARTITION OF labs.sales_info_dp_2025
DEFAULT;

-- default

CREATE TABLE labs.sales_info_dp_other
PARTITION OF labs.sales_info_dp
FOR VALUES FROM ('2026-01-01') TO (MAXVALUE)
PARTITION BY LIST(category);

CREATE TABLE labs.sales_info_dp_other_a
PARTITION OF labs.sales_info_dp_other
FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE labs.sales_info_dp_other_b
PARTITION OF labs.sales_info_dp_other
FOR VALUES IN ('F','G','H','I','J','K');

CREATE TABLE labs.sales_info_dp_other_default
PARTITION OF labs.sales_info_dp_other
DEFAULT;


INSERT INTO labs.sales_info_dp
(id,
 category,
ischeck,
 eventdate
)
SELECT
    id,

    ('{"A","B","C","D","E","F","G","H","I","J","K"}'::text[])
    [(random()*10)::int+1],

    (random()>0.5),

    (
        DATE '2022-01-01'
        + floor(random()*1461)::int
    )

FROM generate_series(1,10000000) id;


UPDATE labs.sales_info_dp
SET category='A'
WHERE id BETWEEN 1 AND 1000;

UPDATE labs.sales_info_dp
SET category='K'
WHERE id BETWEEN 1001 AND 2000;


-- Comparison
EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_dp;




EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple;



EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_dp
WHERE eventdate
BETWEEN '2024-01-01'
AND '2024-12-31';

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple
WHERE eventdate
BETWEEN '2024-01-01'
AND '2024-12-31';

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_dp
WHERE eventdate='2024-06-15';

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple
WHERE eventdate='2024-06-15';

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_dp
WHERE category='A';

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple
WHERE category='A';

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_dp
WHERE category IN ('A','B','C');

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple
WHERE category IN ('A','B','C');

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_dp
WHERE category IN ('A','B','C')
AND eventdate='2024-06-15';

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple
WHERE category IN ('A','B','C')
AND eventdate='2024-06-15';


EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_dp;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_simple;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_dp
WHERE eventdate
BETWEEN '2024-01-01'
AND '2024-12-31';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_simple
WHERE eventdate
BETWEEN '2024-01-01'
AND '2024-12-31';

--2.1 TASK 3: USE PARALLEL QUERING

SET max_parallel_workers_per_gather = 4;

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info;

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_dp;

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple;

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info
ORDER BY eventdate;

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_dp
ORDER BY eventdate;

EXPLAIN ANALYZE
SELECT *
FROM labs.sales_info_simple
ORDER BY eventdate;


EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_dp;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_simple;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info
WHERE eventdate BETWEEN '2024-01-01' AND '2024-12-31';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_dp
WHERE eventdate BETWEEN '2024-01-01' AND '2024-12-31';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info_simple
WHERE eventdate BETWEEN '2024-01-01' AND '2024-12-31';

EXPLAIN ANALYZE
SELECT category,
COUNT(*)
FROM labs.sales_info
GROUP BY category;

EXPLAIN ANALYZE
SELECT category,
COUNT(*)
FROM labs.sales_info_dp
GROUP BY category;

EXPLAIN ANALYZE
SELECT category,
COUNT(*)
FROM labs.sales_info_simple
GROUP BY category;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM labs.sales_info s
JOIN labs.sales_info_dp d
ON s.id = d.id
WHERE s.eventdate = '2024-06-15';


CREATE INDEX idx_sales_info_dp_eventdate
ON labs.sales_info_dp(eventdate);

CREATE INDEX idx_sales_info_dp_category
ON labs.sales_info_dp(category);

CREATE INDEX idx_sales_info_dp_id
ON labs.sales_info_dp(id);