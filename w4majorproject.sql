-- ============================================
-- Major Project – MySQL
-- Instacart Online Grocery Basket Analysis
-- Done by Pranav Jahagirdar
-- ============================================


-- 1. Create database
CREATE DATABASE instacart_db;

-- 2. Use database
USE instacart_db;



-- =====================================================
-- SECTION A
-- =====================================================

-- 1. Create backup table
CREATE TABLE product_backup LIKE products;

-- 2. Insert manual records
INSERT INTO product_backup VALUES
(1,'Sample Product 1',1,1),
(2,'Sample Product 2',2,2),
(3,'Sample Product 3',3,3);

-- 3. Update product names
UPDATE products
SET product_name = CONCAT(product_name,'_new')
WHERE department_id = 1;

-- 4. Delete products
DELETE FROM products
WHERE product_id > 50000;

-- 5. Orders between day 1 and 3
SELECT *
FROM orders
WHERE order_dow BETWEEN 1 AND 3;

-- 6. Products starting with A
SELECT *
FROM products
WHERE product_name LIKE 'A%';

-- 7. Orders excluding early hours
SELECT *
FROM orders
WHERE order_hour_of_day NOT IN (0,1,2,3);

-- 8. Top 15 products
SELECT *
FROM products
LIMIT 15;

-- 9. Aggregate values
SELECT 
MIN(order_hour_of_day) AS min_hour,
MAX(order_hour_of_day) AS max_hour,
AVG(order_hour_of_day) AS avg_hour,
COUNT(order_id) AS total_orders,
SUM(days_since_prior_order) AS total_days
FROM orders;

-- 10. Orders between 5 and 10 days gap
SELECT *
FROM orders
WHERE days_since_prior_order BETWEEN 5 AND 10;



-- =====================================================
-- SECTION B
-- =====================================================

-- 11. Products per department
SELECT department_id, COUNT(*) AS total_products
FROM products
GROUP BY department_id;

-- 12. Products per aisle
SELECT aisle_id, COUNT(*) AS total_products
FROM products
GROUP BY aisle_id;

-- 13. Orders per user
SELECT user_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY user_id;

-- 14. Departments with more than 500 products
SELECT department_id, COUNT(*) AS total_products
FROM products
GROUP BY department_id
HAVING COUNT(*) > 500;

-- 15. Average days per user
SELECT user_id, AVG(days_since_prior_order) AS avg_days
FROM orders
GROUP BY user_id;

-- 16. Total reordered items per product
SELECT product_id, SUM(reordered) AS total_reordered
FROM order_products
GROUP BY product_id;

-- 17. Departments with more than 1000 products
SELECT department_id, COUNT(*) AS total_products
FROM products
GROUP BY department_id
HAVING COUNT(*) > 1000;



-- =====================================================
-- SECTION C
-- =====================================================

-- 18. Product, aisle, department
SELECT p.product_name, a.aisle, d.department
FROM products p
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id;

-- 19. Order details with product
SELECT o.order_id, o.user_id, p.product_name
FROM orders o
JOIN order_products op ON o.order_id = op.order_id
JOIN products p ON op.product_id = p.product_id;

-- 20. Department with product count
SELECT d.department, COUNT(p.product_id) AS total_products
FROM departments d
JOIN products p ON d.department_id = p.department_id
GROUP BY d.department;

-- 21. All aisles even without products
SELECT a.aisle, p.product_name
FROM aisles a
LEFT JOIN products p ON a.aisle_id = p.aisle_id;

-- 22. Total products purchased per user
SELECT o.user_id, COUNT(op.product_id) AS total_products
FROM orders o
JOIN order_products op ON o.order_id = op.order_id
GROUP BY o.user_id;



-- =====================================================
-- SECTION D
-- =====================================================

-- 23. Products ordered per department
SELECT d.department, COUNT(op.product_id) AS total_orders
FROM departments d
JOIN products p ON d.department_id = p.department_id
JOIN order_products op ON p.product_id = op.product_id
GROUP BY d.department;

-- 24. Top 5 most ordered products
SELECT p.product_name, COUNT(op.product_id) AS total_orders
FROM products p
JOIN order_products op ON p.product_id = op.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC
LIMIT 5;

-- 25. Total reordered per department
SELECT d.department, SUM(op.reordered) AS total_reordered
FROM departments d
JOIN products p ON d.department_id = p.department_id
JOIN order_products op ON p.product_id = op.product_id
GROUP BY d.department;

-- 26. Distinct products per aisle
SELECT a.aisle, COUNT(DISTINCT op.product_id) AS total_products
FROM aisles a
JOIN products p ON a.aisle_id = p.aisle_id
JOIN order_products op ON p.product_id = op.product_id
GROUP BY a.aisle;

-- 27. Reordered items per user
SELECT o.user_id, SUM(op.reordered) AS total_reordered
FROM orders o
JOIN order_products op ON o.order_id = op.order_id
GROUP BY o.user_id;

-- 28. Avg products per order per department
SELECT d.department, AVG(op.add_to_cart_order) AS avg_products
FROM departments d
JOIN products p ON d.department_id = p.department_id
JOIN order_products op ON p.product_id = op.product_id
GROUP BY d.department;

-- 29. Busiest hour
SELECT order_hour_of_day, COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC
LIMIT 1;

-- 30. Weekend orders per department
SELECT d.department, COUNT(op.product_id) AS total_orders
FROM departments d
JOIN products p ON d.department_id = p.department_id
JOIN order_products op ON p.product_id = op.product_id
JOIN orders o ON op.order_id = o.order_id
WHERE o.order_dow IN (0,6)
GROUP BY d.department;

-- 31. Unique products per user
SELECT o.user_id, COUNT(DISTINCT op.product_id) AS unique_products
FROM orders o
JOIN order_products op ON o.order_id = op.order_id
GROUP BY o.user_id;

-- 32. Top 3 departments by reordered items
SELECT d.department, SUM(op.reordered) AS total_reordered
FROM departments d
JOIN products p ON d.department_id = p.department_id
JOIN order_products op ON p.product_id = op.product_id
GROUP BY d.department
ORDER BY total_reordered DESC
LIMIT 3;