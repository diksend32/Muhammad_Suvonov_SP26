-- I created each table in specific ordred to avoid mistake finding foreign keys 

CREATE DATABASE  subway;

CREATE SCHEMA IF NOT EXISTS subway_schema;

-- I used BIGSERIAL to avoid writing id which was INTEGER in the diogram
CREATE TABLE IF NOT EXISTS  subway_schema.metro_lines(
line_id		BIGSERIAL PRIMARY KEY,
line_name   VARCHAR(50) NOT NULL UNIQUE,
status 	VARCHAR(50) NOT NULL  CHECK (status IN ('active', 'under construction')),
opened_year INT CHECK (opened_year >= 2000)
);

CREATE TABLE IF NOT EXISTS subway_schema.stations(
station_id BIGSERIAL PRIMARY KEY,
station_name VARCHAR(50) NOT NULL UNIQUE,
opened_yaer INT CHECK (opened_yaer >= 2000)
);

-- bridge table for establishing many to many relationship between metro_lines and stations

-- Added composite key to avoid duplicate rows.
-- This table created after metro_lines and line_stations. Otherwise there will be problems with referencing keys.

CREATE TABLE IF NOT EXISTS subway_schema.line_stations(
line_id BIGINT REFERENCES subway_schema.metro_lines(line_id),
station_id BIGINT REFERENCES subway_schema.stations(station_id),
PRIMARY KEY (line_id, station_id)
);
-- this table created after stations because employees table has station_id which referencing to the stations.
CREATE TABLE IF NOT EXISTS subway_schema.employees(
employee_id BIGSERIAL PRIMARY KEY,
employee_name VARCHAR(50) NOT NULL,
station_id BIGINT REFERENCES subway_schema.stations(station_id)
);

-- this table created after metro_lines because trains table has line_id which referencing to the metro_lines.
CREATE TABLE IF NOT EXISTS subway_schema.trains(
train_id BIGSERIAL PRIMARY KEY,
line_id BIGINT REFERENCES subway_schema.metro_lines(line_id),
train_name VARCHAR(50) NOT NULL UNIQUE
);

-- this table created after trains because trips table has train_id which referencing to the trains.
CREATE TABLE IF NOT EXISTS subway_schema.trips(
trip_id BIGSERIAL PRIMARY KEY,
trip_name VARCHAR(50) NOT NULL UNIQUE,
train_id BIGINT REFERENCES subway_schema.trains(train_id)
);

-- price cannot be NEGATIVE so I used check. I added columns purchased at(time of ticket purchased), duration and valid_until 
-- to maintain validity period better and avoiding hardcoding it every time when new row is entered.
-- valid_until is GENERATED ALWAYS AS (purchased_at + duration) STORED
-- This ensures valid_until is always calculated correctly from purchase time + duration
-- If we stored it manually, someone could INSERT inconsistent values like:
-- purchased_at = '2024-01-01 10:00', duration = '30 minutes', valid_until = '2025-12-31'
-- With GENERATED, the calculation is enforced by the database
-- We can't insert or update valid_until directly, preventing human error

 -- DECIMAL not FLOAT because FLOAT uses binary approximation, so 2.50 might be stored as 2.4999999 -- DECIMAL stores exact 
 --values, so 2.50 is always exactly 2.50.
 --  CHECK(price > 0) is used to ensure valid price. Without it someone can  enter negative price which is invalid
CREATE TABLE IF NOT EXISTS subway_schema.tickets(
ticket_id BIGSERIAL PRIMARY KEY,
price DECIMAL(10,2) UNIQUE CHECK(price > 0),
purchased_at TIMESTAMP NOT NULL DEFAULT NOW(),
duration INTERVAL NOT NULL DEFAULT '30 minutes',
valid_until TIMESTAMP GENERATED ALWAYS AS (purchased_at + duration) STORED
);

-- this table created after tickets because ticket_price_history table has ticket_id which referencing to the tickets.
CREATE TABLE IF NOT EXISTS subway_schema.ticket_price_history(
change_id BIGSERIAL PRIMARY KEY,
ticket_id BIGINT REFERENCES subway_schema.tickets(ticket_id),
ticket_price_at_given_date DECIMAL(10,2) NOT NULL CHECK(ticket_price_at_given_date > 0),
update_date TIMESTAMP NOT NULL DEFAULT NOW()
);

