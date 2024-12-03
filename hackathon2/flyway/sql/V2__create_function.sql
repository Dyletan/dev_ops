CREATE OR REPLACE FUNCTION get_student_with_courses(p_student_id INT)
RETURNS TABLE(
    student_id INT,
    student_name VARCHAR,
    course_id INT,
    course_name VARCHAR,
    enrolled_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id AS student_id,
        s.name AS student_name,
        c.id AS course_id,
        c.name AS course_name,
        e.enrolled_at
    FROM students s
    LEFT JOIN enrollments e ON s.id = e.student_id
    LEFT JOIN courses c ON e.course_id = c.id
    WHERE s.id = p_student_id;
END;
$$ LANGUAGE plpgsql;