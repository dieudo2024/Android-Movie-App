# This file implements the database connection using the mysql-connector-python library
# Use settings from config.py
# Handles connection errors with try/except and meaningful messages.

from . import config
from typing import Optional
import mysql.connector

def connect(database: Optional[str] = None):
    # Create and return a connection to the database
    try:
        connection = mysql.connector.connect(
            host=config.DB_HOST,
            user=config.DB_USER,
            password=config.DB_PASSWORD,
            database=config.DB_NAME,
        )
        return connection
    except mysql.connector.Error as error:
        raise NotImplementedError(f"Failed to connect to database: {error}")
    

def ensure_schema_exists(schema_name: str) -> None:
    # Ensures the schema exists in the database
    connection = None
    cursor = None

    try:
        connection = connect(database=None)
        cursor = connection.cursor()
        cursor.execute(f"CREATE SCHEMA IF NOT EXISTS {schema_name}")
        connection.commit()
    except mysql.connector.Error as error:
        raise NotImplementedError(f"Failed to create schema: {error}")
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()