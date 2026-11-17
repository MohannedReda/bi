
-- G1: Orders by Status

SELECT
    order_status,
    COUNT(*) AS Total_Orders

FROM olist_orders

WHERE order_purchase_timestamp >= '20170101'
  AND order_purchase_timestamp < '20180901'

GROUP BY order_status;


-- G2: Monthly Sales

;WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp), 1
        ) AS Purchase_Month,

        SUM(i.price) AS Merchandise_Sales

    FROM olist_orders o
    JOIN olist_order_items i
        ON o.order_id = i.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'

    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
)

SELECT
    Purchase_Month,
    Merchandise_Sales

FROM MonthlySales
ORDER BY Purchase_Month;


-- G3: Monthly Review Coverage

SELECT
    DATEFROMPARTS(
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp), 1
    ) AS Purchase_Month,

    CAST(
        SUM(ISNULL(r.Has_Review, 0)) * 100.0 / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Review_Coverage_Percentage

FROM olist_orders o

OUTER APPLY (
    SELECT TOP 1 1 AS Has_Review
    FROM olist_order_reviews r
    WHERE r.order_id = o.order_id
      AND r.review_score BETWEEN 1 AND 5
) r

WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '20170101'
  AND o.order_purchase_timestamp < '20180901'

GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)

ORDER BY Purchase_Month;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

-- F1: Delivery Problems by State

