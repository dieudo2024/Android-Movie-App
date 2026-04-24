from . import config

from fastapi import FastAPI
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
    description: str
    created_at: str

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
def list_movies():
    try:
        return movie_db.get_all_movies()
    except Exception as e:
        raise NotImplementedError(f"Failed to retrieve movies: {e}")

