-- I created each table in specific ordred to avoid mistake finding foreign keys 

CREATE DATABASE subway;

CREATE SCHEMA subway_schema;

-- I used BIGSERIAL to avoid writing id which was INTEGER in the diogram
CREATE TABLE subway_schema.metro_lines(
line_id		BIGSERIAL PRIMARY KEY,
line_name   VARCHAR(50) NOT NULL UNIQUE,
status 	VARCHAR  CHECK (status IN ('active', 'under construction')),
opened_yaer INT CHECK (opened_yaer >= 2000)
);

CREATE TABLE subway_schema.stations(
station_id BIGSERIAL PRIMARY KEY,
station_name VARCHAR(50) NOT NULL UNIQUE,
opened_yaer INT CHECK (opened_yaer >= 2000)
);

-- bridge table for establishing many to many relationship between metro_lines and stations

-- Added composite key to avoid duplicate rows
CREATE TABLE subway_schema.line_stations(
line_id INT REFERENCES subway_schema.metro_lines(line_id),
station_id INT REFERENCES subway_schema.stations(station_id),
PRIMARY KEY (line_id, station_id)
);

CREATE TABLE subway_schema.employees(
employee_id BIGSERIAL PRIMARY KEY,
employee_name VARCHAR(50) NOT NULL,
station_id INT REFERENCES subway_schema.stations(station_id)
);

CREATE TABLE subway_schema.trains(
train_id BIGSERIAL PRIMARY KEY,
line_id INT REFERENCES subway_schema.metro_lines(line_id),
train_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE  subway_schema.trips(
trip_id BIGSERIAL PRIMARY KEY,
trip_name VARCHAR(50) NOT NULL,
train_id INT REFERENCES subway_schema.trains(train_id)
);

-- price cannot be NEGATIVE so I used check. I added columns purchased at(time of ticket purchased), duration and valid_until 
-- to maintain validity period better and avoiding hardcoding it every time when new row is entered
CREATE TABLE subway_schema.tickets(
ticket_id BIGSERIAL PRIMARY KEY,
price DECIMAL(10,2) CHECK(price > 0),
purchased_at TIMESTAMP NOT NULL DEFAULT NOW(),
duration INTERVAL NOT NULL DEFAULT '30 minutes',
valid_until TIMESTAMP GENERATED ALWAYS AS (purchased_at + duration) STORED
);

CREATE TABLE subway_schema.ticket_price_history(
change_id BIGSERIAL PRIMARY KEY,
ticket_id INT REFERENCES subway_schema.tickets(ticket_id),
ticket_price_at_given_date DECIMAL(10,2) CHECK(ticket_price_at_given_date > 0),
update_date TIMESTAMP NOT NULL
);

CREATE TABLE subway_schema.passengers(
passenger_id BIGSERIAL PRIMARY KEY,
passenger_name VARCHAR(50),
ticket_id INT REFERENCES subway_schema.tickets(ticket_id)
);

CREATE TABLE subway_schema.trip_passengers(
trip_id INT REFERENCES subway_schema.trips(trip_id),
passenger_id INT REFERENCES subway_schema.passengers(passenger_id)
);

CREATE TABLE subway_schema.schedules(
schedule_id BIGSERIAL PRIMARY KEY,
station_id INT REFERENCES subway_schema.stations(station_id),
train_id INT REFERENCES subway_schema.trains(train_id),
arrival_time TIMESTAMP,
departure_time TIMESTAMP
);

CREATE TABLE subway_schema.maintenance_records(
record_id BIGSERIAL PRIMARY KEY,
train_id INT REFERENCES subway_schema.trains(train_id),
description VARCHAR(50) NOT NULL
);


-- adding values
INSERT INTO subway_schema.metro_lines (line_name, status, opened_yaer) VALUES
('Red Line', 'active', 2005),
('Blue Line', 'under construction', 2023);

INSERT INTO subway_schema.stations (station_name, opened_yaer) VALUES
('Central Station', 2005),
('North Station', 2010);

INSERT INTO subway_schema.line_stations (line_id, station_id) VALUES
(1, 1),
(2, 2);

INSERT INTO subway_schema.employees (employee_name, station_id) VALUES
('Antony Joshua', 1),
('Said Karimov', 2);

INSERT INTO subway_schema.trains (line_id, train_name) VALUES
(1, 'Sharq'),
(2, 'Nasaf');

INSERT INTO subway_schema.trips (trip_name, train_id) VALUES
('Morning Trip', 1),
('Evening Trip', 2);

INSERT INTO subway_schema.tickets (price) VALUES
(2.50),
(3.00);

INSERT INTO subway_schema.ticket_price_history (ticket_id, ticket_price_at_given_date, update_date) VALUES
(1, 2.50, NOW()),
(2, 3.00, NOW());

INSERT INTO subway_schema.passengers (passenger_name, ticket_id) VALUES
('Abdulla Qodiriy', 1),
('Vartole Sadettin', 2);

INSERT INTO subway_schema.trip_passengers (trip_id, passenger_id) VALUES
(1, 1),
(2, 2);

INSERT INTO subway_schema.schedules (station_id, train_id, arrival_time, departure_time) VALUES
(1, 1, '2026-04-06 08:00:00', '2026-04-06 08:05:00'),
(2, 2, '2026-04-06 09:00:00', '2026-04-06 09:05:00');

INSERT INTO subway_schema.maintenance_records (train_id, description) VALUES
(1, 'Routine check completed'),
(2, 'Brake system maintenance');