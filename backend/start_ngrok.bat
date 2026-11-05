@echo off
echo ========================================
echo Simhastha Backend + ngrok Setup
echo ========================================
echo.

REM Check if ngrok is installed
where ngrok >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ngrok is not installed or not in PATH!
    echo.
    echo Please install ngrok:
    echo 1. Download from: https://ngrok.com/download
    echo 2. Or run: choco install ngrok
    echo 3. Or run: npm install -g ngrok
    echo.
    pause
    exit /b 1
)

echo [1/2] Starting Backend Server on port 3000...
start "Simhastha Backend Server" cmd /k "cd /d "%~dp0" && node server.js"

echo [2/2] Waiting 3 seconds for server to start...
timeout /t 3 /nobreak >nul

echo [3/3] Starting ngrok tunnel...
start "ngrok Tunnel" cmd /k "ngrok http 3000 --log=stdout"

echo.
echo ========================================
echo ✅ SETUP COMPLETE!
echo ========================================
echo.
echo NEXT STEPS:
echo.
echo 1. Look at the ngrok window and copy the HTTPS URL
echo    Example: https://abcd-1234-xyz.ngrok-free.app
echo.
echo 2. Open: lib\constants\app_constants.dart
echo    Update: static const String backendBaseUrl = 'YOUR_NGROK_URL';
echo.
echo 3. Rebuild APK:
echo    flutter build apk --release
echo.
echo 4. Install on phone:
echo    e:\AI app\ai_assistant\build\app\outputs\flutter-apk\app-release.apk
echo.
echo 5. Test in browser first:
echo    https://YOUR_NGROK_URL/api/temples
echo.
echo TIP: Visit http://127.0.0.1:4040 to monitor ngrok traffic
echo.
echo ========================================
pause
