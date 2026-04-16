@echo off
setlocal EnableExtensions
set "REPO_ROOT=%~dp0.."
cd /d "%REPO_ROOT%"

call "%~dp0build-app.bat"
if errorlevel 1 exit /b 1

call "%~dp0build-installer.bat"
if errorlevel 1 exit /b 1

exit /b 0
