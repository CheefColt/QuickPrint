@echo off
cd C:\Users\gajul\Desktop\print_shop_automation\print_shop_backend

:: Create uploads directory if it doesn't exist
mkdir uploads 2>nul

:: Activate virtual environment if exists
if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate
) else (
    python -m venv venv
    call venv\Scripts\activate
    pip install -r requirements.txt
)

:: Run server
python -m uvicorn app.main:app --host 192.168.0.100 --port 8000 --reload --log-level debug