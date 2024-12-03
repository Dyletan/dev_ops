import pydantic
from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager
from pydantic_settings import BaseSettings
import asyncpg


class Settings(BaseSettings):
    db_user: str = pydantic.Field(default="postgres")
    db_password: str = pydantic.Field(default="postgres")
    db_name: str = pydantic.Field(default="postgres")
    db_host: str = pydantic.Field(default="localhost")
    db_port: int = pydantic.Field(default="5434")


settings = Settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.db_pool = await asyncpg.create_pool(
        user=settings.db_user,
        password=settings.db_password,
        database=settings.db_name,
        host=settings.db_host,
        port=settings.db_port,
    )
    try:
        yield
    finally:
        await app.state.db_pool.close()


app = FastAPI(
    lifespan=lifespan,
    docs_url="/docs",
)


@app.get("/students/{student_id}/courses")
async def get_student_courses(student_id: int):
    """
    Get a student's details and their enrolled courses.
    """
    query = "SELECT * FROM get_student_with_courses($1)"
    async with app.state.db_pool.acquire() as conn:
        rows = await conn.fetch(query, student_id)
    if not rows:
        raise HTTPException(status_code=404, detail="Student not found")
    return [dict(row) for row in rows]


@app.post("/students")
async def create_student(name: str, age: int):
    """
    Add a new student.
    """
    query = "INSERT INTO students (name, age) VALUES ($1, $2) RETURNING id, name, age"
    async with app.state.db_pool.acquire() as conn:
        row = await conn.fetchrow(query, name, age)
    return dict(row)


@app.get("/students")
async def list_students():
    """
    Get a list of all students.
    """
    query = "SELECT id, name, age FROM students"
    async with app.state.db_pool.acquire() as conn:
        rows = await conn.fetch(query)
    return [dict(row) for row in rows]


@app.post("/courses")
async def create_course(name: str, description: str):
    """
    Add a new course.
    """
    query = "INSERT INTO courses (name, description) VALUES ($1, $2) RETURNING id, name, description"
    async with app.state.db_pool.acquire() as conn:
        row = await conn.fetchrow(query, name, description)
    return dict(row)


@app.get("/courses")
async def list_courses():
    """
    Get a list of all courses.
    """
    query = "SELECT id, name, description FROM courses"
    async with app.state.db_pool.acquire() as conn:
        rows = await conn.fetch(query)
    return [dict(row) for row in rows]


@app.post("/enrollments")
async def enroll_student_in_course(student_id: int, course_id: int):
    """
    Enroll a student in a course.
    """
    query = """
    INSERT INTO enrollments (student_id, course_id)
    VALUES ($1, $2) RETURNING id, student_id, course_id, enrolled_at
    """
    async with app.state.db_pool.acquire() as conn:
        row = await conn.fetchrow(query, student_id, course_id)
    if not row:
        raise HTTPException(status_code=400, detail="Enrollment failed")
    return dict(row)


@app.get("/enrollments")
async def list_enrollments():
    """
    Get a list of all enrollments.
    """
    query = """
    SELECT e.id, s.name AS student_name, c.name AS course_name, e.enrolled_at
    FROM enrollments e
    JOIN students s ON e.student_id = s.id
    JOIN courses c ON e.course_id = c.id
    """
    async with app.state.db_pool.acquire() as conn:
        rows = await conn.fetch(query)
    return [dict(row) for row in rows]