;WITH DeliveryData AS
(
    SELECT
        o.order_id,
        c.customer_state,

        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS Delivery_Days,

        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END AS Is_Late,

        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            )
        END AS Late_Days

    FROM olist_orders o

    JOIN olist_customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    customer_state,
    COUNT(*) AS Total_Orders,

    CAST(
        AVG(CAST(Is_Late AS DECIMAL(10,2))) * 100
        AS DECIMAL(10,2)
    ) AS Late_Rate,

    CAST(
        AVG(CAST(Delivery_Days AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS Avg_Delivery_Days,

    CAST(
        AVG(CAST(Late_Days AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS Avg_Late_Days

FROM DeliveryData

GROUP BY customer_state

ORDER BY Late_Rate DESC;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- F2: Delivery Performance Over Time

SELECT
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    ) AS Purchase_Month,

    CAST(
        AVG(CAST(
            DATEDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date
            ) AS DECIMAL(10,2)
        )) AS DECIMAL(10,2)
    ) AS Avg_Delivery_Days,

    CAST(
        AVG(CAST(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1.0 ELSE 0.0
            END AS DECIMAL(10,2)
        )) * 100 AS DECIMAL(10,2)
    ) AS Late_Rate

FROM olist_orders

WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= '20170101'
  AND order_purchase_timestamp < '20180901'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)

ORDER BY Purchase_Month;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- F3: Orders Taking Longer Than State Average

;WITH DeliveryData AS
(
    SELECT
        o.order_id,
        c.customer_state,

        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS Delivery_Days

    FROM olist_orders o

    JOIN olist_customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'
      AND o.order_delivered_customer_date IS NOT NULL
),

StateAverage AS
(
    SELECT
        customer_state,
        AVG(CAST(Delivery_Days AS DECIMAL(10,2)))
            AS State_Avg_Delivery_Days

    FROM DeliveryData
    GROUP BY customer_state
)

SELECT
    d.order_id,
    d.customer_state,
    d.Delivery_Days,
    s.State_Avg_Delivery_Days

FROM DeliveryData d

JOIN StateAverage s
    ON d.customer_state = s.customer_state

WHERE d.Delivery_Days > s.State_Avg_Delivery_Days

ORDER BY
    d.Delivery_Days DESC;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- F4: Seller Delivery Performance by Customer State

;WITH SellerDelivery AS
(
    SELECT
        s.seller_id,
        s.seller_state,
        c.customer_state,
        o.order_id,

        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS Delivery_Days,

        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END AS Is_Late

    FROM olist_orders o

    JOIN olist_customers c
        ON o.customer_id = c.customer_id

    JOIN olist_order_items i
        ON o.order_id = i.order_id

    JOIN olist_sellers s
        ON i.seller_id = s.seller_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    seller_id,
    seller_state,
    customer_state,

    CAST(
        AVG(CAST(Delivery_Days AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS Avg_Delivery_Days,

    CAST(
        AVG(CAST(Is_Late AS DECIMAL(10,2))) * 100
        AS DECIMAL(10,2)
    ) AS Late_Rate

FROM SellerDelivery

GROUP BY
    seller_id,
    seller_state,
    customer_state

ORDER BY Late_Rate DESC;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- F5: Same-State vs Cross-State Delivery

;WITH DeliveryData AS
(
    SELECT
        CASE
            WHEN c.customer_state = s.seller_state
                THEN 'Same State'
            ELSE 'Cross State'
        END AS Route_Type,

        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS Delivery_Days,

        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END AS Is_Late

    FROM olist_orders o

    JOIN olist_customers c
        ON o.customer_id = c.customer_id

    JOIN olist_order_items i
        ON o.order_id = i.order_id

    JOIN olist_sellers s
        ON i.seller_id = s.seller_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    Route_Type,

    CAST(
        AVG(CAST(Delivery_Days AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS Avg_Delivery_Days,

    CAST(
        AVG(CAST(Is_Late AS DECIMAL(10,2))) * 100
        AS DECIMAL(10,2)
    ) AS Late_Rate

FROM DeliveryData

GROUP BY Route_Type;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- F6: Regional Delivery Problems Over Time

SELECT
    DATEFROMPARTS(
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp),
        1
    ) AS Purchase_Month,

    c.customer_state,

    CAST(
        AVG(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1.0
                ELSE 0.0
            END
        ) * 100 AS DECIMAL(10,2)
    ) AS Late_Rate

FROM olist_orders o

JOIN olist_customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '20170101'
  AND o.order_purchase_timestamp < '20180901'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp),
    c.customer_state

ORDER BY
    Purchase_Month,
    Late_Rate DESC;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- F7: Review Ratings by Delivery Status

;WITH ReviewData AS
(
    SELECT
        order_id,
        AVG(CAST(review_score AS DECIMAL(10,2)))
            AS Review_Score

    FROM olist_order_reviews

    WHERE review_score BETWEEN 1 AND 5

    GROUP BY order_id
)

SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END AS Delivery_Status,

    CAST(
        AVG(r.Review_Score) AS DECIMAL(10,2)
    ) AS Avg_Review_Score

FROM olist_orders o

JOIN ReviewData r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '20170101'
  AND o.order_purchase_timestamp < '20180901'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
 
 

-- O1.1: Average Delivery Time by Order Size

;WITH Orders AS
(
    SELECT
        o.order_id,
        COUNT(i.order_item_id) AS Items_Count,

        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS Delivery_Days

    FROM olist_orders o
    JOIN olist_order_items i
        ON o.order_id = i.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'

    GROUP BY
        o.order_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date
)

SELECT
    CASE
        WHEN Items_Count = 1 THEN 'Small'
        WHEN Items_Count BETWEEN 2 AND 5 THEN 'Medium'
        ELSE 'Large'
    END AS Order_Size,

    AVG(CAST(Delivery_Days AS DECIMAL(10,2)))
        AS Avg_Delivery_Days

FROM Orders

GROUP BY
    CASE
        WHEN Items_Count = 1 THEN 'Small'
        WHEN Items_Count BETWEEN 2 AND 5 THEN 'Medium'
        ELSE 'Large'
    END;


    
-- O1.2: Late Delivery Rate by Order Size

;WITH Orders AS
(
    SELECT
        o.order_id,
        COUNT(i.order_item_id) AS Items_Count,

        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END AS Is_Late

    FROM olist_orders o
    JOIN olist_order_items i
        ON o.order_id = i.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'

    GROUP BY
        o.order_id,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
)

SELECT
    CASE
        WHEN Items_Count = 1 THEN 'Small'
        WHEN Items_Count BETWEEN 2 AND 5 THEN 'Medium'
        ELSE 'Large'
    END AS Order_Size,

    CAST(AVG(CAST(Is_Late AS DECIMAL(10,2))) * 100
        AS DECIMAL(10,2)) AS Late_Rate

FROM Orders

GROUP BY
    CASE
        WHEN Items_Count = 1 THEN 'Small'
        WHEN Items_Count BETWEEN 2 AND 5 THEN 'Medium'
        ELSE 'Large'
    END;

