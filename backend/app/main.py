from . import config

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from .movie_db import MovieDatabase

app = FastAPI(title="Movie API", description="A simple API built with FastAPI")

def home():
    return {"message": "API is running"}

class Movie(BaseModel):
    title: str
    category: str
    director: str
    year: int
    rating: float = Field(ge=0.0, le=10.0)
    description: str | None = None
    synopsis: str | None = None
    created_at: str | None = None

movie_db = MovieDatabase(database=config.DB_NAME)

movie_db.create_table()

# This endpoint retrieves a paginated list of movies with optional filters
# Eg GET /movies?page=2&page_size=5

@app.get("/movies")
def list_movies(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=10, ge=1, le=100),
    category: str | None = None,
    director: str | None = None,
    year: int | None = None,
    min_rating: float | None = Query(default=None, ge=0.0, le=10.0),
    max_rating: float | None = Query(default=None, ge=0.0, le=10.0),
):
    if min_rating is not None and max_rating is not None and min_rating > max_rating:
        raise HTTPException(
            status_code=400,
            detail="min_rating cannot be greater than max_rating",
        )

    try:
        return movie_db.get_all_movies(
            page=page,
            page_size=page_size,
            category=category,
            director=director,
            year=year,
            min_rating=min_rating,
            max_rating=max_rating,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve movies: {e}")

@app.get("/movies/{movie_id}")
def get_movie_by_id(movie_id: int):
    try:
        movie = movie_db.get_movie_by_id(movie_id)
        if not movie:
            raise HTTPException(status_code=404, detail="Movie not found")
        return movie
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve movie by ID: {e}")

@app.post("/movies")
def add_movie(movie: Movie):
    try:
        movie_db.insert_movies([movie.model_dump(exclude_none=True)])
        return {"message": "Movie added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add movie: {e}")

@app.put("/movies/{id}")
def update_movie(id: int, movie: Movie):
    try:
        existing = movie_db.get_movie_by_id(id)
        if not existing:
            raise HTTPException(status_code=404, detail="Movie not found")

        movie_db.update_movie(
            id,
            movie.model_dump(exclude_none=True, exclude={"created_at"}),
        )
        return {"message": "Movie updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update movie: {e}")

@app.delete("/movies/{id}")
def delete_movie(id: int):
    try:
        existing = movie_db.get_movie_by_id(id)
        if not existing:
            raise HTTPException(status_code=404, detail="Movie not found")

        movie_db.delete_movie(id)
        return {"message": "Movie deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete movie: {e}")