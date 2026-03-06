-- ============================================
-- Minor Project – MySQL
-- Minor Project: Student Course Management System
-- Done by Pranav Jahagirdar
-- ============================================




-- 1. Create the database
CREATE DATABASE student_course_db;

-- 2. Select the database to work with
USE student_course_db;


-- 3. Create the students table with required columns and constraints
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number BIGINT UNIQUE,
    course_name VARCHAR(30),
    date_of_birth DATE,
    registration_date DATETIME
);


-- 4. Insert simple student records
INSERT INTO students VALUES
(1,'A','a@gmail.com',001,'CS','2000-01-01','2026-01-01 10:00:00'),
(2,'B','b@gmail.com',002,'AI','2000-02-01','2026-01-02 10:00:00'),
(3,'C','c@gmail.com',003,'DS','2000-03-01','2026-01-03 10:00:00'),
(4,'D','d@gmail.com',004,'CS','2000-04-01','2026-01-04 10:00:00'),
(5,'E','e@gmail.com',005,'IT','2000-05-01','2026-01-05 10:00:00'),
(6,'F','f@gmail.com',006,'AI','2000-06-01','2026-01-06 10:00:00'),
(7,'Z','z@gmail.com',007,'DS','2000-07-01','2026-01-07 10:00:00'),
(8,'H','h@gmail.com',008,'CS','2000-08-01','2026-01-08 10:00:00'),
(9,'I','i@gmail.com',009,'IT','2000-09-01','2026-01-09 10:00:00'),
(10,'J','j@gmail.com',010,'AI','2000-10-01','2026-01-10 10:00:00'),
(11,'K','k@gmail.com',011,'DS','2000-11-01','2026-01-11 10:00:00'),
(12,'L','l@gmail.com',012,'CS','2000-12-01','2026-01-12 10:00:00'),
(13,'M','m@gmail.com',013,'IT','2000-01-15','2026-01-13 10:00:00'),
(14,'N','n@gmail.com',014,'AI','2000-02-15','2026-01-14 10:00:00'),
(15,'O','o@gmail.com',015,'DS','2000-03-15','2026-01-15 10:00:00'),
(16,'P','p@gmail.com',016,'CS','2000-04-15','2026-01-16 10:00:00'),
(17,'Q','q@gmail.com',017,'IT','2000-05-15','2026-01-17 10:00:00'),
(18,'R','r@gmail.com',018,'AI','2000-06-15','2026-01-18 10:00:00'),
(19,'S','s@gmail.com',019,'DS','2000-07-15','2026-01-19 10:00:00'),
(20,'T','t@gmail.com',020,'CS','2000-08-15','2026-01-20 10:00:00');


-- 5. Display all records from the table
SELECT * FROM students;