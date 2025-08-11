import 'package:dio/dio.dart';
import '../models/facility_model.dart';
import '../config/constants.dart';

class KakaoSearchService {
  static final Dio _dio = Dio();

  // 카카오 REST API 키 - constants.dart에서 관리
  static const String KAKAO_REST_API_KEY = Constants.kakaoRestApiKey;

  // API 키 검증
  static bool get isApiKeyConfigured =>
      KAKAO_REST_API_KEY != 'YOUR_KAKAO_REST_API_KEY_HERE' &&
      KAKAO_REST_API_KEY.isNotEmpty;

  // 키워드로 장소 검색
  static Future<List<FacilityModel>> searchNearbyFacilities({
    required double latitude,
    required double longitude,
    required String keyword,
    int radius = 5000, // 5km 반경
    int size = 15, // 최대 15개 결과
  }) async {
    try {
      // API 키 검증
      if (!isApiKeyConfigured) {
        print('카카오 API 키가 설정되지 않았습니다.');
        return [];
      }

      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',
        queryParameters: {
          'query': keyword,
          'x': longitude.toString(),
          'y': latitude.toString(),
          'radius': radius.toString(),
          'size': size.toString(),
          'sort': 'distance', // 거리순 정렬
        },
        options: Options(
          headers: {
            'Authorization': 'KakaoAK $KAKAO_REST_API_KEY',
          },
        ),
      );

      // Timeout 설정을 별도로 처리
      _dio.options.connectTimeout = Duration(seconds: 10);
      _dio.options.receiveTimeout = Duration(seconds: 10);

      if (response.statusCode == 200) {
        final data = response.data;
        final documents = data['documents'] as List;

        print('카카오 API 검색 결과: ${documents.length}개 ($keyword)');

        return documents
            .map((doc) => _createFacilityFromKakao(doc, keyword))
            .where((facility) => facility.name.isNotEmpty) // 빈 이름 필터링
            .toList();
      } else {
        print('카카오 API 오류: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      print('카카오 검색 API 네트워크 오류: ${e.message}');
      if (e.response?.statusCode == 401) {
        print('API 키 인증 실패. 카카오 REST API 키를 확인하세요.');
      }
      return [];
    } catch (e) {
      print('카카오 검색 API 오류: $e');
      return [];
    }
  }

  // 카카오 API 응답을 FacilityModel로 변환
  static FacilityModel _createFacilityFromKakao(
      Map<String, dynamic> doc, String searchKeyword) {
    return FacilityModel(
      id: doc['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: doc['place_name'] ?? '',
      address: doc['address_name'] ?? '',
      latitude: double.tryParse(doc['y']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(doc['x']?.toString() ?? '0') ?? 0.0,
      phone: doc['phone'] ?? '',
      type: _getFacilityTypeFromKeyword(searchKeyword),
      description:
          '${doc['category_name'] ?? ''}\n거리: ${doc['distance'] ?? ''}m',
    );
  }

  // 검색 키워드에 따른 시설 타입 결정
  static FacilityType _getFacilityTypeFromKeyword(String keyword) {
    if (keyword.contains('소방서') ||
        keyword.contains('119') ||
        keyword.contains('구조대')) {
      return FacilityType.fireStation;
    } else if (keyword.contains('병원') ||
        keyword.contains('응급실') ||
        keyword.contains('의료')) {
      return FacilityType.hospital;
    } else if (keyword.contains('경찰서') || keyword.contains('파출소')) {
      return FacilityType.policeStation;
    } else if (keyword.contains('민방위') ||
        keyword.contains('피난') ||
        keyword.contains('초등학교')) {
      return FacilityType.shelter;
    }
    return FacilityType.fireStation;
  }

  // 🚒 가까운 소방서 검색
  static Future<List<FacilityModel>> searchNearbyFireStations({
    required double latitude,
    required double longitude,
    int? radius,
  }) async {
    return await searchNearbyFacilities(
      latitude: latitude,
      longitude: longitude,
      keyword: '소방서',
      radius: radius ?? Constants.fireStationRadius,
      size: Constants.maxSearchResults,
    );
  }

  // 🏥 가까운 병원 검색
  static Future<List<FacilityModel>> searchNearbyHospitals({
    required double latitude,
    required double longitude,
    int? radius,
  }) async {
    return await searchNearbyFacilities(
      latitude: latitude,
      longitude: longitude,
      keyword: '응급실',
      radius: radius ?? Constants.hospitalRadius,
      size: Constants.maxSearchResults,
    );
  }

  // 🚔 가까운 경찰서 검색
  static Future<List<FacilityModel>> searchNearbyPoliceStations({
    required double latitude,
    required double longitude,
    int? radius,
  }) async {
    return await searchNearbyFacilities(
      latitude: latitude,
      longitude: longitude,
      keyword: '경찰서',
      radius: radius ?? Constants.policeStationRadius,
      size: Constants.maxSearchResults,
    );
  }

  // 🏛️ 가까운 대피소/공공시설 검색
  static Future<List<FacilityModel>> searchNearbyShelters({
    required double latitude,
    required double longitude,
    int? radius,
  }) async {
    return await searchNearbyFacilities(
      latitude: latitude,
      longitude: longitude,
      keyword: '초등학교', // 대피소 역할
      radius: radius ?? Constants.shelterRadius,
      size: Constants.maxSearchResults,
    );
  }

  // 종합 검색 (가장 가까운 응급시설들)
  static Future<Map<FacilityType, List<FacilityModel>>>
      searchAllEmergencyFacilities({
    required double latitude,
    required double longitude,
  }) async {
    final results = <FacilityType, List<FacilityModel>>{};

    // 병렬로 모든 시설 검색
    final futures = await Future.wait([
      searchNearbyFireStations(latitude: latitude, longitude: longitude),
      searchNearbyHospitals(latitude: latitude, longitude: longitude),
      searchNearbyPoliceStations(latitude: latitude, longitude: longitude),
      searchNearbyShelters(latitude: latitude, longitude: longitude),
    ]);

    results[FacilityType.fireStation] = futures[0];
    results[FacilityType.hospital] = futures[1];
    results[FacilityType.policeStation] = futures[2];
    results[FacilityType.shelter] = futures[3];

    return results;
  }
}
