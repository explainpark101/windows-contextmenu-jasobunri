# windows-contextmenu-jasobunri

Windows 탐색기 우클릭 메뉴에서 파일 이름 또는 폴더 이름을 Unicode NFC로 정규화하는 도구입니다. 맥(macOS) 등 다른 환경에서 만든 파일 이름이 자모(초성·중성·종성)가 분리된 형태(NFD)로 저장된 경우, Windows에서 다루기 어렵거나 일부 프로그램 동작이 이상할 때 유용합니다.

## 기능

- 탐색기에서 파일 또는 폴더를 우클릭한 뒤 **한글자모 분리 수정**을 선택하면, 해당 항목의 이름만 NFC 형태로 바뀝니다.
- 실제 내용은 `normalize_nfc.py`에서 `unicodedata.normalize('NFC', ...)`로 기준 이름을 변경합니다.

## 요구 사항

- Windows 10 이상(권장).
- Python3.x가 설치되어 있고, **PATH에 `pythonw.exe`가 등록**되어 있어야 합니다. 우클릭 메뉴는 백그라운드에서 `pythonw`로 스크립트를 실행합니다.
- 설치(레지스트리 병합)은 **관리자 권한**이 필요합니다.

## 설치 방법

1. 이 저장소를 로컬에 다운받거나 클론합니다.
2. `install.bat`, `normalize_nfc.py`, `add_nfc_menu.reg` 세 파일이 **같은 폴더**에 있어야 합니다.
3. **관리자 권한**으로 `install.bat`을 실행합니다. (탐색기에서 우클릭 → **관리자 권한으로 실행**)
4. 스크립트가 Python 미설치/경로 미등록으로 판단하면 안내 후 브라우저로 Python 공식 다운로드 페이지를 엽니다. 설치 시 **Add python.exe to PATH**를 필수로 선택한 뒤, 다시 3단계를 반복합니다.
5. 성공 시 `normalize_nfc.py`가 `C:\Scripts\`로 복사되고, `add_nfc_menu.reg`가 레지스트리에 병합됩니다.

## 사용 방법

1. 탐색기에서 이름을 고치고 싶은 파일 또는 폴더를 우클릭합니다.
2. 컨텍스트 메뉴에서 **한글자모 분리 수정**을 선택합니다.
3. 변경이 필요 없으면 아무 일도 일어나지 않을 수 있습니다. 이름이 이미 NFC면 동작이 없습니다.

## 파일 구성

| 파일 | 설명 |
|------|------|
| `normalize_nfc.py` | 우클릭으로 받은 경로의 마지막 이름만 NFC로 바꾸는 스크립트 |
| `add_nfc_menu.reg` | 파일/폴더 우클릭에 메뉴 항목을 추가하는 레지스트리 템플릿 |
| `install.bat` | 관리자 권한 및 Python 확인 후 복사와 `reg import` 실행 |

## 문제 해결

- **메뉴를 눌러도 아무 일도 없음**: `pythonw.exe`가 PATH에 없을 수 있습니다. Python 설치 경로의 `pythonw.exe`의 **전체 경로**를 `add_nfc_menu.reg`의 `command` 값에 직접 지정한 뒤 다시 병합하세요.
- **`reg import` 실패**: 관리자 권한으로 `install.bat`을 실행했는지, 및 `add_nfc_menu.reg`의 인코딩이 UTF-16(레지스트리 편집기가 인식하는 형태)인지 확인하세요.
