-- 									HOW SALES ARE PERFORMING?
SELECT
    ROUND(SUM(payment_value), 2) AS Total_Revenue
FROM order_payments;

SELECT
	DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS Month,
    ROUND(SUM(payment_value), 2) AS Revenue
FROM
	orders o
JOIN
	order_payments op
ON
	o.order_id = op.order_id
GROUP BY Month
ORDER BY Revenue DESC;

-- Is increasing revenue come from more orders?
SELECT
    DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS Month,
    COUNT(order_id) AS Total_Orders
FROM orders
GROUP BY Month
ORDER BY Month;

-- Were customers spending more per order (AOV)?
SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS Month,
    ROUND(AVG(op.payment_value),2) AS Avg_Order_Value
FROM 
	orders o
JOIN 
	order_payments op
ON 
	o.order_id = op.order_id
GROUP BY Month
ORDER BY Month;


-- 									WHICH CATEGORY GENERATE HIGHEST SALES?
SELECT
    p.product_category_name AS Category,
    COUNT(DISTINCT oi.order_id) AS Orders,
    ROUND(SUM(oi.price),2) AS Revenue
FROM 
	order_items oi
JOIN 
	products p
ON 
	oi.product_id = p.product_id
GROUP BY p.product_category_name
--             				<-- Order by Revenue or by Orders frequency
ORDER BY Revenue DESC 
-- ORDER BY Orders DESC
LIMIT 5;


-- 									WHICH CUSTOMERS ARE MOST VALUABLE?
-- Who spends the most?
SELECT
    c.customer_unique_id,
    ROUND(SUM(op.payment_value), 2) AS Total_Spend
FROM 
	customers c
JOIN 
	orders o
ON 
	c.customer_id = o.customer_id
JOIN 
	order_payments op
ON 
	o.order_id = op.order_id
GROUP BY c.customer_unique_id
ORDER BY Total_Spend DESC
LIMIT 10;

-- Number of Orders per Customer
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS Total_Orders
FROM 
	customers c
JOIN 
	orders o
ON 
	c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY Total_Orders DESC;

-- Average Spend per Customer
SELECT
    c.customer_unique_id,
    ROUND(SUM(op.payment_value) / COUNT(DISTINCT o.order_id), 2) AS Avg_Order_Value
FROM 
	customers c
JOIN 
	orders o
ON 
	c.customer_id = o.customer_id
JOIN 
	order_payments op
ON 
	o.order_id = op.order_id
GROUP BY c.customer_unique_id
ORDER BY Avg_Order_Value DESC;

-- Acquiring information about customer_unique_id = '0a0a92112bd4c708ca5fde585afaa872' 
-- as it is toping in both most spending customer and average spend per customer
SELECT DISTINCT
	c.customer_unique_id,
    c.customer_id,
    p.product_category_name
FROM
	customers c
JOIN
	orders o
ON
	c.customer_id = o.customer_id
JOIN
	order_items ot
ON
	o.order_id = ot.order_id
JOIN
	products p
ON
	ot.product_id = p.product_id
WHERE
	customer_unique_id = '0a0a92112bd4c708ca5fde585afaa872';

-- Customer distribution by State
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS Customers
FROM 
	customers c
GROUP BY c.customer_state
ORDER BY Customers DESC;


-- 									WHICH SELLERS PERFORM BEST?
SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS Orders,
    COUNT(*) AS Units_Sold,
    ROUND(SUM(oi.price),2) AS Revenue,
    ROUND(AVG(oi.price),2) AS Avg_Product_Price,
    ROUND(AVG(r.review_score),2) AS Avg_Review,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)),2) AS Avg_Delivery_Days
FROM 
	order_items oi
JOIN 
	orders o
ON 
	oi.order_id = o.order_id
JOIN 
	order_reviews r
ON 
	oi.order_id = r.order_id
GROUP BY oi.seller_id
ORDER BY Revenue DESC
Limit 5;


-- 									WHY CUSTOMERS LEAVE POSITIVE OR NEGATIVE REVIEWS?
-- Review score by late delivery
SELECT
    r.review_score,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS Late_Deliveries,
    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),2
	) AS Late_Delivery_Percentage
FROM 
	orders o
JOIN
	order_reviews r
ON 
	o.order_id = r.order_id
WHERE 
	o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score;

-- Review score by Category
SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score),2) AS Avg_Review,
    COUNT(*) AS Reviews
FROM 
	order_items oi
JOIN 
	products p
ON 
	oi.product_id = p.product_id
JOIN 
	order_reviews r
ON 
	oi.order_id = r.order_id
GROUP BY p.product_category_name
HAVING COUNT(*) >= 30
ORDER BY Avg_Review DESC
Limit 5;

-- Review score by Seller
SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score),2) AS Avg_Review,
    COUNT(DISTINCT oi.order_id) AS Orders
FROM 
	order_items oi
JOIN 
	order_reviews r
ON 
	oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT oi.order_id) >= 20
ORDER BY Avg_Review DESC
LIMIT 5;

-- 									HOW DELIVERY PERFORMANCE AFFECTS CUSTOMER SATISFACTION?
-- Average Delivdry Days
SELECT
    ROUND(
        AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),
        2
    ) AS Avg_Delivery_Days
FROM 
	orders
WHERE 
	order_status = 'delivered'
AND 
	order_delivered_customer_date IS NOT NULL;

-- Are late deliveries causing poor reviews?
SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On Time'
    END AS Delivery_Status,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(r.review_score),2) AS Avg_Review
FROM 
	orders o
JOIN 
	order_reviews r
ON 
	o.order_id = r.order_id
WHERE 
	o.order_status = 'delivered'
GROUP BY Delivery_Status;

-- Which states experience slower deliveries?
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS Orders,
    ROUND(
        AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)),2
    ) AS Avg_Delivery_Days
FROM 
	orders o
JOIN 
	customers c
ON 
	o.customer_id = c.customer_id
WHERE 
	o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY Avg_Delivery_Days DESC;

-- Late delivery Rate % by State
SELECT
    c.customer_state,
    COUNT(*) AS Orders,
    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS Late_Deliveries,
    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),2
    ) AS Late_Delivery_Percentage
FROM 
	orders o
JOIN 
	customers c
ON 
	o.customer_id = c.customer_id
WHERE 
	o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY Late_Delivery_Percentage DESC;