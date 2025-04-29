-- CREATE DATABASE IF NOT EXISTS alt_mobility;
-- USE alt_mobility;



-- 1. Order and Sales Analysis:
-- 1.1. Order Status Distribution
SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_orders), 2) AS percentage
FROM customer_orders
GROUP BY order_status
ORDER BY order_count DESC;


-- 1.2. Sales by Order Status
SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(SUM(order_amount), 2) AS total_sales,
    ROUND(AVG(order_amount), 2) AS avg_order_value
FROM customer_orders
GROUP BY order_status
ORDER BY total_sales DESC;


-- 1.3. Monthly Sales Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS yer_month,
    COUNT(*) AS order_count,
    ROUND(SUM(order_amount), 2) AS total_sales,
    ROUND(AVG(order_amount), 2) AS avg_order_value
FROM customer_orders
GROUP BY yer_month
ORDER BY yer_month;


-- 1.4. Top Performing Months by Order Volume
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS yer_month,
    COUNT(*) AS order_count,
    ROUND(SUM(order_amount), 2) AS total_sales
FROM customer_orders
GROUP BY yer_month
ORDER BY order_count DESC
LIMIT 5;


-- 1.5. Year-over-Year Sales Comparison
SELECT 
    YEAR(order_date) AS year,
    COUNT(*) AS order_count,
    ROUND(SUM(order_amount), 2) AS total_sales,
    ROUND(AVG(order_amount), 2) AS avg_order_value
FROM customer_orders
GROUP BY year
ORDER BY year;




-- 2. Customer Analysis:
-- 2.1. Repeat Customer Analysis
SELECT 
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS days_as_customer,
    SUM(order_amount) AS total_spent,
    AVG(order_amount) AS avg_order_value
FROM customer_orders
GROUP BY customer_id
ORDER BY total_orders DESC;

-- 2.2. Customer Order Trends Over Time
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(order_id) AS total_orders,
    SUM(order_amount) AS total_revenue,
    SUM(order_amount)/COUNT(order_id) AS average_order_value
FROM customer_orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- 2.3. Payment Method Analysis by Customer
SELECT 
    co.customer_id,
    p.payment_method,
    COUNT(p.payment_id) AS payment_count,
    SUM(p.payment_amount) AS total_payment_amount
FROM customer_orders co
JOIN payments p ON co.order_id = p.order_id
GROUP BY co.customer_id, p.payment_method
ORDER BY co.customer_id, total_payment_amount DESC;


-- 2.4. Order Status Analysis by Customer
WITH customer_status_agg AS (
    SELECT 
        customer_id,
        order_status,
        COUNT(*) AS status_count
    FROM customer_orders
    GROUP BY customer_id, order_status
),
customer_total_orders AS (
    SELECT 
        customer_id,
        COUNT(*) AS total_orders
    FROM customer_orders
    GROUP BY customer_id
)
SELECT 
    csa.customer_id,
    csa.order_status,
    csa.status_count,
    cto.total_orders,
    ROUND((csa.status_count / cto.total_orders) * 100, 2) AS status_percentage
FROM customer_status_agg csa
JOIN customer_total_orders cto ON csa.customer_id = cto.customer_id
ORDER BY csa.customer_id, csa.status_count DESC;



-- 3. Payment Status Analysis:
-- 3.1. Payment Method Distribution and Success Rates
SELECT 
    p.payment_method,
    COUNT(*) AS payment_count,
    SUM(CASE WHEN p.payment_status = 'completed' THEN 1 ELSE 0 END) AS successful_payments,
    ROUND(SUM(CASE WHEN p.payment_status = 'completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM payments p
GROUP BY p.payment_method
ORDER BY success_rate DESC;


-- 3.2. Overall Payment Status Distribution
SELECT 
    payment_status,
    COUNT(*) AS payment_count,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM payments)) * 100, 2) AS percentage,
    ROUND(SUM(payment_amount), 2) AS total_amount,
    ROUND(AVG(payment_amount), 2) AS average_amount
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC;


-- 3.3. Payment Status Trends Over Time
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m-%d') AS date,
    payment_status,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_amount), 2) AS total_amount
FROM payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m-%d'), payment_status
ORDER BY date;

SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS date,
    payment_status,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_amount), 2) AS total_amount
FROM payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m'), payment_status
ORDER BY date;


-- 3.4. Payment Method Analysis with unique customers
SELECT 
    p.payment_method,
    COUNT(*) AS payment_count,
    SUM(p.payment_amount) AS total_amount,
    AVG(p.payment_amount) AS average_amount,
    COUNT(DISTINCT co.customer_id) AS unique_customers
FROM payments p
JOIN customer_orders co ON p.order_id = co.order_id
GROUP BY p.payment_method
ORDER BY payment_count DESC;


-- 3.5. Payment Method Success Rate Analysis
SELECT 
    p.payment_method,
    payment_status,
    COUNT(*) AS payment_count,
    ROUND((COUNT(*) / t.total_method_count) * 100, 2) AS percentage_by_method,
    ROUND(SUM(payment_amount), 2) AS total_amount
FROM payments p
JOIN (
    SELECT 
        payment_method,
        COUNT(*) AS total_method_count
    FROM payments
    GROUP BY payment_method
) t ON p.payment_method = t.payment_method
GROUP BY payment_method, payment_status
ORDER BY payment_method, payment_status;




