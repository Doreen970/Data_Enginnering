
-- SQL queries for data modeling
USE DATABASE SNOW_SALE;

select * FROM sales_table
LIMIT 3;

-- customer dimension table
CREATE OR REPLACE TABLE dim_customer (
    CUSTOMERID INT,
    CUSTOMERNAME VARCHAR,
    PRIMARY KEY (CUSTOMERID)
);

INSERT INTO dim_customer (CUSTOMERID, CUSTOMERNAME)
SELECT DISTINCT CUSTOMERID, CUSTOMERNAME
FROM sales_table;

SELECT * FROM dim_customer
LIMIT 5;

-- orders dimension table
CREATE OR REPLACE TABLE dim_orders (
    ORDERID INT,
    QUANTITY INT,
    PRIMARY KEY (ORDERID)
);

INSERT INTO dim_orders (ORDERID, QUANTITY)
SELECT DISTINCT ORDERID, QUANTITY 
FROM sales_table;

SELECT * FROM dim_orders
LIMIT 3;

-- products dimension table
CREATE OR REPLACE TABLE dim_products (
    PRODUCTID INT,
    PRODUCTNAME VARCHAR,
    PRIMARY KEY (PRODUCTID)
);

INSERT INTO dim_products (PRODUCTID, PRODUCTNAME)
SELECT DISTINCT PRODUCTID, PRODUCTNAME
FROM sales_table;

SELECT * FROM dim_products
LIMIT 3;


-- date dimension table
CREATE OR REPLACE TABLE dim_date (
    DATEID INT AUTOINCREMENT,
    date DATE,
    DAY INT,
    MONTH INT,
    YEAR INT,
    PRIMARY KEY (DATEID)
);

INSERT INTO dim_date (date, DAY, MONTH, YEAR)
SELECT DISTINCT ORDERDATE,
DAY(ORDERDATE),
MONTH(ORDERDATE),
YEAR(ORDERDATE)
FROM sales_table;

SELECT * FROM dim_date
LIMIT 5;

-- creating a fact table
CREATE OR REPLACE TABLE sales_fact (
    sales_id INT AUTOINCREMENT,
    CUSTOMERID INT,
    ORDERID INT,
    PRODUCTID INT,
    DATEID INT,
    PRICEPERUNIT DECIMAL (10, 2),
    TOTALPRICE DECIMAL (10, 2),
    PRIMARY KEY (sales_id),
    FOREIGN KEY (CUSTOMERID) REFERENCES dim_customer(CUSTOMERID),
    FOREIGN KEY (ORDERID) REFERENCES dim_orders(ORDERID),
    FOREIGN KEY (PRODUCTID) REFERENCES dim_products(PRODUCTID),
    FOREIGN KEY (DATEID) REFERENCES dim_date(DATEID)
);

INSERT INTO sales_fact (CUSTOMERID, ORDERID, PRODUCTID, DATEID, PRICEPERUNIT, TOTALPRICE)
SELECT
    c.CUSTOMERID,
    o.ORDERID,
    p.PRODUCTID,
    d.DATEID,
    s.PRICEPERUNIT,
    s.TOTALPRICE
FROM sales_table s
LEFT JOIN dim_customer c ON s.CUSTOMERNAME = c.CUSTOMERNAME
LEFT JOIN dim_orders o ON s.QUANTITY = o.QUANTITY
LEFT JOIN dim_products p ON s.PRODUCTNAME = p.PRODUCTNAME
LEFT JOIN dim_date d ON s.ORDERDATE = d.date;

SELECT * FROM sales_fact
LIMIT 3;

-- data validation checks / cleaning
-- check for nulls
SELECT * 
FROM sales_fact
LEFT JOIN dim_customer ON sales_fact.CUSTOMERID = dim_customer.CUSTOMERID
LEFT JOIN dim_orders ON sales_fact.ORDERID = dim_orders.ORDERID
LEFT JOIN dim_products ON sales_fact.PRODUCTID = dim_products.PRODUCTID
LEFT JOIN dim_date ON sales_fact.DATEID = dim_date.DATEID
WHERE dim_customer.CUSTOMERID IS NULL
   OR dim_orders.ORDERID IS NULL
   OR dim_products.PRODUCTID IS NULL
   OR dim_date.DATEID IS NULL
   OR sales_fact.priceperunit IS NULL
   OR sales_fact.totalprice IS NULL;

-- checking column datatypes
SELECT 
    table_name,
    column_name,
    data_type
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    table_name IN ('SALES_FACT', 'DIM_CUSTOMER', 'DIM_ORDERS', 'DIM_PRODUCTS', 'DIM_DATE')
ORDER BY 
    table_name, column_name;

-- check for duplicates
SELECT 
    CUSTOMERID, ORDERID, PRODUCTID, DATEID, PRICEPERUNIT, TOTALPRICE,
    COUNT(*) AS count_duplicates
FROM 
    sales_fact
GROUP BY 
    CUSTOMERID, ORDERID, PRODUCTID, DATEID, PRICEPERUNIT, TOTALPRICE
HAVING 
    COUNT(*) > 1;

-- validating date table
SELECT DAY, MONTH, YEAR
FROM dim_date
WHERE (DAY > 31
OR MONTH > 12
OR YEAR > 2024);   

-- validating orders table
SELECT * FROM dim_orders
WHERE QUANTITY < 1;
