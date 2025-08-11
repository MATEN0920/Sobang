// constants.dart

class Constants {
  // 카카오 API 키들 - 실제 운영시에는 환경 변수나 별도 파일로 관리하세요
  static const String kakaoRestApiKey = '5584d4e1e63f1cb733ddb7def7e3248f';
  static const String kakaoJavascriptKey = '77a3caaeba36ec76992e9b1b136e8ebe';

  // ⚠️ 보안 주의: 실제 배포 시에는 다음과 같이 처리하세요:
  // 1. .env 파일 사용: flutter_dotenv 패키지
  // 2. 네이티브 코드에서 읽기
  // 3. 서버에서 프록시 API 사용

  // 기본 지도 설정
  static const double defaultLatitude = 37.5665; // 서울시청
  static const double defaultLongitude = 126.9780;
  static const int defaultZoomLevel = 3;

  // 검색 반경 설정
  static const int fireStationRadius = 10000; // 10km
  static const int hospitalRadius = 5000; // 5km
  static const int policeStationRadius = 5000; // 5km
  static const int shelterRadius = 3000; // 3km

  // 최대 검색 결과 수
  static const int maxSearchResults = 15;
}
