-- =====================================================
-- Weekly Assignment – MySQL
-- Assignment 1: Database Fundamentals and Table Design
-- Done by Pranav Jahagirdar
-- =====================================================




-- =========================
-- Part A: Theory
-- =========================

-- 1. What is a database in MySQL? Why is it important to organize data into databases?
-- A database in MySQL is a structured collection of data stored electronically
-- so that it can be easily accessed, managed, and updated using SQL.
-- Organizing data into databases helps keep information structured, reduces
-- redundancy, improves data security, and makes it easier to retrieve and
-- maintain large amounts of information.

-- 2. Explain the difference between INT and BIGINT. When would you prefer one over the other?
-- INT and BIGINT are numeric data types used to store whole numbers.
-- INT stores numbers roughly from -2 billion to +2 billion.
-- BIGINT stores much larger numbers up to around ±9 quintillion.
-- INT is preferred for normal values like IDs or counts, while BIGINT is used
-- when very large numbers need to be stored.

-- 3. What is a PRIMARY KEY? Mention two rules that a primary key must follow.
-- A PRIMARY KEY is a column that uniquely identifies each row in a table.
-- Two rules for a primary key are:
-- 1) The value must be unique for every record.
-- 2) It cannot contain NULL values.

-- 4. Differentiate between CHAR and VARCHAR with one practical example.
-- CHAR stores fixed-length text, while VARCHAR stores variable-length text.
-- Example: If we store "HR"
-- CHAR(10) will store "HR" plus extra spaces to fill 10 characters.
-- VARCHAR(10) will store only "HR" without extra spaces.

-- 5. What is the purpose of NOT NULL and UNIQUE constraints?
-- NOT NULL ensures that a column must always have a value and cannot be empty.
-- UNIQUE ensures that all values in a column are different and duplicates are not allowed.
-- These constraints help maintain data accuracy and integrity.




-- =========================
-- Part B: SQL Coding
-- =========================


-- 1. Create a database named company_db
CREATE DATABASE company_db;


-- 2. Display all available databases
SHOW DATABASES;


-- 3. Switch to the company_db database
USE company_db;


-- 4. Create a table named employees
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department CHAR(10),
    salary INT,
    joining_date DATE,
    created_at DATETIME
);


-- 5. Insert at least 5 employee records
INSERT INTO employees VALUES
(101, 'A', 'a@email.com', 'HR', 45000, '2022-05-10', '2022-05-10 09:00:00'),
(102, 'B', 'b@email.com', 'Finance', 52000, '2021-08-15', '2021-08-15 10:30:00'),
(103, 'C', 'c@email.com', 'IT', 60000, '2023-01-20', '2023-01-20 11:15:00'),
(104, 'D', 'd@email.com', 'Marketing', 48000, '2022-11-05', '2022-11-05 08:45:00'),
(105, 'E', 'e@email.com', 'Sales', 50000, '2020-07-18', '2020-07-18 09:20:00');


-- 6. Display all records from the employees table
SELECT * FROM employees;


-- 7. Verify the table structure
DESCRIBE employees;


-- 8. Drop the table employees
DROP TABLE employees;


-- 9. Drop the database company_db
DROP DATABASE company_db;