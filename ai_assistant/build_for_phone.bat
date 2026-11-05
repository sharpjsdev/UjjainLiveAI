@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Simhastha APK Builder for Phone Testing
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH!
    echo Please install Flutter from: https://flutter.dev
    pause
    exit /b 1
)

echo Current backend URL configuration:
echo.
type "lib\constants\app_constants.dart" | findstr /C:"defaultValue:"
echo.
echo ========================================
echo.

REM Ask user if they want to use custom URL
set /p USE_CUSTOM="Do you want to override the backend URL? (y/n): "

if /i "%USE_CUSTOM%"=="y" (
    set /p CUSTOM_URL="Enter your ngrok URL (e.g., https://xxxx.ngrok-free.app): "
    echo.
    echo Building APK with custom URL: !CUSTOM_URL!
    echo.
    
    echo [1/3] Cleaning previous build...
    call flutter clean
    
    echo.
    echo [2/3] Building APK with custom backend URL...
    call flutter build apk --release --dart-define=BACKEND_URL=!CUSTOM_URL!
    
) else (
    echo.
    echo Building APK with URL from app_constants.dart...
    echo.
    
    echo [1/3] Cleaning previous build...
    call flutter clean
    
    echo.
    echo [2/3] Building APK...
    call flutter build apk --release
)

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Build failed! Check the errors above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ Build Complete!
echo ========================================
echo.

set APK_PATH=build\app\outputs\flutter-apk\app-release.apk

if exist "%APK_PATH%" (
    echo [3/3] APK Location:
    echo %CD%\%APK_PATH%
    echo.
    
    REM Get file size
    for %%A in ("%APK_PATH%") do set SIZE=%%~zA
    set /a SIZE_MB=!SIZE! / 1048576
    echo APK Size: !SIZE_MB! MB
    echo.
    
    echo ========================================
    echo NEXT STEPS:
    echo ========================================
    echo.
    echo 1. Transfer APK to your phone:
    echo    - USB cable: Copy to phone's Download folder
    echo    - ADB: adb install "%APK_PATH%"
    echo    - Email/Drive: Send to yourself
    echo.
    echo 2. On phone:
    echo    - Enable "Install from Unknown Sources"
    echo    - Tap the APK file to install
    echo.
    echo 3. Test the app:
    echo    - Open app
    echo    - Check if data loads from backend
    echo.
    echo TIP: Use 'adb logcat ^| findstr Backend' to see logs
    echo.
    
    REM Ask if user wants to install via ADB
    set /p INSTALL_ADB="Install to connected phone via ADB? (y/n): "
    if /i "!INSTALL_ADB!"=="y" (
        echo.
        echo Checking for connected devices...
        adb devices
        echo.
        echo Installing APK...
        adb install -r "%APK_PATH%"
        
        if !ERRORLEVEL! EQU 0 (
            echo.
            echo ✅ APK installed successfully!
            echo.
            echo Start the app on your phone to test.
        ) else (
            echo.
            echo ❌ Installation failed. Make sure:
            echo    1. Phone is connected via USB
            echo    2. USB Debugging is enabled
            echo    3. ADB is installed
        )
    )
    
    echo.
    echo Open APK location in Explorer?
    set /p OPEN_FOLDER="Open folder? (y/n): "
    if /i "!OPEN_FOLDER!"=="y" (
        explorer /select,"%APK_PATH%"
    )
    
) else (
    echo ❌ APK file not found at expected location!
    echo Check build output above for errors.
)

echo.
echo ========================================
pause
