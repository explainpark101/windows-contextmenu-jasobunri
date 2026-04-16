import sys
import os
import unicodedata

# Windows 우클릭으로 전달받은 모든 파일/폴더 경로 처리
for filepath in sys.argv[1:]:
    dir_name = os.path.dirname(filepath)
    base_name = os.path.basename(filepath)
    
    # 파일명을 NFC(Windows 호환) 방식으로 정규화
    nfc_name = unicodedata.normalize('NFC', base_name)
    
    if base_name != nfc_name:
        new_filepath = os.path.join(dir_name, nfc_name)
        try:
            os.rename(filepath, new_filepath)
        except Exception as e:
            # 오류 발생 시 로깅이 필요하다면 여기에 추가할 수 있습니다.
            pass
