DROP DATABASE IF EXISTS retail_db;
CREATE DATABASE retail_db;
USE retail_db;

-- 1. Category Table
CREATE TABLE category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Product Table
CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_qty INT NOT NULL,
    reorder_level INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- 3. Customer Table
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    reg_date DATE NOT NULL
);

-- 4. Orders Table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    status ENUM('PLACED', 'SHIPPED', 'DELIVERED', 'CANCELLED') NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- 5. Order Item Table (Composite PK)
CREATE TABLE order_item (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 6. Payment Table
CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    method ENUM('UPI', 'CARD', 'COD', 'NETBANKING') NOT NULL,
    status ENUM('SUCCESS', 'FAILED', 'PENDING') NOT NULL,
    paid_on DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 7. Review Table
CREATE TABLE review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATETIME NOT NULL,
    UNIQUE (customer_id, product_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 8. Stock Alert Table
CREATE TABLE stock_alert (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    stock_at_alert INT NOT NULL,
    alert_time DATETIME NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- Categories
INSERT INTO category (category_name) VALUES 
('Electronics'), ('Books'), ('Fashion'), ('Home Goods');

-- Products
INSERT INTO product (product_name, category_id, price, stock_qty, reorder_level) VALUES 
('Smartphone Pro', 1, 45000.00, 15, 10),
('Wireless Earbuds', 1, 3500.00, 8, 15),
('Python Programming', 2, 850.00, 25, 5),
('Sci-Fi Epic Novel', 2, 450.00, 40, 10),
('Designer Kurti', 3, 1200.00, 30, 8),
('Running Shoes', 3, 5500.00, 12, 10),
('Non-Stick Cookware Set', 4, 3200.00, 5, 10),
('Wireless Mouse', 1, 1500.00, 50, 10);

-- Customers
INSERT INTO customer (name, email, phone, city, state, reg_date) VALUES 
('Rahul Verma', 'rahul.v@gmail.com', '9876543210', 'Mumbai', 'Maharashtra', '2025-11-15'),
('Priya Nair', 'priya.nair@yahoo.com', '9123456789', 'Bengaluru', 'Karnataka', '2026-05-10'),
('Amit Patel', 'amit.patel@outlook.com', '9988776655', 'Ahmedabad', 'Gujarat', '2026-07-20'),
('Sneha Reddy', 'sneha.r@gmail.com', '9765432109', 'Hyderabad', 'Telangana', '2026-08-01'),
('Ananya Sharma', 'ananya.s@gmail.com', '9555443322', 'Delhi', 'Delhi', '2026-09-15');

-- Orders
INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES 
(1, '2026-05-12 14:30:00', 'DELIVERED', 45850.00),
(2, '2026-06-15 10:15:00', 'DELIVERED', 6700.00),
(3, '2026-08-10 18:45:00', 'CANCELLED', 3200.00),
(4, '2026-09-05 11:20:00', 'SHIPPED', 5500.00),
(1, '2026-09-25 16:00:00', 'PLACED', 1200.00);

-- Order Items
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES 
(1, 1, 1, 45000.00),
(1, 3, 1, 850.00),
(2, 6, 1, 5500.00),
(2, 4, 2, 600.00),
(3, 7, 1, 3200.00),
(4, 6, 1, 5500.00),
(5, 5, 1, 1200.00);

-- Payments
INSERT INTO payment (order_id, method, status, paid_on) VALUES 
(1, 'CARD', 'SUCCESS', '2026-05-12 14:35:00'),
(2, 'UPI', 'SUCCESS', '2026-06-15 10:20:00'),
(3, 'NETBANKING', 'FAILED', NULL),
(4, 'UPI', 'SUCCESS', '2026-09-05 11:25:00'),
(5, 'COD', 'PENDING', NULL);

-- Reviews
INSERT INTO review (customer_id, product_id, rating, comment, review_date) VALUES 
(1, 1, 5, 'Amazing smartphone performance!', '2026-05-15 10:00:00'),
(2, 6, 4, 'Very comfortable running shoes.', '2026-06-20 12:00:00'),
(4, 6, 5, 'Best shoes I have worn.', '2026-09-10 14:00:00');

-- Query 1: List all products with price above ₹5,000, sorted by price (highest first)
SELECT product_id, product_name, price, stock_qty 
FROM product 
WHERE price > 5000.00 
ORDER BY price DESC;

-- Query 2: Show customers who registered in the last 6 months (relative to Oct 2026)
SELECT customer_id, name, email, city, state, reg_date 
FROM customer 
WHERE reg_date >= DATE_SUB('2026-10-21', INTERVAL 6 MONTH)
ORDER BY reg_date DESC;

-- Query 3: Count customers in each state
SELECT state, COUNT(customer_id) AS customer_count 
FROM customer 
GROUP BY state 
ORDER BY customer_count DESC;

-- Query 4: Show monthly revenue and a cumulative revenue column
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS monthly_rev
    FROM orders
    WHERE status != 'CANCELLED'
    GROUP BY sales_month
)
SELECT 
    sales_month,
    monthly_rev,
    SUM(monthly_rev) OVER (ORDER BY sales_month) AS cumulative_revenue
FROM monthly_sales
ORDER BY sales_month;

-- 4. Stored Function: Customer Lifetime Spend Tier
DELIMITER //

CREATE FUNCTION GetCustomerTier(p_customer_id INT) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE total_spend DECIMAL(12,2);
    DECLARE tier VARCHAR(20);

    -- Calculate spend on non-cancelled orders
    SELECT COALESCE(SUM(total_amount), 0) 
    INTO total_spend 
    FROM orders 
    WHERE customer_id = p_customer_id AND status != 'CANCELLED';

    IF total_spend >= 100000.00 THEN
        SET tier = 'PLATINUM';
    ELSEIF total_spend >= 50000.00 THEN
        SET tier = 'GOLD';
    ELSEIF total_spend >= 10000.00 THEN
        SET tier = 'SILVER';
    ELSE
        SET tier = 'BASIC';
    END IF;

    RETURN tier;
END //

DELIMITER ;

-- Example usage:
-- SELECT name, GetCustomerTier(customer_id) AS tier FROM customer;

-- 5. View: Top-Selling Category in Each State
CREATE VIEW vw_top_category_by_state AS
WITH state_category_sales AS (
    SELECT 
        c.state,
        cat.category_name,
        SUM(oi.quantity * oi.unit_price) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY c.state ORDER BY SUM(oi.quantity * oi.unit_price) DESC) as rn
    FROM customer c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_item oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    JOIN category cat ON p.category_id = cat.category_id
    WHERE o.status != 'CANCELLED'
    GROUP BY c.state, cat.category_name
)
SELECT state, category_name, total_sales
FROM state_category_sales
WHERe rn = 1;

-- Example usage:
-- SELECT * FROM vw_top_category_by_state;

-- 6. Trigger: Stock Replenishment Alert
DELIMITER //

CREATE TRIGGER trg_check_stock_alert
AFTER UPDATE ON product
FOR EACH ROW
BEGIN
    -- If stock drops below or equals reorder level and wasn't already below it
    IF NEW.stock_qty < NEW.reorder_level AND OLD.stock_qty >= OLD.reorder_level THEN
        INSERT INTO stock_alert (product_id, stock_at_alert, alert_time)
        VALUES (NEW.product_id, NEW.stock_qty, NOW());
    END IF;
END //

DELIMITER ;