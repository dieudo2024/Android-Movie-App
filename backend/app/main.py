from . import config

from fastapi import FastAPI
from fastapi import HTTPException
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
    description: str
    created_at: str

movie_db = MovieDatabase(database=config.DB_NAME)

movie_db.create_table()

@app.get("/")
def read_root():
    return "Welcome to the Movie API!"

@app.get("/movies")
def list_movies():
    try:
        return movie_db.get_all_movies()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve movies: {e}")

