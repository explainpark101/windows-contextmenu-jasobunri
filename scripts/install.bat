@echo off
setlocal EnableExtensions
cd /d "%~dp0"

chcp 65001 >nul 2>&1

net session >nul 2>&1
if not errorlevel 1 goto :have_admin

echo.
echo [안내] 관리자 권한으로 실행되지 않았습니다.
echo 레지스트리에 우클릭 메뉴를 등록하려면 이 배치 파일을
echo 탐색기에서 우클릭한 뒤 "관리자 권한으로 실행"을 선택하세요.
echo.
pause
exit /b 1

:have_admin

set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%~dp0.."
set "EXE_SOURCE="
set "INSTALL_DIR=%ProgramData%\JasoBunri"
set "INSTALL_EXE=%INSTALL_DIR%\nfc_renamer.exe"

if exist "%SCRIPT_DIR%nfc_renamer.exe" set "EXE_SOURCE=%SCRIPT_DIR%nfc_renamer.exe"
if not defined EXE_SOURCE if exist "%REPO_ROOT%\nfc_renamer.exe" set "EXE_SOURCE=%REPO_ROOT%\nfc_renamer.exe"
if not defined EXE_SOURCE if exist "%REPO_ROOT%\dist\nfc_renamer.exe" set "EXE_SOURCE=%REPO_ROOT%\dist\nfc_renamer.exe"

if not defined EXE_SOURCE (
    echo.
    echo [안내] nfc_renamer.exe를 찾지 못했습니다.
    echo 다음 경로를 순서대로 확인했습니다:
    echo   1^) %SCRIPT_DIR%nfc_renamer.exe
    echo   2^) %REPO_ROOT%\nfc_renamer.exe
    echo   3^) %REPO_ROOT%\dist\nfc_renamer.exe
    echo README의 g++ 빌드 방법으로 exe를 만든 뒤 다시 실행하세요.
    echo.
    pause
    exit /b 1
)

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
copy /Y "%EXE_SOURCE%" "%INSTALL_EXE%" >nul
if errorlevel 1 (
    echo.
    echo [오류] nfc_renamer.exe를 "%INSTALL_EXE%"로 복사하지 못했습니다.
    pause
    exit /b 1
)

set "REG_COMMAND=\"%INSTALL_EXE%\" \"%%1\""

reg add "HKCR\*\shell\NormalizeNFC" /ve /t REG_SZ /d "한글자모 분리 수정" /f >nul
if errorlevel 1 goto :reg_fail
reg add "HKCR\*\shell\NormalizeNFC\command" /ve /t REG_SZ /d "%REG_COMMAND%" /f >nul
if errorlevel 1 goto :reg_fail
reg add "HKCR\Directory\shell\NormalizeNFC" /ve /t REG_SZ /d "한글자모 분리 수정" /f >nul
if errorlevel 1 goto :reg_fail
reg add "HKCR\Directory\shell\NormalizeNFC\command" /ve /t REG_SZ /d "%REG_COMMAND%" /f >nul
if errorlevel 1 (
    goto :reg_fail
)

echo.
echo 설치가 완료되었습니다.
echo 실행 파일: "%INSTALL_EXE%"
echo 탐색기에서 "한글자모 분리 수정" 우클릭 메뉴를 확인하세요.
echo.
pause
exit /b 0

:reg_fail
echo.
echo [오류] 레지스트리 등록에 실패했습니다.
echo 관리자 권한으로 실행했는지 확인하세요.
pause
exit /b 1
