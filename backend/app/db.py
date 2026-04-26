# This file implements the database connection using the mysql-connector-python library
# Use settings from config.py
# Handles connection errors with try/except and meaningful messages.

from . import config
from typing import Optional
import mysql.connector


class DatabaseError(RuntimeError):
    """Raised when a database operation fails."""


def connect(database: Optional[str] = None, include_database: bool = True):
    # Create and return a connection to the database
    connection_config = {
        "host": config.DB_HOST,
        "user": config.DB_USER,
        "password": config.DB_PASSWORD,
        "port": config.DB_PORT,
    }

    if include_database:
        connection_config["database"] = database or config.DB_NAME

    try:
        connection = mysql.connector.connect(**connection_config)
        return connection
    except mysql.connector.Error as error:
        raise DatabaseError(f"Failed to connect to database: {error}") from error
    

def ensure_schema_exists(schema_name: str) -> None:
    # Ensures the schema exists in the database
    connection = None
    cursor = None

    if not schema_name:
        raise ValueError("schema_name is required")

    try:
        connection = connect(database=None, include_database=False)
        cursor = connection.cursor()
        cursor.execute(f"CREATE SCHEMA IF NOT EXISTS `{schema_name}`")
        connection.commit()
    except (mysql.connector.Error, DatabaseError) as error:
        raise DatabaseError(f"Failed to create schema: {error}") from error
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()