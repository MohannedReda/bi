
SELECT
    COUNT(*) AS Total_Orders,

    COUNT(CASE
        WHEN order_status = 'delivered'
        THEN 1
    END) AS Delivered_Orders,

    CAST(
        AVG(
            CASE
                WHEN order_status = 'delivered'
                THEN CAST(
                    DATEDIFF(
                        DAY,
                        order_purchase_timestamp,
                        order_delivered_customer_date
                    ) AS DECIMAL(10,2)
                )
            END
        ) AS DECIMAL(10,2)
    ) AS Avg_Delivery_Days,

    CAST(
        100.0 * COUNT(
            CASE
                WHEN order_status = 'delivered'
                 AND order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
            END
        )
        / NULLIF(
            COUNT(
                CASE
                    WHEN order_status = 'delivered'
                     AND order_delivered_customer_date IS NOT NULL
                    THEN 1
                END
            ), 0
        )
        AS DECIMAL(10,2)
    ) AS Late_Delivery_Rate

FROM olist_orders

WHERE order_purchase_timestamp >= '20170101'
  AND order_purchase_timestamp < '20180901';


--Chart 1 — Monthly Delivery Performance
SELECT
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    ) AS Purchase_Month,

    COUNT(CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 1
    END) AS On_Time_Orders,

    COUNT(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1
    END) AS Late_Orders,

    CAST(
        AVG(CAST(
            DATEDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date
            ) AS DECIMAL(10,2)
        )) AS DECIMAL(10,2)
    ) AS Avg_Delivery_Days

FROM olist_orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp >= '20170101'
  AND order_purchase_timestamp < '20180901'

GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)

ORDER BY Purchase_Month;

---Chart 2 — Late Delivery Rate by State

SELECT TOP 10
    c.customer_state AS Customer_State,

    COUNT(*) AS Delivered_Orders,

    COUNT(CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 1
    END) AS Late_Orders,

    CAST(
        100.0 * COUNT(CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
        END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Late_Delivery_Rate

FROM olist_orders o

JOIN olist_customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= '20170101'
  AND o.order_purchase_timestamp < '20180901'

GROUP BY c.customer_state

HAVING COUNT(*) >= 30

ORDER BY Late_Delivery_Rate DESC;


--Chart 3 — Top 10 Sellers by Late Delivery Rate

WITH Seller_Orders AS (
    SELECT DISTINCT
        oi.seller_id,
        o.order_id,
        s.seller_state,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date

    FROM olist_order_items oi

    JOIN olist_orders o
        ON oi.order_id = o.order_id

    JOIN olist_sellers s
        ON oi.seller_id = s.seller_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'
)

SELECT TOP 10
    seller_id AS Seller_ID,
    seller_state AS Seller_State,

    COUNT(*) AS Delivered_Orders,

    COUNT(CASE
        WHEN order_delivered_customer_date >
             order_estimated_delivery_date
        THEN 1
    END) AS Late_Orders,

    CAST(
        100.0 * COUNT(CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
        END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Late_Delivery_Rate

FROM Seller_Orders

GROUP BY seller_id, seller_state

HAVING COUNT(*) >= 20

ORDER BY Late_Delivery_Rate DESC;

---Chart 4 — Within-State vs Cross-State Delivery

WITH Seller_Order_Pairs AS (
    SELECT DISTINCT
        o.order_id,
        s.seller_state,
        c.customer_state,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date

    FROM olist_orders o

    JOIN olist_customers c
        ON o.customer_id = c.customer_id

    JOIN olist_order_items oi
        ON o.order_id = oi.order_id

    JOIN olist_sellers s
        ON oi.seller_id = s.seller_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp >= '20170101'
      AND o.order_purchase_timestamp < '20180901'
)

SELECT
    CASE
        WHEN seller_state = customer_state
        THEN 'Within-State'
        ELSE 'Cross-State'
    END AS Delivery_Type,

    COUNT(*) AS Seller_Order_Pairs,

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
        100.0 * COUNT(CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
        END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Late_Delivery_Rate

FROM Seller_Order_Pairs

GROUP BY
    CASE
        WHEN seller_state = customer_state
        THEN 'Within-State'
        ELSE 'Cross-State'
    END

ORDER BY Delivery_Type;
