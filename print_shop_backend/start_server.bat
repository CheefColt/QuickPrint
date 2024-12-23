@echo off
SETLOCAL

:: Set environment variables
SET PYTHONPATH=%~dp0
SET APP_ENV=development

:: Create virtual environment if not exists
IF NOT EXIST venv (
    python -m venv venv
    CALL venv\Scripts\activate
    pip install -r requirements.txt
) ELSE (
    CALL venv\Scripts\activate
)

:: Create uploads directory
mkdir uploads 2>nul

:: Run the server
python -m uvicorn app.main:app --host 192.168.0.100 --port 8000 --reload --log-level debug

ENDLOCAL