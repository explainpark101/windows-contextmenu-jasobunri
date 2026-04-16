@echo off
setlocal EnableExtensions
cd /d "%~dp0"

chcp 65001 >nul 2>&1

set "REPO_ROOT=%~dp0.."
set "DIST_DIR=%REPO_ROOT%\dist"
set "EXE_DIST=%DIST_DIR%\nfc_renamer.exe"
set "EXE_SOURCE="

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

if exist "%EXE_DIST%" set "EXE_SOURCE=%EXE_DIST%"
if not defined EXE_SOURCE if exist "%REPO_ROOT%\nfc_renamer.exe" set "EXE_SOURCE=%REPO_ROOT%\nfc_renamer.exe"
if not defined EXE_SOURCE if exist "%~dp0nfc_renamer.exe" set "EXE_SOURCE=%~dp0nfc_renamer.exe"

if not defined EXE_SOURCE (
    echo.
    echo [오류] nfc_renamer.exe를 찾지 못했습니다.
    echo 먼저 README의 빌드 방법으로 실행 파일을 생성하세요.
    echo.
    pause
    exit /b 1
)

if /I not "%EXE_SOURCE%"=="%EXE_DIST%" copy /Y "%EXE_SOURCE%" "%EXE_DIST%" >nul
if errorlevel 1 (
    echo.
    echo [오류] dist\nfc_renamer.exe 준비에 실패했습니다.
    echo.
    pause
    exit /b 1
)

set "ISCC=ISCC.exe"
where /q "%ISCC%"
if errorlevel 1 (
    if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
)
if not exist "%ISCC%" (
    echo.
    echo [오류] Inno Setup 6의 ISCC.exe를 찾지 못했습니다.
    echo https://jrsoftware.org/isinfo.php 에서 설치 후 다시 실행하세요.
    echo.
    pause
    exit /b 1
)

"%ISCC%" "%~dp0jasobunri-installer.iss"
if errorlevel 1 (
    echo.
    echo [오류] 설치 파일 생성에 실패했습니다.
    echo.
    pause
    exit /b 1
)

echo.
echo [완료] 설치 파일 생성 성공: "%DIST_DIR%\jasobunri-setup.exe"
echo.
pause
exit /b 0