-- this table created after tickets because passengers table has ticket_id which referencing to the ticket.
CREATE TABLE IF NOT EXISTS subway_schema.passengers(
passenger_id BIGSERIAL PRIMARY KEY,
passenger_name VARCHAR(50),
ticket_id BIGINT REFERENCES subway_schema.tickets(ticket_id)
);

-- this is bridge table between trips and passengers tables, so I created it after them to ensure correct referencing
CREATE TABLE IF NOT EXISTS subway_schema.trip_passengers(
trip_id BIGINT REFERENCES subway_schema.trips(trip_id),
passenger_id INT REFERENCES subway_schema.passengers(passenger_id),
PRIMARY KEY(trip_id, passenger_id)
);

CREATE TABLE IF NOT EXISTS subway_schema.schedules(
schedule_id BIGSERIAL PRIMARY KEY,
station_id BIGINT REFERENCES subway_schema.stations(station_id),
train_id BIGINT REFERENCES subway_schema.trains(train_id),
arrival_time TIMESTAMP,
departure_time TIMESTAMP,
UNIQUE(station_id, train_id, arrival_time, departure_time)  -- one train cannot be in the same station and the same time multiple times
);

CREATE TABLE IF NOT EXISTS subway_schema.maintenance_records(
record_id BIGSERIAL PRIMARY KEY,
train_id BIGINT REFERENCES subway_schema.trains(train_id),
description VARCHAR(50) NOT NULL
);


-- adding values
INSERT INTO subway_schema.metro_lines (line_name, status, opened_year) VALUES
('Red Line', 'active', 2005),
('Blue Line', 'under construction', 2023)
ON CONFLICT (line_name) DO NOTHING ;

INSERT INTO subway_schema.stations (station_name, opened_yaer) VALUES
('Central Station', 2005),
('North Station', 2010)
ON CONFLICT (station_name) DO NOTHING;

INSERT INTO subway_schema.line_stations (line_id, station_id) 
SELECT ml.line_id, s.station_id
FROM 
(VALUES
('Red Line', 'Central Station'),
('Blue Line', 'North Station')) AS v(line_name, station_name)
INNER JOIN subway_schema.metro_lines ml ON ml.line_name = v.line_name
INNER JOIN subway_schema.stations s ON s.station_name = v.station_name
ON CONFLICT (line_id, station_id) DO NOTHING;

-- ON CONFLICT (employee_name) is not used because names are not unique.
-- Uniqueness is enforced by the ID column, which is a surrogate key.
INSERT INTO subway_schema.employees (employee_name, station_id) 
SELECT	e.employee_name, s.station_id
FROM (VALUES
('Antony Joshua', 'Central Station'),
('Said Karimov', 'North Station'))  AS e(employee_name, station_name)
INNER JOIN subway_schema.stations s ON e.station_name = s.station_name 
;

INSERT INTO subway_schema.trains (line_id, train_name) 
SELECT	ml.line_id, t.train_name
FROM (VALUES
('Red Line', 'Sharq'),
('Blue Line', 'Nasaf')
) AS t(line_name, train_name)
INNER JOIN subway_schema.metro_lines ml ON ml.line_name = t.line_name
ON CONFLICT (train_name) DO NOTHING;

INSERT INTO subway_schema.trips (trip_name, train_id) 
SELECT	trp.trip_name, trn.train_id
FROM (VALUES
('Morning Trip', 'Sharq'),
('Evening Trip', 'Nasaf')) as trp (trip_name, train_name)
INNER JOIN subway_schema.trains trn ON trn.train_name = trp.train_name
ON CONFLICT (trip_name) DO NOTHING;

INSERT INTO subway_schema.tickets (price) VALUES
(2.50),
(3.00)
ON CONFLICT (price) DO NOTHING;

-- here also we do not need ON CONFLICT.. since uniqueness is defined by change_id which is surragate key
INSERT INTO subway_schema.ticket_price_history (ticket_id, ticket_price_at_given_date)
SELECT t.ticket_id, ph.price
FROM (VALUES
(2.50),
(3.00)) as ph(price)
INNER JOIN subway_schema.tickets t ON t.price = ph.price;

