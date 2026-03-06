-- ============================================
-- Weekly Assignment – MySQL
-- Assignment 2: Student Record Management System
-- Done by Pranav Jahagirdar
-- ============================================




-- -------------------------
-- Part A: Theory Answers
-- -------------------------

-- 1. What is the difference between DATE and DATETIME?
-- DATE stores only the date (year, month, day).
-- Example: 2003-07-15
-- DATETIME stores both date and time (year, month, day, hour, minute, second).
-- Example: 2026-03-06 18:30:00
-- DATE is used when only the date is needed, while DATETIME is used when both date and time are required.


-- 2. Why should email or phone number fields often be marked as UNIQUE?
-- Email and phone numbers are usually used to identify a specific person.
-- Using the UNIQUE constraint prevents duplicate values from being stored in that column.
-- This helps maintain data accuracy and avoids multiple records with the same contact information.


-- 3. Can a table have multiple UNIQUE constraints? Explain.
-- Yes, a table can have multiple UNIQUE constraints.
-- Different columns can each have a UNIQUE constraint.
-- For example, both email and phone_number can be unique so that duplicates are not allowed in either column.


-- 4. What happens if you try to insert a NULL value into a NOT NULL column?
-- The database will generate an error and the record will not be inserted.
-- This happens because NOT NULL columns require a value to be provided.


-- 5. Why is proper data type selection important while designing tables?
-- Proper data types help store data correctly and efficiently.
-- They improve performance, reduce storage usage, and ensure that values follow the correct format.
-- For example, DATE ensures valid date values and INT stores numeric values efficiently.





-- -------------------------
-- Part B: SQL Coding
-- -------------------------

-- 1. Create a database named student_db
CREATE DATABASE student_db;

-- 2. Show all databases
SHOW DATABASES;

-- Switch to the created database
USE student_db;


-- 3. Create students table
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number BIGINT,
    course VARCHAR(30),
    date_of_birth DATE,
    registration_date DATETIME
);


-- 4. Insert at least 5 student records
INSERT INTO students VALUES
(1, 'A', 'a@gmail.com', 9876543210, 'Computer Science', '2003-05-12', '2026-03-01 10:15:00');

INSERT INTO students VALUES
(2, 'B', 'b@gmail.com', 9123456780, 'Information Technology', '2002-11-25', '2026-03-02 11:30:00');

INSERT INTO students VALUES
(3, 'C', 'c@gmail.com', 9988776655, 'Artificial Intelligence', '2003-01-18', '2026-03-03 09:45:00');

INSERT INTO students VALUES
(4, 'D', 'd@gmail.com', 9012345678, 'Data Science', '2002-08-10', '2026-03-04 14:20:00');

INSERT INTO students VALUES
(5, 'E', 'e@gmail.com', 9098765432, 'Cyber Security', '2003-03-30', '2026-03-05 16:10:00');


-- 5. Display all records from the students table
SELECT * FROM students;


-- 6. Verify table structure
DESCRIBE students;


-- 7. Drop the database
DROP DATABASE student_db;