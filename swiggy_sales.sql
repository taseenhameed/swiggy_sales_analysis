--create database swiggysales
use swiggysales
select * from swiggy_sales_orders;
select * from swiggy_restaurants;


-- ============================================================
-- Swiggy Sales Analysis - T-SQL (SQL Server) Business Questions
-- Database: SwiggySales (run setup_swiggy_sqlserver.sql first)
-- Tables: orders (order-level), restaurants (restaurant-level)
-- ============================================================

 
-- Total revenue, orders, and average order value (delivered only)
SELECT
    COUNT(*) AS total_orders,
    SUM(final_amount) AS total_revenue,
    ROUND(AVG(final_amount), 2) AS avg_order_value
FROM swiggy_sales_orders
WHERE order_status = 'Delivered';

-- FINDING: 3,972 delivered orders generated ~₹27.53L total revenue, at an average order value of ₹693.--

-- Monthly revenue trend --
SELECT
    FORMAT(order_date, 'yyyy-MM') AS [month],
    SUM(final_amount) AS revenue
FROM swiggy_sales_orders
WHERE order_status = 'Delivered'
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY [month];

-- FINDING:Revenue ranged from ₹1.92L (May, lowest) to ₹2.76L (December, highest),
--with December ~44% higher than May. No single month dominates disproportionately.


-- Top 10 restaurants by revenue --
SELECT TOP 10
    r.restaurant_name,
    r.city,
    SUM(o.final_amount) AS revenue
FROM swiggy_sales_orders o
JOIN swiggy_restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_name, r.city
ORDER BY revenue DESC;

-- FINDING: Top 10 restaurants are led by "Spice Junction 28" and "Wok This Way 47"(both Ahmedabad,~₹71K each).
--Revenue is spread fairly evenly across the top 10(₹61K-71K range),
--meaning growth relies on many mid-size performers rather than one dominant outlet.

-- Revenue and order share by city
SELECT r.city,
    COUNT(*) AS total_orders,
    SUM(o.final_amount) AS revenue,
    ROUND(SUM(o.final_amount) * 100.0 /
        (SELECT SUM(final_amount) FROM swiggy_sales_orders WHERE order_status = 'Delivered'), 2) AS pct_of_total_revenue
FROM swiggy_sales_orders o
JOIN swiggy_restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.city
ORDER BY revenue DESC;
-- FINDING: Hyderabad leads with 18.6% of total revenue; Jaipur trails at 3.5%.
-- The top 3 cities (Hyderabad, Pune, Chennai) together drive ~46% of revenue,
-- suggesting marketing/operations spend should prioritize these markets.


-- Revenue by cuisine type
SELECT
    cuisine,
    COUNT(*) AS total_orders,
    ROUND(SUM(final_amount),1) AS revenue
FROM swiggy_sales_orders 
--JOIN swiggy_restaurants r ON o.restaurant_id = r.restaurant_id
WHERE order_status = 'Delivered'
GROUP BY cuisine
ORDER BY revenue DESC;
-- FINDING: Continental leads cuisine revenue (₹5.08L); Italian is lowest (₹1.44L).
-- Continental and Desserts also carry the highest average order values (~₹710-730),
-- indicating these categories skew toward higher-ticket orders.


--Cancellation rate by city
SELECT
    r.city,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM swiggy_sales_orders o
JOIN swiggy_restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY cancellation_rate_pct DESC;
-- FINDING: Cancellation rates range 17.6% (Ahmedabad) to 23.1% (Pune), averaging ~20%
-- across all cities. A ~20% cancellation rate is high for food delivery and would be
-- the top flagged issue in a real analysis - worth investigating root causes
-- (payment failures, restaurant unavailability, etc.).


-- Busiest day of week
SELECT
    DATENAME(WEEKDAY, order_date) AS day_of_week,
    COUNT(*) AS total_orders,
    SUM(final_amount) AS revenue
FROM swiggy_sales_orders
WHERE order_status = 'Delivered'
GROUP BY DATENAME(WEEKDAY, order_date)
ORDER BY total_orders DESC;
-- FINDING: Tuesday is busiest (632 orders, ₹4.2L revenue); Friday is lowest
-- (521 orders). Order volume is fairly flat across the week (521-632 range),
-- with no dramatic weekend spike.

-- Month-over-month revenue growth rate (window function)
WITH monthly AS (
    SELECT
        FORMAT(order_date, 'yyyy-MM') AS [month],
        SUM(final_amount) AS revenue
    FROM swiggy_sales_orders
    WHERE order_status = 'Delivered'
    GROUP BY FORMAT(order_date, 'yyyy-MM')
)
SELECT
    [month],
    revenue,
    LAG(revenue) OVER (ORDER BY [month]) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY [month])) * 100.0
        / LAG(revenue) OVER (ORDER BY [month]), 2
    ) AS mom_growth_pct
FROM monthly
ORDER BY [month];
-- FINDING: Month-over-month growth swung from -22.4% (April) to +31.2% (December),
-- showing high volatility rather than a steady trend. Good example query to
-- highlight LAG() window function skills in interviews.

--Top restaurant per city (window function - RANK)
WITH ranked AS (
    SELECT
        r.city,
        r.restaurant_name,
        SUM(o.final_amount) AS revenue,
        RANK() OVER (PARTITION BY r.city ORDER BY SUM(o.final_amount) DESC) AS rnk
    FROM swiggy_sales_orders o
    JOIN swiggy_restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.order_status = 'Delivered'
    GROUP BY r.city, r.restaurant_name
)
SELECT city, restaurant_name, revenue
FROM ranked
WHERE rnk = 1
ORDER BY revenue DESC;
-- FINDING: Each city has one clear top-performing restaurant, e.g. "Spice Junction 28"
-- in Ahmedabad and "Curry Leaf 49" in Pune. Demonstrates RANK() for "best performer
-- per segment" logic - a common real-world analyst pattern.