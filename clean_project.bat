@echo off
echo ========================================
echo   NeuroAid Project Cleanup Script
echo ========================================
echo.
echo This script will delete:
echo  - All Python virtual environments (venv)
echo  - Flutter build files
echo  - Python cache files
echo  - Temporary files
echo.
echo WARNING: You will need to reinstall dependencies later!
echo.
pause

echo.
echo [1/6] Running flutter clean...
call flutter clean
if %errorlevel% equ 0 (
    echo ✓ Flutter clean completed
) else (
    echo ✗ Flutter clean failed or not in Flutter project
)

echo.
echo [2/6] Deleting Python virtual environments...
if exist "backend\flask_server\venv" (
    echo   - Deleting backend\flask_server\venv...
    rmdir /s /q "backend\flask_server\venv"
    echo   ✓ Deleted
)
if exist "backend\ai_services\chatbot\venv" (
    echo   - Deleting backend\ai_services\chatbot\venv...
    rmdir /s /q "backend\ai_services\chatbot\venv"
    echo   ✓ Deleted
)
if exist "backend\ai_services\stroke_assessment\venv" (
    echo   - Deleting backend\ai_services\stroke_assessment\venv...
    rmdir /s /q "backend\ai_services\stroke_assessment\venv"
    echo   ✓ Deleted
)
if exist "backend\venv" (
    echo   - Deleting backend\venv...
    rmdir /s /q "backend\venv"
    echo   ✓ Deleted
)

echo.
echo [3/6] Deleting Python cache files...
for /d /r . %%d in (__pycache__) do @if exist "%%d" (
    echo   - Deleting %%d
    rmdir /s /q "%%d"
)
for /r . %%f in (*.pyc) do @if exist "%%f" del /q "%%f"
for /r . %%f in (*.pyo) do @if exist "%%f" del /q "%%f"
echo ✓ Cache files deleted

echo.
echo [4/6] Deleting Flutter build artifacts...
if exist "build" (
    echo   - Deleting build folder...
    rmdir /s /q "build"
    echo   ✓ Deleted
)
if exist ".dart_tool" (
    echo   - Deleting .dart_tool folder...
    rmdir /s /q ".dart_tool"
    echo   ✓ Deleted
)
if exist ".flutter-plugins" del /q ".flutter-plugins"
if exist ".flutter-plugins-dependencies" del /q ".flutter-plugins-dependencies"

echo.
echo [5/6] Deleting uploaded files and logs...
if exist "backend\uploads" (
    echo   - Keeping backend\uploads folder structure but cleaning files...
    rem Optionally delete uploaded scans if needed
    rem rmdir /s /q "backend\uploads\scans"
)
if exist "backend\*.log" del /q "backend\*.log"

echo.
echo [6/6] Deleting IDE and temp files...
if exist ".idea" rmdir /s /q ".idea"
if exist ".vscode\*.log" del /q ".vscode\*.log"
if exist "*.tmp" del /q "*.tmp"

echo.
echo ========================================
echo   Cleanup Complete!
echo ========================================
echo.
echo To restore the project:
echo.
echo 1. Flutter dependencies:
echo    flutter pub get
echo.
echo 2. Python dependencies (for each service):
echo    cd backend\flask_server
echo    python -m venv venv
echo    venv\Scripts\activate
echo    pip install -r requirements.txt
echo.
echo    cd ..\ai_services\chatbot
echo    python -m venv venv
echo    venv\Scripts\activate
echo    pip install -r requirements.txt
echo.
echo ========================================
pause
