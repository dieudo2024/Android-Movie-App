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

## Android Emulator (Android Studio)

Follow these steps to set up and run an Android emulator with Android Studio, then launch the Flutter app on the emulator.

- **Install Android Studio**: Download and install from https://developer.android.com/studio. During installation, include the Android SDK and Android Virtual Device (AVD) components.

- **Install Flutter & Dart plugins**: In Android Studio go to `File > Settings > Plugins` and install `Flutter` (which also installs `Dart`). Restart Android Studio if prompted.

- **Configure Android SDK path**: In Android Studio go to `File > Settings > Appearance & Behavior > System Settings > Android SDK` and note the SDK location. You can set `ANDROID_SDK_ROOT` or `ANDROID_HOME` environment variable to this path if needed.

- **Create a virtual device (AVD)**:
    1. Open `AVD Manager` from the toolbar or `Tools > Device Manager`.
    2. Click `Create Virtual Device` and choose a device (e.g., Pixel 7).
    3. Select a system image (use a Google Play or Google APIs image with API level 30+ recommended).
    4. Finish creating the AVD.

- **Enable hardware acceleration (Not a must. Just recommended)**:
    - On Windows, enable `Windows Hypervisor Platform` or install Intel HAXM (if using Intel CPU). Enable virtualization in BIOS if required.
    - On macOS, the emulator uses Hypervisor.framework.

- **Start the emulator**:
    - From `AVD Manager`, click the green `Play` icon for the AVD.
    - Or start from the command line:

```bash
cd flutter_app
flutter emulators --launch <emulatorId>
```

- **Accept Android licenses** (if not done yet):

```bash
flutter doctor --android-licenses
```

- **Verify device is available**:

```bash
flutter devices
```

- **Run the Flutter app on the emulator**:

From the project `flutter_app` directory:

```bash
flutter pub get
flutter run
```

Or open the project in Android Studio and press the run (green) button after selecting the emulator as the target device.

Troubleshooting tips:
- If `flutter devices` does not show the emulator, ensure the emulator is running and `adb` is on your PATH (Android SDK platform-tools).
- Run `flutter doctor` to see missing components and follow its suggestions.