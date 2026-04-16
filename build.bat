@echo off
setlocal EnableExtensions
cd /d "%~dp0"

g++ -std=c++17 -municode -o nfc_renamer.exe normalize_nfc.cpp -lNormaliz
if errorlevel 1 exit /b 1

echo 빌드 완료: %~dp0nfc_renamer.exe
exit /b 0
