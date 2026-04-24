from . import config

from fastapi import FastAPI, Query
from pydantic import BaseModel, Field
from .movie_db import MovieDatabase

from app.db import ensure_schema_exists

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

ensure_schema_exists(config.DB_NAME)

movie_db = MovieDatabase(
    host=config.DB_HOST,
    user=config.DB_USER,
    password=config.DB_PASSWORD,
    database=config.DB_NAME,
)

movie_db.create_table()

@app.get("/")
def read_root():
    return "Welcome to the Movie API!"

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
        raise NotImplementedError(f"Failed to retrieve movies: {e}")

@app.get("/movies/one")
def get_one_movie():
    try:
        return movie_db.get_one_movie()
    except Exception as e:
        raise NotImplementedError(f"Failed to retrieve one movie: {e}")

@app.post("/movies")
def add_movie(movie: Movie):
    try:
        movie_db.insert_movies([movie.model_dump(exclude_none=True)])
        return {"message": "Movie added successfully"}
    except Exception as e:
        raise NotImplementedError(f"Failed to add movie: {e}")