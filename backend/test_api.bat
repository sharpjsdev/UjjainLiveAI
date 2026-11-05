@echo off
echo ========================================
echo Simhastha Backend API Test Suite
echo ========================================
echo.

set BASE_URL=http://localhost:3000

REM Check if custom URL provided
if not "%~1"=="" (
    set BASE_URL=%~1
    echo Using custom URL: %BASE_URL%
) else (
    echo Using default URL: %BASE_URL%
)

echo.
echo Testing API endpoints...
echo.

echo [1/3] Testing Temples API...
curl -s -X GET "%BASE_URL%/api/temples" -H "Accept: application/json" | findstr /C:"templeName" >nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ Temples API working!
) else (
    echo ❌ Temples API failed
)

echo.
echo [2/3] Testing Events API...
curl -s -X GET "%BASE_URL%/api/events" -H "Accept: application/json" | findstr /C:"title" >nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ Events API working!
) else (
    echo ❌ Events API failed
)

echo.
echo [3/3] Testing Stays API...
curl -s -X GET "%BASE_URL%/api/stays" -H "Accept: application/json" | findstr /C:"name" >nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ Stays API working!
) else (
    echo ❌ Stays API failed
)

echo.
echo ========================================
echo Test Complete!
echo ========================================
echo.
echo To test with ngrok URL:
echo test_api.bat https://your-ngrok-url.ngrok-free.app
echo.
pause