-- here also we do not need ON CONFLICT.. since uniqueness is defined by passenger_id which is surragate key 
-- So one passenger can buy one type ofticket multiple times
INSERT INTO subway_schema.passengers (passenger_name, ticket_id) 
SELECT 	p.passenger_name, t.ticket_id
FROM (VALUES
('Abdulla Qodiriy', 2.50),
('Vartolu Sadettin', 3.00)) AS p(passenger_name, price)
INNER  JOIN subway_schema.tickets t ON t.price = p.price;

INSERT INTO subway_schema.trip_passengers (trip_id, passenger_id)
SELECT	t.trip_id, p.passenger_id
FROM (VALUES
('Morning Trip', 'Abdulla Qodiriy'),
('Evening Trip', 'Vartolu Sadettin')) AS tp(trip_name, passenger_name)
INNER JOIN subway_schema.trips t ON t.trip_name = tp.trip_name
INNER JOIN subway_schema.passengers p ON p.passenger_name = tp.passenger_name
ON CONFLICT (trip_id, passenger_id) DO NOTHING
;

INSERT INTO subway_schema.schedules (station_id, train_id, arrival_time, departure_time)
SELECT  s.station_id, t.train_id,  st.arrival_time, st.departure_time
FROM	(VALUES
('Central Station', 'Sharq', '2026-04-06 08:00:00'::timestamp, '2026-04-06 08:05:00'::timestamp),
('North Station', 'Nasaf', '2026-04-06 09:00:00'::timestamp, '2026-04-06 09:05:00'::timestamp)) AS st(station_name, train_name,  arrival_time, departure_time)
INNER JOIN subway_schema.stations s ON s.station_name = st.station_name
INNER JOIN subway_schema.trains t ON t.train_name = st.train_name
ON CONFLICT ( station_id, train_id, arrival_time, departure_time) DO NOTHING;

-- I did not used ON CONFLICT(train_id, description) DO NOTHING  since one train can have  same problem multiple time
INSERT INTO subway_schema.maintenance_records (train_id, description)
SELECT	t.train_id, tm.description
FROM (VALUES 
('Sharq', 'Routine check completed'),
('Nasaf', 'Brake system maintenance')) as tm(train_name, description)
INNER JOIN subway_schema.trains t ON t.train_name = tm.train_name;

-- Add a not null 'record_ts' field to each table using ALTER TABLE statements, set the default value to current_date, and 
-- check to make sure the value has been set for the existing rows.

ALTER TABLE subway_schema.metro_lines
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.employees
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.line_stations
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.maintenance_records
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.passengers
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.schedules
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.stations
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.ticket_price_history
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.tickets
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.trains
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.trip_passengers
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE subway_schema.trips
ADD COLUMN IF NOT EXISTS record_ts TIMESTAMPTZ NOT NULL DEFAULT NOW();



SELECT 'metro_lines' AS table_name,
COUNT(*) AS total_rows,
COUNT(*) FILTER (WHERE record_ts IS NULL) AS null_count
FROM subway_schema.metro_lines
UNION ALL
SELECT 'stations', COUNT(*), COUNT(*) FILTER (WHERE record_ts IS NULL)
FROM subway_schema.stations
UNION ALL
SELECT 'employees', COUNT(*), COUNT(*) FILTER (WHERE record_ts IS NULL)
FROM	subway_schema.employees
UNION ALL 
SELECT 'line_stations', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.line_stations
UNION ALL 
SELECT 'maintenace_records', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.maintenance_records
UNION ALL 
SELECT 'passengers', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.passengers
UNION ALL
SELECT 'schedules', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.schedules
UNION ALL
SELECT 'ticket_price_history', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.ticket_price_history
UNION ALL
SELECT 'tickets', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.tickets
UNION ALL
SELECT 'trains', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.trains
UNION ALL
SELECT 'trip_passengers', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.trip_passengers
UNION All
SELECT 'trips', COUNT(*), COUNT(*) FILTER(WHERE record_ts IS NULL)
FROM	subway_schema.trips;




