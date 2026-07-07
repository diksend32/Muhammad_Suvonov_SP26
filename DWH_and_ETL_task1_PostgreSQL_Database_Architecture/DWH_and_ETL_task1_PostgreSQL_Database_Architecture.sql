SELECT version();

CREATE DATABASE test_db;

SELECT
    d.oid,
    d.datname,
    d.datistemplate,
    d.datallowconn,
    t.spcname
FROM pg_database d
JOIN pg_tablespace t
ON d.dattablespace = t.oid;

CREATE TABLESPACE mytablespace
LOCATION 'C:/PostgreSQL/tblspc_test';

SELECT *
FROM pg_tablespace;

ALTER DATABASE test_db
SET TABLESPACE mytablespace;

SELECT
    d.oid,
    d.datname,
    d.datistemplate,
    d.datallowconn,
    t.spcname
FROM pg_database d
JOIN pg_tablespace t
ON d.dattablespace = t.oid;

CREATE SCHEMA labs;

CREATE TABLE labs.person
(
    id INTEGER NOT NULL,
    name VARCHAR(15)
);

SELECT
    schemaname,
    tablename
FROM pg_tables
WHERE tablename='person';

INSERT INTO labs.person VALUES (1,'Bob');
INSERT INTO labs.person VALUES (2,'Alice');
INSERT INTO labs.person VALUES (3,'Robert');

SELECT *
FROM labs.person;

SHOW search_path;

SET search_path TO labs;

SHOW search_path;

INSERT INTO person VALUES (4,'John');
INSERT INTO person VALUES (5,'Sarah');

SELECT *
FROM person;


CREATE EXTENSION IF NOT EXISTS pageinspect;

SELECT
    id,
    name,
    ctid,
    xmin,
    xmax
FROM person;

SELECT
    t_xmin,
    t_xmax,
    t_ctid,
    tuple_data_split(
        'labs.person'::regclass,
        t_data,
        t_infomask,
        t_infomask2,
        t_bits
    )
FROM heap_page_items(
    get_raw_page('labs.person',0)
);

BEGIN;

INSERT INTO person VALUES (6,'John');

COMMIT;

SELECT
    id,
    name,
    ctid,
    xmin,
    xmax
FROM person;

SELECT
    t_xmin,
    t_xmax,
    t_ctid,
    tuple_data_split(
        'labs.person'::regclass,
        t_data,
        t_infomask,
        t_infomask2,
        t_bits
    )
FROM heap_page_items(
    get_raw_page('labs.person',0)
);

BEGIN;

UPDATE person
SET name='Alex'
WHERE id=2;

COMMIT;

SELECT
    id,
    name,
    ctid,
    xmin,
    xmax
FROM person;

SELECT
    t_xmin,
    t_xmax,
    t_ctid,
    tuple_data_split(
        'labs.person'::regclass,
        t_data,
        t_infomask,
        t_infomask2,
        t_bits
    )
FROM heap_page_items(
    get_raw_page('labs.person',0)
);

BEGIN;

DELETE
FROM person
WHERE id=3;

COMMIT;

SELECT
    id,
    name,
    ctid,
    xmin,
    xmax
FROM person;

SELECT
    t_xmin,
    t_xmax,
    t_ctid,
    tuple_data_split(
        'labs.person'::regclass,
        t_data,
        t_infomask,
        t_infomask2,
        t_bits
    )
FROM heap_page_items(
    get_raw_page('labs.person',0)
);


BEGIN;

INSERT INTO person VALUES (999,'Test');

COMMIT;

SELECT
    id,
    name,
    ctid,
    xmin,
    xmax
FROM person;

SELECT
    t_xmin,
    t_xmax,
    t_ctid,
    tuple_data_split(
        'labs.person'::regclass,
        t_data,
        t_infomask,
        t_infomask2,
        t_bits
    )
FROM heap_page_items(
        get_raw_page('labs.person',0)
);


BEGIN;

DELETE
FROM person
WHERE id=999;

COMMIT;

SELECT
    id,
    name,
    ctid,
    xmin,
    xmax
FROM person;

SELECT
    t_xmin,
    t_xmax,
    t_ctid,
    tuple_data_split(
        'labs.person'::regclass,
        t_data,
        t_infomask,
        t_infomask2,
        t_bits
    )
FROM heap_page_items(
        get_raw_page('labs.person',0)
); 


VACUUM labs.person;

SELECT
    t_xmin,
    t_xmax,
    t_ctid,
    tuple_data_split(
        'labs.person'::regclass,
        t_data,
        t_infomask,
        t_infomask2,
        t_bits
    )
FROM heap_page_items(
    get_raw_page('labs.person',0)
);


INSERT INTO person VALUES (7,'Sarah');

SELECT
    id,
    name,
    ctid,
    xmin,
    xmax
FROM person;

VACUUM FULL labs.person;

SELECT
    t_xmin,
    t_xmax,
    t_ctid,
    tuple_data_split(
        'labs.person'::regclass,
        t_data,
        t_infomask,
        t_infomask2,
        t_bits
    )
FROM heap_page_items(
    get_raw_page('labs.person',0)
);

SELECT *
FROM person;