# DBA-W2026-Group7

## Backend Setup (FastAPI)

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
pip install fastapi uvicorn mysql-connector-python
```

### 5. Run the API server

From inside `backend`:

```bash
uvicorn main:app --reload
```

### 6. Verify it is running

- API root: http://127.0.0.1:8000/
- Swagger docs: http://127.0.0.1:8000/docs

You should see:

```json
{"message":"API is running"}
```

### 7. Stop the server

Press `Ctrl + C` in the terminal.