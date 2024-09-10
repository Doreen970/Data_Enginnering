CREATE DATABASE music_sales;
USE DATABASE music_sales;
CREATE SCHEMA music_data_schema;

CREATE OR REPLACE WAREHOUSE music_warehouse
WITH WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE;

SHOW DATABASES;
USE music_sales;

CREATE OR REPLACE STAGE my_music_stage;

COPY INTO @my_music_stage/music_data.csv
FROM music_data_schema.music
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');

LIST @my_music_stage;

-- code to check null values
SELECT * FROM music_data_schema.music
WHERE VALUE IS NULL;

-- script to replace null values with 0
UPDATE music_data_schema.music
SET VALUE = 0
WHERE VALUE IS NULL;

SELECT VALUE
FROM music_data_schema.music
WHERE VALUE IS NULL;

-- Create database user
CREATE USER Esther
PASSWORD = '@essy1'
COMMENT = 'New employee in data analysis department';

-- Create database roles and assign privileges
CREATE ROLE data_analyst;
GRANT SELECT ON music_data_schema.music TO ROLE data_analyst;

-- give a role to a user
GRANT ROLE data_analyst TO USER Esther;

GRANT ROLE data_analyst to USER DOREENWANYAMA;
USE ROLE data_analyst;

USE DATABASE music_sales;

SELECT VALUE
FROM music_data_schema.music;

SELECT DISTINCT VALUE
FROM music_data_schema.music;

-- remove characters that are non-numeric eg commas
UPDATE music_data_schema.music
SET VALUE = REPLACE(VALUE, ',', '');

DROP USER Esther;

UPDATE music_data_schema.music
SET VALUE = 1
WHERE VALUE = 0.8;