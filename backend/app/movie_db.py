import mysql.connector
import pandas as pd
from typing import Any, Dict, List, Optional, Sequence
from .db import connect, ensure_schema_exists, DatabaseError

class MovieDatabase:
    def __init__(self, database: str):
        if not database:
            raise ValueError("database is required")

        try:
            self.connection = connect(database=None, include_database=False)
            self.cursor = self.connection.cursor(dictionary=True)

            ensure_schema_exists(database)
            self.cursor.execute(f"USE `{database}`;")
            
        except (mysql.connector.Error, DatabaseError) as error:
            raise DatabaseError(f"Failed to connect to database: {error}") from error

    def create_table(self) -> None:
        try:
            sql = """
            CREATE TABLE IF NOT EXISTS movies (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL UNIQUE,
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
            raise DatabaseError(f"Failed to create movies table: {error}") from error
    
    def insert_movies(self, rows: Sequence[Dict[str, Any]]) -> int:
        if rows is None:
            raise ValueError("rows cannot be None")
        
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
                    row.get('synopsis') or ""
                )
                for row in rows
            ]

            self.cursor.executemany(sql, values)
            self.connection.commit()

            return self.cursor.rowcount
        except mysql.connector.Error as error:
            raise DatabaseError(f"Failed to insert movies: {error}") from error

    def get_all_movies(
        self,
        page: int = 1,
        page_size: int = 10,
        category: str | None = None,
        title: str | None = None,
        director: str | None = None,
        year: int | None = None,
        min_rating: float | None = None,
        max_rating: float | None = None,
    ) -> Dict[str, Any]:
        if page < 1:
            raise ValueError("page must be >= 1")
        if page_size < 1:
            raise ValueError("page_size must be >= 1")
        if min_rating is not None and max_rating is not None and min_rating > max_rating:
            raise ValueError("min_rating cannot be greater than max_rating")

        try:
            where_clauses: List[str] = []
            where_values: List[Any] = []

            if category:
                where_clauses.append("category = %s")
                where_values.append(category)
            if title:
                where_clauses.append("LOWER(title) LIKE %s")
                where_values.append(f"%{title.lower()}%")
            if director:
                where_clauses.append("director = %s")
                where_values.append(director)
            if year is not None:
                where_clauses.append("year = %s")
                where_values.append(year)
            if min_rating is not None:
                where_clauses.append("rating >= %s")
                where_values.append(min_rating)
            if max_rating is not None:
                where_clauses.append("rating <= %s")
                where_values.append(max_rating)

            where_sql = ""
            if where_clauses:
                where_sql = " WHERE " + " AND ".join(where_clauses)

            offset = (page - 1) * page_size

            count_sql = f"SELECT COUNT(*) AS total FROM movies{where_sql};"
            self.cursor.execute(count_sql, tuple(where_values))
            total = int(self.cursor.fetchone()["total"])

            data_sql = f"SELECT * FROM movies{where_sql} ORDER BY id DESC LIMIT %s OFFSET %s;"
            data_values = [*where_values, page_size, offset]
            self.cursor.execute(data_sql, tuple(data_values))
            movies = self.cursor.fetchall()

            total_pages = (total + page_size - 1) // page_size if total else 0

            return {
                "items": movies,
                "page": page,
                "page_size": page_size,
                "total": total,
                "total_pages": total_pages,
            }
        except mysql.connector.Error as error:
            raise DatabaseError(f"Failed to retrieve movies: {error}") from error
    
    def get_one_movie(self) -> Optional[Dict[str, Any]]:
        try:
            self.cursor.execute("SELECT * FROM movies LIMIT 1;")
            return self.cursor.fetchone()
        except mysql.connector.Error as error:
            raise DatabaseError(f"Failed to retrieve one movie: {error}")

    def get_movie_by_id(self, movie_id: int) -> Optional[Dict[str, Any]]:
        if movie_id < 1:
            raise ValueError("movie_id must be >= 1")

        try:
            query = "SELECT * FROM movies WHERE id = %s;"
            self.cursor.execute(query, (movie_id,))
            return self.cursor.fetchone()
        except mysql.connector.Error as error:
            raise DatabaseError(f"Failed to retrieve movie by ID: {error}") from error

    def update_movie(self, movie_id: int, row: Dict[str, Any]) -> None:
        if movie_id < 1:
            raise ValueError("movie_id must be >= 1")
        if row is None:
            raise ValueError("row cannot be None")

        try:
            sql = """
            UPDATE movies
            SET title = %s,
                category = %s,
                director = %s,
                year = %s,
                rating = %s,
                description = %s,
                synopsis = %s
            WHERE id = %s;
            """

            values = (
                row["title"],
                row["category"],
                row["director"],
                row["year"],
                row["rating"],
                row.get("description"),
                row.get("synopsis") or "",
                movie_id,
            )

            self.cursor.execute(sql, values)
            self.connection.commit()
        except mysql.connector.Error as error:
            raise DatabaseError(f"Failed to update movie: {error}") from error

    def delete_movie(self, movie_id: int) -> int:
        if movie_id < 1:
            raise ValueError("movie_id must be >= 1")

        try:
            sql = "DELETE FROM movies WHERE id = %s;"
            self.cursor.execute(sql, (movie_id,))
            self.connection.commit()
            return self.cursor.rowcount
        except mysql.connector.Error as error:
            raise DatabaseError(f"Failed to delete movie: {error}") from error

    def get_stats(self) -> Dict[str, Any]:
        try:
            self.cursor.execute("SELECT * FROM movies;")
            rows = self.cursor.fetchall()
            df = pd.DataFrame(rows)

            if df.empty:
                return {
                    "total_movies": 0,
                    "avg_rating": 0.0,
                    "min_rating": 0.0,
                    "max_rating": 0.0,
                    "avg_year": 0.0,
                    "oldest_year": None,
                    "newest_year": None,
                    "movies_by_category": {},
                    "avg_rating_by_category": {},
                }

            movies_by_category = (
                df["category"].value_counts().sort_index().astype(int).to_dict()
            )
            avg_rating_by_category = (
                df.groupby("category")["rating"].mean().round(2).to_dict()
            )

            return {
                "total_movies": int(len(df)),
                "avg_rating": float(df["rating"].mean().round(2)),
                "min_rating": float(df["rating"].min()),
                "max_rating": float(df["rating"].max()),
                "avg_year": float(df["year"].mean().round(2)),
                "oldest_year": int(df["year"].min()),
                "newest_year": int(df["year"].max()),
                "movies_by_category": movies_by_category,
                "avg_rating_by_category": avg_rating_by_category,
            }
        except mysql.connector.Error as error:
            raise DatabaseError(f"Failed to retrieve stats: {error}") from error
        
    def close(self) -> None:
        try:
            if self.cursor:
                self.cursor.close()
            if self.connection:
                self.connection.close()
        except mysql.connector.Error as error:
            raise DatabaseError(f"Failed to close database connection: {error}") from error
        