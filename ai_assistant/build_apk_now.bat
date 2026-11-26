@echo off
echo ========================================
echo Building APK with ngrok URL
echo ========================================
echo.
echo Backend URL: https://e158-183-87-13-226.ngrok-free.app
echo.

echo [1/3] Cleaning previous build...
call flutter clean

echo.
echo [2/3] Getting dependencies...
call flutter pub get

echo.
echo [3/3] Building release APK...
echo This will take 3-5 minutes...
echo.
call flutter build apk --release

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Build failed! Check errors above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ BUILD COMPLETE!
echo ========================================
echo.
echo APK Location:
echo %CD%\build\app\outputs\flutter-apk\app-release.apk
echo.

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do set SIZE=%%~zA
    set /a SIZE_MB=!SIZE! / 1048576
    echo APK Size: !SIZE_MB! MB
    echo.
    
    echo NEXT STEPS:
    echo 1. Transfer APK to your phone
    echo 2. Install on phone
    echo 3. Launch app and test!
    echo.
    echo The app is configured to connect to:
    echo https://e158-183-87-13-226.ngrok-free.app
    echo.
    
    set /p INSTALL_ADB="Install via ADB now? (y/n): "
    if /i "!INSTALL_ADB!"=="y" (
        echo.
        echo Checking for connected devices...
        adb devices
        echo.
        echo Installing...
        adb install -r "build\app\outputs\flutter-apk\app-release.apk"
        
        if !ERRORLEVEL! EQU 0 (
            echo.
            echo ✅ Installation successful!
            echo Launch the app on your phone now.
        ) else (
            echo.
            echo ❌ Installation failed.
            echo Make sure USB debugging is enabled.
        )
    )
    
    set /p OPEN_FOLDER="Open APK folder? (y/n): "
    if /i "!OPEN_FOLDER!"=="y" (
        explorer /select,"build\app\outputs\flutter-apk\app-release.apk"
    )
) else (
    echo ❌ APK file not found!
)

echo.
pause
