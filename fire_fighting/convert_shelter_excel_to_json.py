import pandas as pd
import json

excel_file = 'shelters.xlsx'      # 원본 엑셀 파일명
json_file = 'shelters.json'       # 저장할 JSON 파일명

# 필요한 컬럼명 지정 (엑셀 헤더와 일치해야 함)
needed_columns = {
    '관리번호': 'id',
    '시설명': 'name',
    '도로명전체주소': 'address',
    '위도(EPSG4326)': 'latitude',
    '경도(EPSG4326)': 'longitude'
}

df = pd.read_excel(excel_file)
filtered = df[list(needed_columns.keys())].rename(columns=needed_columns)
data = filtered.to_dict(orient='records')

with open(json_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f'변환 완료: {json_file}')