import mysql.connector
from typing import Any, Dict, List, Optional, Sequence

class MovieDatabase:
    def __init__(self, host: str, user: str, password: str, database: str):
        try:
            self.connection = mysql.connector.connect(
                host=host,
                user=user,
                password=password,
                database=database
            )
            self.cursor = self.connection.cursor(dictionary=True)

            self.cursor.execute(f"CREATE DATABASE IF NOT EXISTS {database};")
            self.cursor.execute(f"USE {database};")
            
        except mysql.connector.Error as error:
            raise NotImplementedError(f"Failed to connect to database: {error}")

    def create_table(self) -> None:
        try:
            sql = """
            CREATE TABLE IF NOT EXISTS movies (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                category VARCHAR(255) NOT NULL,
                director VARCHAR(255) NOT NULL,
                year INT NOT NULL,
                rating FLOAT NOT NULL CHECK (rating >= 0.0 AND rating <= 10.0),
                description TEXT NULL,
                synopsis VARCHAR(255) NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );
            """

            self.cursor.execute(sql)
            self.connection.commit()
        
        except mysql.connector.Error as error:
            print(f"Error creating movies table: {error}")
            raise NotImplementedError(f"Failed to create movies table: {error}")
    
    def insert_movies(self, rows: Sequence[Dict[str, Any]]) -> int:
        
        if not rows:
            return 0
        
        try:
            sql = """
            INSERT INTO movies (title, category, director, year, rating, description, synopsis)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
            """

            values = [
                (
                    row['title'],
                    row['category'],
                    row['director'],
                    row['year'],
                    row['rating'],
                    row.get('description'),
                    row.get('synopsis')
                )
                for row in rows
            ]

            self.cursor.executemany(sql, values)
            self.connection.commit()

            return self.cursor.rowcount
        except mysql.connector.Error as error:
            raise NotImplementedError(f"Failed to insert movies: {error}")

    def get_all_movies(self) -> List[Dict[str, Any]]:
        try:
            self.cursor.execute("SELECT * FROM movies;")
            return self.cursor.fetchall()
        except mysql.connector.Error as error:
            raise NotImplementedError(f"Failed to retrieve movies: {error}")
        
    def get_movie_by_id(self, movie_id: int) -> Optional[Dict[str, Any]]:
        try:
            query = "SELECT * FROM movies WHERE id = %s;"
            self.cursor.execute(query, (movie_id,))
            return self.cursor.fetchone()
        except mysql.connector.Error as error:
            raise NotImplementedError(f"Failed to retrieve movie by ID: {error}")
        
    def close(self) -> None:
        try:
            if self.cursor:
                self.cursor.close()
            if self.connection:
                self.connection.close()
        except mysql.connector.Error as error:
            raise NotImplementedError(f"Failed to close database connection: {error}")
        