# DBA-W2026-Group7

## Domain Choice

This project is a movie catalog application.

## Project Description

The system combines a FastAPI backend with a Flutter frontend to manage a movie database. Users can browse movies, add new entries, update or delete existing movies, view movie details, and access dashboard and favorites features in the app.

## Prerequisites

- Python 3.10+ with `pip`
- Flutter SDK 3.11+ with a configured device or emulator
- MySQL server for the backend database

## Backend Setup and Run Instructions

These steps run the backend in the existing `backend` folder for this project.

### 1. Go to the backend directory

```bash
cd backend
```

### 2. Create a virtual environment

```bash
python -m venv venv
```

### 3. Activate the virtual environment

On Windows (PowerShell or CMD):

```bash
venv\Scripts\activate
```

On macOS/Linux:

```bash
source venv/bin/activate
```

### 4. Install backend dependencies

```bash
pip install -r requirements.txt
```

Current dependencies in `backend/requirements.txt`:

- fastapi
- uvicorn
- mysql-connector-python
- pydantic
- pandas
- python-dotenv

### 5. Configure the database connection

Create the environment file used by the backend and update the values for your local MySQL setup:

```bash
copy .env.example .env
```

On macOS/Linux:

```bash
cp .env.example .env
```

Backend environment variables:

- DB_HOST
- DB_USER
- DB_PASSWORD
- DB_NAME
- DB_PORT

### 6. Initialize the database

If your MySQL user can create schemas automatically, you can skip this step because the backend also creates the `movie_db` schema and the `movies` table at startup.

If you want to initialize the database manually, run `db_setup.sql` first.

### 7. Seed the data

From inside `backend`, run:

```bash
python seed_movies.py
```

### 8. Run the API server

From inside `backend`:

```bash
uvicorn app.main:app --reload
```

### 9. Verify it is running

- API root: http://127.0.0.1:8000/
- Swagger docs: http://127.0.0.1:8000/docs

You should see:

```json
{"message":"API is running"}
```

### 10. Stop the server

Press `Ctrl + C` in the terminal.

## Flutter Setup and Run Instructions

These steps run the Flutter app in the `flutter_app` folder.

### 1. Go to the Flutter directory

```bash
cd flutter_app
```

### 2. Get Flutter dependencies

```bash
flutter pub get
```

### 3. Make sure the backend is running

Start the FastAPI server before launching the app so the UI can connect to the API.

### 4. Run the Flutter app

```bash
flutter run
```

If more than one device is connected, choose the target device when prompted.

### 5. Stop the app

Use `q` in the terminal or stop the debug session from VS Code.