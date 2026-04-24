# app/main.py
"""
Student Template (Patron)
-------------------------
FastAPI app entry point.

Rules:
- Routes must call class methods.
- Do NOT write raw SQL directly inside routes.
- Use Pydantic models for request bodies.
"""

from __future__ import annotations
from dbm import error

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel

from . import config
from .db import ensure_schema_exists, get_connection
from .student_db import StudentDatabase
from .log_analyzer import LogAnalyzer

app = FastAPI(title="Assignment 1 API")


class StudentIn(BaseModel):
    first_name: str
    last_name: str
    student_id: str
    email: str

ensure_schema_exists(config.DB1_NAME)

student_db = StudentDatabase(
    host=config.DB_HOST,
    user=config.DB_USER,
    password=config.DB_PASSWORD,
    database=config.DB1_NAME
)

student_db.create_table()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/students")
def list_students():
    try:
        return student_db.get_all_students()
    except Exception as error:
        raise NotImplementedError(f"Failed to retrieve students: {error}")


@app.get("/students/{student_id}")
def get_student(student_id: str):
    try:
        student = student_db.get_student_by_id(student_id)

        if student is None:
            raise HTTPException(status_code=404, detail="Student not found")
        return student 
    except Exception as error:
        raise NotImplementedError(f"Failed to retrieve student: {error}")


@app.post("/students")
def create_student(payload: StudentIn):
    try:
        inserted = student_db.insert_students([payload.dict()])

        if inserted != 1:
            raise HTTPException(status_code=400, detail="Failed to insert student")
        return student_db.get_student_by_id(payload.student_id)
    except Exception as error:
        raise NotImplementedError(f"Failed to create student: {error}")


@app.delete("/students/{student_id}")
def delete_student(student_id: str):
    try:
        deleted = student_db.delete_student(student_id)

        if not deleted:
            raise HTTPException(status_code=404, detail="Student not found")
        return {"deleted": "Student deleted successfully"}
    except Exception as error:
        raise NotImplementedError(f"Failed to delete student: {error}")

# 1. Create the connection first (This defines log_conn)
# RIGHT (Sending only the database name as the template expects)
log_conn = get_connection(database=config.DB2_NAME)

# 2. Now pass that connection to the LogAnalyzer
log_analyzer = LogAnalyzer(
    conn=log_conn,
    table_name="logs"
)

@app.get("/logs/count")
def logs_count(date: str = Query(..., description="YYYY-MM-DD")):
    try:
        # Calls class method to count logs for a specific day
        result = log_analyzer.count_logs_by_date(date)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


@app.get("/logs/levels")
def logs_levels():
    try:
        # Calls class method to get unique log levels
        levels = log_analyzer.distinct_levels()
        return levels
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


@app.get("/logs/critical")
def logs_critical():
    try:
        # Calls class method to get Critical logs grouped by Source
        critical_data = log_analyzer.critical_by_source()
        return critical_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


@app.get("/logs/hardware")
def logs_hardware():
    try:
        # Calls class method to find logs mentioning 'hardware'
        hardware_data = log_analyzer.hardware_logs()
        return hardware_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")