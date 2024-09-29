-- a file to keep track of changes happening
-- using snowflake tasks and streams

USE DATABASE SNOW_SALE;

USE SCHEMA sales_schema;

CREATE OR REPLACE STREAM dim_customer_stream
ON TABLE dim_customer;

CREATE OR REPLACE STREAM sales_fact_stream
ON TABLE sales_fact;

SHOW STREAMS;

-- creating a task for generating sales report

-- create a table for the report
CREATE OR REPLACE TABLE sales_report (
    report_date DATE,
    report_hour TIMESTAMP,
    total_sales DECIMAL (10, 2)
);

-- The task
CREATE OR REPLACE TASK hourly_sales
  WAREHOUSE = 'sales_warehouse' 
  SCHEDULE = '60 MINUTE' 
  COMMENT = 'sales report in realtime'
AS
  -- SQL script for real-time analysis
  BEGIN
    INSERT INTO sales_report (report_date, report_hour, total_sales)
    SELECT
      DATE_TRUNC(DAY, CURRENT_TIMESTAMP()) AS report_date,
      DATE_TRUNC(HOUR, CURRENT_TIMESTAMP()) AS report_hour,
      SUM(TOTALPRICE) AS total_sales
    FROM sales_fact_stream;
  END;

-- code to activate Task to run hourly
ALTER TASK hourly_sales RESUME;  

SELECT * FROM sales_fact_stream;

SELECT * FROM dim_customer_stream;

INSERT INTO dim_customer (CUSTOMERID, CUSTOMERNAME)
VALUES(1000, 'Mwangi Wetu');

INSERT INTO sales_fact (CUSTOMERID, ORDERID, PRODUCTID, DATEID, PRICEPERUNIT, TOTALPRICE)
VALUES(1000, NULL, NULL, NULL, NULL, 50000);

INSERT INTO sales_fact (CUSTOMERID, ORDERID, PRODUCTID, DATEID, PRICEPERUNIT, TOTALPRICE)
VALUES(NULL, NULL, NULL, NULL, NULL, 100000);



SELECT * FROM sales_report;