-- One time Snowflake setup: database, warehouse, Azure Blob external stage, raw loads
CREATE DATABASE IF NOT EXISTS FINANCE_MART;
CREATE WAREHOUSE IF NOT EXISTS TRANSFORM_WH WITH WAREHOUSE_SIZE = XSMALL AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;
CREATE SCHEMA IF NOT EXISTS FINANCE_MART.RAW;

-- File format for the Olist CSVs
CREATE OR REPLACE FILE FORMAT FINANCE_MART.RAW.CSV_FMT
  TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1 NULL_IF = ('', 'NULL');

-- External stage pointing at Azure Blob Storage (upload the Olist CSVs to this container first)
CREATE OR REPLACE STAGE FINANCE_MART.RAW.AZURE_OLIST
  URL = 'azure://<storage_account>.blob.core.windows.net/olist-raw'
  CREDENTIALS = (AZURE_SAS_TOKEN = '<sas_token>')
  FILE_FORMAT = FINANCE_MART.RAW.CSV_FMT;

-- Raw tables
CREATE OR REPLACE TABLE FINANCE_MART.RAW.ORDERS (
  order_id STRING, customer_id STRING, order_status STRING,
  order_purchase_timestamp TIMESTAMP_NTZ, order_approved_at TIMESTAMP_NTZ,
  order_delivered_carrier_date TIMESTAMP_NTZ, order_delivered_customer_date TIMESTAMP_NTZ,
  order_estimated_delivery_date TIMESTAMP_NTZ
);
CREATE OR REPLACE TABLE FINANCE_MART.RAW.ORDER_ITEMS (
  order_id STRING, order_item_id INTEGER, product_id STRING, seller_id STRING,
  shipping_limit_date TIMESTAMP_NTZ, price NUMBER(10,2), freight_value NUMBER(10,2)
);
CREATE OR REPLACE TABLE FINANCE_MART.RAW.CUSTOMERS (
  customer_id STRING, customer_unique_id STRING, customer_zip_code_prefix STRING,
  customer_city STRING, customer_state STRING
);
CREATE OR REPLACE TABLE FINANCE_MART.RAW.PRODUCTS (
  product_id STRING, product_category_name STRING, product_name_lenght INTEGER,
  product_description_lenght INTEGER, product_photos_qty INTEGER,
  product_weight_g INTEGER, product_length_cm INTEGER, product_height_cm INTEGER, product_width_cm INTEGER
);
CREATE OR REPLACE TABLE FINANCE_MART.RAW.PAYMENTS (
  order_id STRING, payment_sequential INTEGER, payment_type STRING,
  payment_installments INTEGER, payment_value NUMBER(10,2)
);

-- Load from the Azure stage
COPY INTO FINANCE_MART.RAW.ORDERS       FROM @FINANCE_MART.RAW.AZURE_OLIST/olist_orders_dataset.csv;
COPY INTO FINANCE_MART.RAW.ORDER_ITEMS  FROM @FINANCE_MART.RAW.AZURE_OLIST/olist_order_items_dataset.csv;
COPY INTO FINANCE_MART.RAW.CUSTOMERS    FROM @FINANCE_MART.RAW.AZURE_OLIST/olist_customers_dataset.csv;
COPY INTO FINANCE_MART.RAW.PRODUCTS     FROM @FINANCE_MART.RAW.AZURE_OLIST/olist_products_dataset.csv;
COPY INTO FINANCE_MART.RAW.PAYMENTS     FROM @FINANCE_MART.RAW.AZURE_OLIST/olist_order_payments_dataset.csv;
