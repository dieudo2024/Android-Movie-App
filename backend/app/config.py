import os
from pathlib import Path

from dotenv import load_dotenv

# Load environment variables from backend/.env
BASE_DIR = Path(__file__).resolve().parents[1]
load_dotenv(BASE_DIR / ".env")

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_NAME = os.getenv("DB_NAME", "movie_db")
DB_PORT = int(os.getenv("DB_PORT", "3306"))