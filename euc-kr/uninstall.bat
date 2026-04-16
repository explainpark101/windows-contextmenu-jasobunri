@echo off
setlocal EnableExtensions
cd /d "%~dp0"

chcp 65001 >nul 2>&1

net session >nul 2>&1
if not errorlevel 1 goto :have_admin

echo.
echo [안내] 관리자 권한으로 실행되지 않았습니다.
echo 레지스트리에서 메뉴를 제거하려면 이 배치 파일을
echo 탐색기에서 우클릭한 뒤 "관리자 권한으로 실행"을 선택하세요.
echo.
pause
exit /b 1

:have_admin

reg delete "HKCR\*\shell\NormalizeNFC" /f >nul 2>&1
reg delete "HKCR\Directory\shell\NormalizeNFC" /f >nul 2>&1
echo [완료] 레지스트리 메뉴 제거를 시도했습니다. 없던 키는 무시됩니다.

if not exist "C:\Scripts\nfc_renamer.exe" goto :no_copy
del /f /q "C:\Scripts\nfc_renamer.exe"
if exist "C:\Scripts\nfc_renamer.exe" goto :del_fail
echo [완료] C:\Scripts\nfc_renamer.exe 삭제
goto :end

:no_copy
echo [정보] C:\Scripts\nfc_renamer.exe 없음 (이미 삭제되었거나 설치하지 않음)
goto :end

:del_fail
echo [오류] nfc_renamer.exe 삭제 실패. 파일이 다른 프로그램에서 열렸는지 확인하세요.

:end
echo.
echo 제거 작업을 종료했습니다.
echo.
pause
exit /b 0
