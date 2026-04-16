#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <windows.h>
// NormalizeString 함수 사용을 위해 필요합니다.
#include <winnls.h>

// MSVC 컴파일러에서 Normaliz.lib를 링크하도록 지시합니다.
#pragma comment(lib, "Normaliz.lib")

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

// Windows 환경에서 유니코드 경로를 처리하기 위해 일반 main 대신 wmain을 사용합니다.
int wmain(int argc, wchar_t* argv[]) {
    // Windows 우클릭으로 전달받은 모든 파일/폴더 경로 처리 (argv[0]은 프로그램 자체 경로입니다)
    for (int i = 1; i < argc; ++i) {
        fs::path filepath(argv[i]);

        // 디렉토리 경로와 파일명을 분리합니다.
        fs::path dir_name = filepath.parent_path();
        std::wstring base_name = filepath.filename().wstring();

        // 파일명을 NFC(Windows 호환) 방식으로 정규화합니다.
        std::wstring nfc_name = normalize_to_nfc(base_name);

        // 정규화 전후의 이름이 다르면 파일명을 변경합니다.
        if (base_name != nfc_name) {
            fs::path new_filepath = dir_name / nfc_name;
            try {
                fs::rename(filepath, new_filepath);
            } catch (const fs::filesystem_error& e) {
                // 오류 발생 시 로깅이 필요하다면 여기에 추가할 수 있습니다.
                // Python의 pass처럼 예외를 무시합니다.
            }
        }
    }
    return 0;
}