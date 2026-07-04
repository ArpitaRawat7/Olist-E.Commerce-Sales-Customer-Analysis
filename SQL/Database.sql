--                        Creating databse
CREATE DATABASE brazilian_ecommerce;
-- Useing databse brazilian_ecommerce
USE brazilian_ecommerce;

--                Chaecking tables data records' count
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_payments;
SELECT DISTINCT(COUNT(*)) FROM order_payments;
SELECT COUNT(*) FROM order_reviews;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;
SELECT COUNT(*) FROM geolocation;


--                     Viewing records of tables
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items ORDER BY price DESC;
SELECT * FROM order_payments ORDER BY payment_sequential DESC;
SELECT * FROM order_reviews;
SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM geolocation;