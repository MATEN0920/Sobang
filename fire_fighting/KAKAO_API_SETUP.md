# 카카오 지도 API 설정 가이드

## 1. 카카오 개발자 등록
1. [카카오 개발자 사이트](https://developers.kakao.com/)에 접속
2. 로그인 후 "내 애플리케이션" → "애플리케이션 추가하기" 클릭
3. 앱 이름, 사업자명 입력 후 애플리케이션 생성

## 2. API 키 발급
1. 생성된 앱 선택 → "앱 키" 탭
2. **REST API 키** 복사
3. **JavaScript 키** 복사 (웹에서 사용 시)

## 3. 플랫폼 등록
### Android
1. "플랫폼" → "Android 플랫폼 등록"
2. 패키지명: `com.example.fire_fighting` (또는 본인의 패키지명)
3. 키 해시 등록 (선택사항)

### iOS  
1. "플랫폼" → "iOS 플랫폼 등록"
2. 번들 ID: `com.example.fire_fighting` (또는 본인의 번들 ID)

## 4. 코드에 API 키 적용
`lib/config/constants.dart` 파일에서:
```dart
static const String kakaoRestApiKey = '여기에_발급받은_REST_API_키_입력';
```

## 5. 주의사항
- API 키는 절대 공개 저장소에 올리지 마세요
- `.gitignore`에 `constants.dart` 추가 권장
- 상용 앱 배포 시 키 해시 등록 필요

## 카카오 지도 기능 사용법

### 기본 기능
- 📍 현재 위치 표시
- 🔍 반경 내 소방서/병원/경찰서 검색  
- 🚒 가장 가까운 소방서 찾기
- 📱 시설 정보 상세 보기

### 버튼 기능
- 🧭 위치 버튼: 현재 위치로 이동
- 🔄 새로고침: 시설 재검색
- 📋 목록: 시설 목록 보기
- 🚨 응급: 119 신고
- 🚒 주황 버튼: 가장 가까운 소방서로 이동
