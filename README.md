# windows-contextmenu-jasobunri

Windows 탐색기 우클릭 메뉴에서 파일 이름 또는 폴더 이름을 Unicode NFC로 정규화하는 도구입니다. 맥(macOS) 등 다른 환경에서 만든 파일 이름이 자모(초성·중성·종성)가 분리된 형태(NFD)로 저장된 경우, Windows에서 다루기 어렵거나 일부 프로그램 동작이 이상할 때 유용합니다.

## 기능

- 탐색기에서 파일 또는 폴더를 우클릭한 뒤 **한글자모 분리 수정**을 선택하면, 해당 항목의 이름만 NFC 형태로 바뀝니다.
- 동작은 `normalize_nfc.cpp`를 빌드한 `nfc_renamer.exe`가 Windows API `NormalizeString(NormalizationC, …)`로 이름을 정규화한 뒤 `rename`으로 반영합니다.

## 요구 사항

- Windows 10 이상(권장).
- 설치(레지스트리 병합)와 제거(`uninstall.bat`) 모두 **관리자 권한**이 필요합니다.
- `install.bat`을 실행하기 전에 같은 폴더에 **g++로 빌드한 `nfc_renamer.exe`**가 있어야 합니다.

## 빌드 (g++)

MinGW-w64 등 **g++**가 설치되어 있어야 하며, `NormalizeString` 함수가 들어 있는 **Normaliz** 라이브러리(`-lNormaliz`)를 링크할 수 있어야 합니다.

저장소 루트에서 다음을 실행합니다.

```bat
g++ -std=c++17 -municode -o nfc_renamer.exe normalize_nfc.cpp -lNormaliz
```

또는 같은 내용의 `build.bat`을 실행합니다.

- `-std=c++17`: `std::filesystem` 등에 사용합니다.
- `-municode`: 유니코드 진입점 `wmain`을 쓰기 위해 필요합니다.
- `-lNormaliz`: `NormalizeString`이 들어 있는 시스템 라이브러리입니다. 링크 오류가 나면 MinGW의 `lib` 경로에 `libNormaliz`가 있는지, 또는 Windows SDK 측 경로를 `-L`로 넘겨야 하는지 배포판 문서를 확인하세요.

빌드에 성공하면 현재 폴더에 `nfc_renamer.exe`가 생성됩니다.

## 설치 방법

1. 이 저장소를 로컬에 다운받거나 클론합니다.
2. 위 **빌드 (g++)** 절차로 `nfc_renamer.exe`를 만듭니다(이미 빌드된 exe를 두었는지 확인).
3. `install.bat`, `uninstall.bat`, `nfc_renamer.exe`, `add_nfc_menu.reg`가 **같은 폴더**에 있어야 합니다.
4. **관리자 권한**으로 `install.bat`을 실행합니다. (탐색기에서 우클릭 → **관리자 권한으로 실행**)
5. 성공 시 `nfc_renamer.exe`가 `C:\Scripts\`로 복사되고, `add_nfc_menu.reg`가 레지스트리에 병합됩니다.

## 제거 방법

1. **관리자 권한**으로 `uninstall.bat`을 실행합니다.
2. 파일 및 폴더 우클릭 메뉴 항목(`NormalizeNFC`)이 레지스트리에서 제거됩니다. `C:\Scripts\nfc_renamer.exe`가 있으면 삭제를 시도합니다. 다른 프로그램에서 해당 파일을 사용 중이면 삭제에 실패할 수 있습니다.

## 사용 방법

1. 탐색기에서 이름을 고치고 싶은 파일 또는 폴더를 우클릭합니다.
2. 컨텍스트 메뉴에서 **한글자모 분리 수정**을 선택합니다.
3. 변경이 필요 없으면 아무 일도 일어나지 않을 수 있습니다. 이름이 이미 NFC면 동작이 없습니다.

## 파일 구성

| 파일 | 설명 |
|------|------|
| `normalize_nfc.cpp` | NFC 이름 정규화 및 `rename` 수행(소스) |
| `nfc_renamer.exe` | 위 소스를 g++로 빌드한 실행 파일(`install.bat`이 `C:\Scripts\`로 복사) |
| `build.bat` | g++로 `nfc_renamer.exe` 빌드 |
| `add_nfc_menu.reg` | 파일/폴더 우클릭에 메뉴 항목을 추가하는 레지스트리 템플릿 |
| `install.bat` | 관리자 권한 확인 후 exe 복사와 `reg import` 실행 |
| `uninstall.bat` | 관리자 권한으로 레지스트리 메뉴 제거 및 `C:\Scripts\nfc_renamer.exe` 삭제 시도 |

`install.bat`과 `uninstall.bat`은 **UTF-8(무 BOM)**으로 저장하는 것을 권장합니다. 한글 출력을 위해 배치 파일에서 `chcp 65001`을 실행합니다.

## 문제 해결

- **`install.bat`이 exe 없음으로 종료**: 같은 폴더에 `nfc_renamer.exe`를 빌드한 뒤 다시 실행하세요.
- **`reg import` 실패**: 관리자 권한으로 `install.bat`을 실행했는지, 및 `add_nfc_menu.reg`의 인코딩이 UTF-16(레지스트리 편집기가 인식하는 형태)인지 확인하세요.
- **g++ 링크 오류(`Normaliz` 관련)**: MinGW에 `libNormaliz`가 있는지, `-L`로 경로를 지정해야 하는지 배포판 문서를 확인하세요.
