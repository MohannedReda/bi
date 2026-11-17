
/*
====================================================
Project: Olist Delivery Performance
Database: Olist_Delivery_Performance
File: 01_schema.sql
Purpose:
- Document database schema
- Document table definitions
- Provide data import instructions

Source:
Brazilian E-Commerce Public Dataset by Olist
====================================================
*/

USE Olist_Delivery_Performance;
GO

/*
====================================================
1. DATABASE TABLES
====================================================

The database contains seven tables:

1. olist_orders
2. olist_customers
3. olist_order_items
4. olist_products
5. olist_sellers
6. olist_order_payments
7. olist_order_reviews

Table definitions, column data types, and key
relationships are documented in the project
Data Dictionary and Schema documentation.
*/

/*
====================================================
2. IMPORT NOTES
====================================================

Source:
Brazilian E-Commerce Public Dataset by Olist.

Import Method:
The original CSV files were imported into
Microsoft SQL Server using SQL Server Management
Studio (SSMS) Import Flat File / Import Data tools.

Imported tables:
- olist_orders
- olist_customers
- olist_order_items
- olist_products
- olist_sellers
- olist_order_payments
- olist_order_reviews

Note:
The geolocation dataset was not imported.

For detailed column definitions and relationships,
refer to:
Documentation/Database_Schema.pdf
Documentation/Data_Dictionary.pdf

*/
