@echo off
REM ====== Personalizza SOLO queste 3 righe coi tuoi percorsi portable ======
set "JAVA_HOME=C:\portable\jdk-17"
set "ANDROID_HOME=C:\portable\android-sdk"
set "NODE_DIR=C:\portable\node"
REM =========================================================================

set "PATH=%NODE_DIR%;%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%PATH%"

echo.
echo == Verifica requisiti Cordova ==
call npx cordova requirements
echo.
echo == Aggiunta piattaforma Android (se assente) ==
call npx cordova platform add android
echo.
echo == Build APK di debug ==
call npx cordova build android
echo.
echo APK generato in:
echo platforms\android\app\build\outputs\apk\debug\app-debug.apk
pause
