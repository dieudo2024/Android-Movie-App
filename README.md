# DBA-W2026-Group7

## A. Backend Setup (FastAPI)

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

### 5. Create your environment file

From inside `backend`, copy the example and update values as needed:

```bash
copy .env.example .env
```

On macOS/Linux:

```bash
cp .env.example .env
```

Default variables used by the backend:

- DB_HOST
- DB_USER
- DB_PASSWORD
- DB_NAME
- DB_PORT

### 6. Run the API server

From inside `backend`:

```bash
uvicorn app.main:app --reload
```

### 7. Verify it is running

- API root: http://127.0.0.1:8000/
- Swagger docs: http://127.0.0.1:8000/docs

You should see:

```json
{"message":"API is running"}
```

### 8. Stop the server

Press `Ctrl + C` in the terminal.