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

if not exist "%~dp0nfc_renamer.exe" (
    echo.
    echo [안내] 이 폴더에 nfc_renamer.exe가 없습니다.
    echo README의 g++ 빌드 방법을 참고하여 exe를 만든 뒤 다시 실행하세요.
    echo.
    pause
    exit /b 1
)

if not exist "C:\Scripts\" mkdir "C:\Scripts\"
copy /Y "%~dp0nfc_renamer.exe" "C:\Scripts\" >nul
if errorlevel 1 (
    echo.
    echo [오류] nfc_renamer.exe를 C:\Scripts\로 복사하지 못했습니다.
    pause
    exit /b 1
)

if not exist "C:\Scripts\" mkdir "C:\Scripts\"
copy /Y "%~dp0nfc_renamer.exe" "C:\Scripts\" >nul
if errorlevel 1 (
    echo.
    echo [오류] nfc_renamer.exe를 C:\Scripts\로 복사하지 못했습니다.
    pause
    exit /b 1
)

reg import "%~dp0add_nfc_menu.reg"
if errorlevel 1 (
    echo.
    echo [오류] 레지스트리 병합에 실패했습니다. add_nfc_menu.reg 파일 경로와 내용을 확인하세요.
    pause
    exit /b 1
)

echo.
echo 설치가 완료되었습니다. 탐색기에서 "한글자모 분리 수정" 우클릭 메뉴를 확인하세요.
echo.
pause
exit /b 0
