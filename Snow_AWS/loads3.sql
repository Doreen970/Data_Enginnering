-- SQL scripts for data extraction and loading into Snowflake

CREATE DATABASE Snow_sale;

USE DATABASE SNOW_SALE;

CREATE SCHEMA sales_schema;

CREATE OR REPLACE WAREHOUSE sales_warehouse
WITH WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE;

--CREATE OR REPLACE STAGE aws_stage
--url = 's3://snowfproject1/Sales/';
CREATE OR REPLACE STAGE aws_stage
URL='s3://snowfproject1/Sales/';

desc STAGE aws_stage;

list @aws_stage;

SELECT t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8, t.$9, t.$10 FROM @aws_stage t LIMIT 5;

-- table to store our data
CREATE TABLE sales_table (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR,
    ProductID INT,
    ProductName VARCHAR,
    Quantity INT,
    PricePerUnit FLOAT,
    TotalPrice FLOAT
);

COPY INTO sales_table
FROM @aws_stage
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);

SELECT * FROM sales_table
LIMIT 5; 



