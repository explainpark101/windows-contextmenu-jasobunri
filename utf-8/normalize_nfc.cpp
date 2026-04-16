#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <windows.h>
#include <shellapi.h> // CommandLineToArgvW 함수 사용을 위해 추가합니다.
// NormalizeString 함수 사용을 위해 필요합니다.
#include <winnls.h>
// Windows 프로그레스 다이얼로그 사용을 위해 추가합니다.
#include <shlobj.h>

// MSVC 컴파일러를 위한 라이브러리 링크 지시어입니다.
#pragma comment(lib, "Normaliz.lib")
#pragma comment(lib, "Ole32.lib")

namespace fs = std::filesystem;

// 문자열을 NFC 방식으로 정규화하는 함수입니다.
std::wstring normalize_to_nfc(const std::wstring& input) {
    // 1. 정규화된 문자열을 저장할 버퍼의 필요한 크기를 구합니다.
    int size = NormalizeString(NormalizationC, input.c_str(), -1, NULL, 0);
    if (size <= 0) {
        return input; // 오류 시 원본을 그대로 반환합니다.
    }

    // 2. 버퍼를 할당하고 실제로 정규화를 수행합니다.
    std::vector<wchar_t> buffer(size);
    int result = NormalizeString(NormalizationC, input.c_str(), -1, buffer.data(), size);
    if (result <= 0) {
        return input; // 오류 시 원본을 그대로 반환합니다.
    }

    return std::wstring(buffer.data());
}

// 콘솔 창을 띄우지 않기 위해 일반 wmain 대신 Windows GUI 진입점인 wWinMain을 사용합니다.
int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nCmdShow) {
    int argc;
    LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (argv == NULL) {
        return 0;
    }

    if (argc < 2) {
        LocalFree(argv);
        return 0;
    }

    int total_files = argc - 1;

    // COM(Component Object Model) 라이브러리를 초기화합니다.
    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);

    IProgressDialog *pDialog = NULL;
    HRESULT hr = CoCreateInstance(CLSID_ProgressDialog, NULL, CLSCTX_INPROC_SERVER, IID_IProgressDialog, (void**)&pDialog);

    if (SUCCEEDED(hr)) {
        pDialog->SetTitle(L"NFC 파일명 정규화");
        pDialog->SetLine(1, L"파일 이름을 변환하는 중입니다...", TRUE, NULL);
        // 프로그레스 바 표시를 시작합니다.
        pDialog->StartProgressDialog(NULL, NULL, PROGDLG_NORMAL | PROGDLG_AUTOTIME, NULL);
    }

    // Windows 우클릭으로 전달받은 모든 파일/폴더 경로 처리 (argv[0]은 프로그램 자체 경로입니다)
    for (int i = 1; i < argc; ++i) {
        if (pDialog) {
            // 사용자가 진행 창에서 '취소'를 눌렀는지 확인합니다.
            if (pDialog->HasUserCancelled()) {
                break;
            }
            // 현재 진행률을 업데이트합니다.
            pDialog->SetProgress(i - 1, total_files);
        }

        fs::path filepath(argv[i]);

        // 디렉토리 경로와 파일명을 분리합니다.
        fs::path dir_name = filepath.parent_path();
        std::wstring base_name = filepath.filename().wstring();

        if (pDialog) {
            // 현재 처리 중인 파일명을 프로그레스 바에 표시합니다.
            pDialog->SetLine(2, base_name.c_str(), TRUE, NULL);
        }

        // 파일명을 NFC(Windows 호환) 방식으로 정규화합니다.
        std::wstring nfc_name = normalize_to_nfc(base_name);

        // 정규화 전후의 이름이 다르면 파일명을 변경합니다.
        if (base_name != nfc_name) {
            fs::path new_filepath = dir_name / nfc_name;
            try {
                fs::rename(filepath, new_filepath);
            } catch (const fs::filesystem_error& e) {
                // 오류 발생 시 무시합니다.
            }
        }
    }

    // 작업 완료 후 프로그레스 바를 닫고 메모리를 해제합니다.
    if (pDialog) {
        pDialog->SetProgress(total_files, total_files);
        pDialog->StopProgressDialog();
        pDialog->Release();
    }

    // COM 라이브러리 사용을 종료합니다.
    CoUninitialize();

    LocalFree(argv); // 할당된 인자 메모리를 해제합니다.
    return 0;
}