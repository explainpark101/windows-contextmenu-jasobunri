#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <windows.h>
#include <shellapi.h>
// NormalizeString 함수 사용을 위해 필요합니다.
#include <winnls.h>
// Windows 프로그레스 다이얼로그 사용을 위해 추가합니다.
#include <shlobj.h>

#pragma comment(lib, "Normaliz.lib")
#pragma comment(lib, "Ole32.lib")

namespace fs = std::filesystem;

// 문자열을 NFC 방식으로 정규화하는 함수입니다.
std::wstring normalize_to_nfc(const std::wstring& input) {
    int size = NormalizeString(NormalizationC, input.c_str(), -1, NULL, 0);
    if (size <= 0) {
        return input; 
    }

    std::vector<wchar_t> buffer(size);
    int result = NormalizeString(NormalizationC, input.c_str(), -1, buffer.data(), size);
    if (result <= 0) {
        return input;
    }

    return std::wstring(buffer.data());
}

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

    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);

    IProgressDialog *pDialog = NULL;
    HRESULT hr = CoCreateInstance(CLSID_ProgressDialog, NULL, CLSCTX_INPROC_SERVER, IID_IProgressDialog, (void**)&pDialog);

    if (SUCCEEDED(hr)) {
        pDialog->SetTitle(L"NFC 파일/폴더명 정규화");
        pDialog->SetLine(1, L"이름을 변환하는 중입니다...", TRUE, NULL);
        pDialog->StartProgressDialog(NULL, NULL, PROGDLG_NORMAL | PROGDLG_AUTOTIME, NULL);
    }

    for (int i = 1; i < argc; ++i) {
        if (pDialog) {
            if (pDialog->HasUserCancelled()) {
                break;
            }
            pDialog->SetProgress(i - 1, total_files);
        }

        // 경로를 표준화하고 후행 슬래시(\) 문제를 해결합니다.
        fs::path filepath = fs::path(argv[i]).lexically_normal();
        
        // 경로 끝에 슬래시가 있어 filename()이 추출되지 않는 경우 부모 경로로 올립니다.
        if (!filepath.has_filename()) {
            filepath = filepath.parent_path();
        }

        fs::path dir_name = filepath.parent_path();
        std::wstring base_name = filepath.filename().wstring();

        if (pDialog) {
            pDialog->SetLine(2, base_name.c_str(), TRUE, NULL);
        }

        std::wstring nfc_name = normalize_to_nfc(base_name);

        if (base_name != nfc_name) {
            fs::path new_filepath = dir_name / nfc_name;
            try {
                fs::rename(filepath, new_filepath);
            } catch (const fs::filesystem_error& e) {
                // 실패 원인을 파악할 수 있도록 에러 메시지 박스를 표시합니다.
                std::string error_msg = "다음 항목의 이름 변경을 실패했습니다:\n" + filepath.string() + "\n\n사유: " + e.what();
                MessageBoxA(NULL, error_msg.c_str(), "이름 변경 오류", MB_OK | MB_ICONERROR);
            }
        }
    }

    if (pDialog) {
        pDialog->SetProgress(total_files, total_files);
        pDialog->StopProgressDialog();
        pDialog->Release();
    }

    CoUninitialize();
    LocalFree(argv);
    return 0;
}