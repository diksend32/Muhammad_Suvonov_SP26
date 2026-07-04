CREATE SCHEMA IF NOT EXISTS BL_DM;

CREATE TABLE IF NOT EXISTS BL_DM.DIM_TIME_DAY (
    date_surr_id   INT           NOT NULL,   
    full_date      DATE          NOT NULL,   
    day            SMALLINT      NOT NULL,   
    day_name       VARCHAR(20)   NOT NULL,   
    day_of_week    SMALLINT      NOT NULL,   
    week_of_year   SMALLINT      NOT NULL,  
    month          SMALLINT      NOT NULL,   
    month_name     VARCHAR(20)   NOT NULL,   
    quarter        SMALLINT      NOT NULL,   
    year           SMALLINT      NOT NULL,  
    CONSTRAINT pk_dim_time_day PRIMARY KEY (date_surr_id),
    CONSTRAINT uq_dim_time_day_full_date UNIQUE (full_date)
);

WITH calendar AS (
    SELECT GENERATE_SERIES(
             DATE '2000-01-01', 
             DATE '2030-12-31',   
             INTERVAL '1 day'
           )::DATE AS full_date
)
INSERT INTO BL_DM.DIM_TIME_DAY (
    date_surr_id,
    full_date,
    day,
    day_name,
    day_of_week,
    week_of_year,
    month,
    month_name,
    quarter,
    year
)
SELECT
    TO_CHAR(full_date, 'YYYYMMDD')::INT   AS date_surr_id,
    full_date,
    EXTRACT(DAY     FROM full_date)       AS day,
    TO_CHAR(full_date, 'FMDay')           AS day_name,
    EXTRACT(ISODOW  FROM full_date)       AS day_of_week,     
    EXTRACT(WEEK    FROM full_date)       AS week_of_year,
    EXTRACT(MONTH   FROM full_date)       AS month,
    TO_CHAR(full_date, 'FMMonth')         AS month_name,
    EXTRACT(QUARTER FROM full_date)       AS quarter,
    EXTRACT(YEAR    FROM full_date)       AS year
FROM calendar
ORDER BY full_date
ON CONFLICT (date_surr_id) DO NOTHING;


