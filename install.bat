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

REM 우클릭 명령은 PATH의 pythonw.exe를 사용합니다.
pythonw --version >nul 2>&1
if not errorlevel 1 goto :have_python

python --version >nul 2>&1
if not errorlevel 1 goto :have_python

echo.
echo [안내] Python이 없거나 PATH에 등록되어 있지 않습니다.
echo 설치 시 "Add python.exe to PATH" 옵션을 반드시 체크하고, 설치 후 이 배치 파일을 다시 실행하세요.
echo 우클릭 메뉴는 PATH의 pythonw.exe가 필요합니다.
echo.
echo 브라우저에서 Python 공식 다운로드 페이지를 엽니다...
start "" "https://www.python.org/downloads/"
exit /b 1

:have_python
if not exist "C:\Scripts\" mkdir "C:\Scripts\"
copy /Y "%~dp0normalize_nfc.py" "C:\Scripts\" >nul
if errorlevel 1 (
    echo.
    echo [오류] normalize_nfc.py를 C:\Scripts\로 복사하지 못했습니다.
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
