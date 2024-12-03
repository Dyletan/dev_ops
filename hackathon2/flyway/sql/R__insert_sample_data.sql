-- Clear existing data 
TRUNCATE TABLE enrollments RESTART IDENTITY CASCADE; 
TRUNCATE TABLE courses RESTART IDENTITY CASCADE; 
TRUNCATE TABLE students RESTART IDENTITY CASCADE; 

-- Savoskin said that delete is preferd, but need to test
-- DELETE FROM enrollments;
-- DELETE FROM courses;
-- DELETE FROM students;

-- -- Reset sequences for auto-increment fields
-- ALTER SEQUENCE students_id_seq RESTART WITH 1;
-- ALTER SEQUENCE courses_id_seq RESTART WITH 1;
-- ALTER SEQUENCE enrollments_id_seq RESTART WITH 1;

-- Insert sample data 
INSERT INTO students (name, age) VALUES 
    ('Alice Johnson', 20), 
    ('Bob Smith', 22), 
    ('Charlie Brown', 19), 
    ('Diana Prince', 21), 
    ('Evan Wright', 23); 
 
INSERT INTO courses (name, description) VALUES 
    ('Introduction to Programming', 'Learn the basics of programming using Python.'), 
    ('Data Structures', 'Study fundamental data structures such as lists, stacks, and queues.'), 
    ('Web Development', 'Understand how to build web applications using modern frameworks.'), 
    ('Databases', 'Learn about relational and non-relational databases.'), 
    ('Machine Learning', 'An introductory course on machine learning concepts and algorithms.'); 
 
INSERT INTO enrollments (student_id, course_id, enrolled_at) VALUES 
    (1, 1, '2023-10-01 10:00:00'), 
    (1, 2, '2023-10-02 11:00:00'), 
    (2, 3, '2023-10-01 12:00:00'), 
    (3, 1, '2023-10-03 14:00:00'), 
    (3, 4, '2023-10-04 15:00:00'), 
    (4, 5, '2023-10-05 16:00:00'), 
    (5, 3, '2023-10-06 17:00:00');