-- TASK 2
-- 1. Create table ‘table_to_delete’ and fill it with the following query:
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;


-- 2. Lookup how much space this table consumes with the following query:  I did not wrote this query again, just reused it.
SELECT *, pg_size_pretty(total_bytes) AS total,
             pg_size_pretty(index_bytes) AS index,
             pg_size_pretty(toast_bytes) AS toast,
             pg_size_pretty(table_bytes) AS table
FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
  FROM (
    SELECT c.oid,nspname AS table_schema,
           relname AS table_name,
           c.reltuples AS row_estimate,
           pg_total_relation_size(c.oid) AS total_bytes,
           pg_indexes_size(c.oid) AS index_bytes,
           pg_total_relation_size(reltoastrelid) AS toast_bytes
    FROM pg_class c
    LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE relkind = 'r'
  ) a
) a
WHERE table_name LIKE '%table_to_delete%';

-- 3. Issue the following DELETE operation on ‘table_to_delete’:

DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0;

-- a) Note how much time it takes to perform this DELETE statement; -->  Query returned successfully in 10 secs 533 msec.

-- b) Lookup how much space this table consumes after previous DELETE:
-- Before and after deleting  table space consumption is the same:

-- BEFORE:
-- table: 575 MB,

-- AFTER:
-- table: 575 MB,


-- DELETE does not free disk space

--      c) Perform the following command (if you're using DBeaver, press Ctrl+Shift+O to observe server output (VACUUM 
-- results)): VACUUM FULL VERBOSE table_to_delete;
VACUUM FULL VERBOSE table_to_delete;

-- d) Check space consumption of the table once again and make conclusions;

-- AFTER VACUUM: table: 383 MB. With VACUUM the space consumption reduced 200 mb


-- e) Recreate ‘table_to_delete’ table;
DROP TABLE public.table_to_delete;

CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;

TRUNCATE table_to_delete;  -- AFTER TRUNCATE table: 0


-- CONCLUSION
-- DELETE do not reduce free the space, because even we won't see deleted rows, they will be stored as died rows
-- With VACUUM we can fully get rid of those died rows
-- TRUNCATE instantly delete full table without scanning which makes it very fast
-- DELETE and TRUNCATE can be rolled back inside of transaction while VACUUM not
