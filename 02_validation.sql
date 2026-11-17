
/*
====================================================
Project: Olist Delivery Performance
Database: Olist_Delivery_Performance
File: 02_validation.sql

Purpose:
- Data profiling
- NULL checks
- Duplicate checks
- Key validation
- Relationship validation
- Validation evidence

====================================================
*/

USE Olist_Delivery_Performance;
GO

/* ================================================
   1. DATA PROFILING
   ================================================ */

SELECT 'olist_orders' AS Table_Name,
       COUNT(*) AS Total_Rows
FROM olist_orders

UNION ALL

SELECT 'olist_customers', COUNT(*)
FROM olist_customers

UNION ALL

SELECT 'olist_order_items', COUNT(*)
FROM olist_order_items

UNION ALL

SELECT 'olist_products', COUNT(*)
FROM olist_products

UNION ALL

SELECT 'olist_sellers', COUNT(*)
FROM olist_sellers

UNION ALL

SELECT 'olist_order_payments', COUNT(*)
FROM olist_order_payments

UNION ALL

SELECT 'olist_order_reviews', COUNT(*)
FROM olist_order_reviews;


/* ================================================
   2. NULL CHECKS
   ================================================ */

SELECT
    COUNT(*) AS Total_Orders,

    SUM(CASE
        WHEN customer_id IS NULL THEN 1
        ELSE 0
    END) AS Null_Customer_ID,

    SUM(CASE
        WHEN order_purchase_timestamp IS NULL THEN 1
        ELSE 0
    END) AS Null_Purchase_Date,

    SUM(CASE
        WHEN order_estimated_delivery_date IS NULL THEN 1
        ELSE 0
    END) AS Null_Estimated_Date

FROM olist_orders;


/* ================================================
   3. DUPLICATE CHECKS
   ================================================ */

-- Duplicate Order IDs

SELECT
    order_id,
    COUNT(*) AS Duplicate_Count
FROM olist_orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Duplicate Order Items (Logical Composite Key)

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS Duplicate_Count
FROM olist_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- Duplicate Payments (Logical Composite Key)

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS Duplicate_Count
FROM olist_order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;


-- Duplicate Review IDs

SELECT
    review_id,
    COUNT(*) AS Duplicate_Count
FROM olist_order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;


/* ================================================
   4. KEY & RELATIONSHIP CHECKS
   ================================================ */

-- Orders without matching customers

SELECT COUNT(*) AS Orders_Without_Customers
FROM olist_orders o
LEFT JOIN olist_customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order Items without matching orders

SELECT COUNT(*) AS Items_Without_Orders
FROM olist_order_items i
LEFT JOIN olist_orders o
    ON i.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order Items without matching products

SELECT COUNT(*) AS Items_Without_Products
FROM olist_order_items i
LEFT JOIN olist_products p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Order Items without matching sellers

SELECT COUNT(*) AS Items_Without_Sellers
FROM olist_order_items i
LEFT JOIN olist_sellers s
    ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


/* ================================================
   5. DATA VALIDATION
   ================================================ */

-- Invalid Review Scores

SELECT COUNT(*) AS Invalid_Review_Scores
FROM olist_order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;


-- Invalid Order Prices

SELECT COUNT(*) AS Invalid_Prices
FROM olist_order_items
WHERE price < 0;


-- Invalid Freight Values

SELECT COUNT(*) AS Invalid_Freight_Values
FROM olist_order_items
WHERE freight_value < 0;


-- Invalid Delivery Dates

SELECT COUNT(*) AS Invalid_Delivery_Dates
FROM olist_orders
WHERE order_delivered_customer_date
      < order_purchase_timestamp;


/* ================================================
   6. ANALYSIS SCOPE / EXCLUSIONS
   ================================================ */

-- Orders outside the analysis period

SELECT
    COUNT(*) AS Orders_Outside_Analysis_Period
FROM olist_orders
WHERE order_purchase_timestamp < '20170101'
   OR order_purchase_timestamp >= '20180901';


-- Orders not delivered

SELECT
    order_status,
    COUNT(*) AS Orders_Count
FROM olist_orders
WHERE order_status <> 'delivered'
GROUP BY order_status
ORDER BY Orders_Count DESC;


/*
====================================================
VALIDATION NOTES
====================================================

1. Data quality checks were performed before analysis.
2. Duplicate checks used logical key combinations.
3. Referential integrity was checked through joins.
4. Delivery analysis uses the defined purchase date range.
5. Non-delivered orders are excluded from delivery-time
   and late-delivery calculations where appropriate.

Validation results should be reviewed and saved as
evidence. No records should be reported as excluded
or corrected unless the corresponding action was
actually performed.

====================================================
*/
