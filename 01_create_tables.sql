-- ============================================
-- SUNRISE SUPERMARKET
-- Assignment One
-- Database: MySQL
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS sunrise_supermarket;

-- Select database
USE sunrise_supermarket;


-- ============================================
-- CUSTOMERS TABLE
-- ============================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);


-- ============================================
-- PRODUCTS TABLE
-- ============================================

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);


-- ============================================
-- ORDERS TABLE
-- ============================================

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- ============================================
-- ORDER ITEMS TABLE
-- ============================================

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);