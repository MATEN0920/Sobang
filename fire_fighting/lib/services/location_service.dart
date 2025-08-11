import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/facility_model.dart';
import '../services/kakao_search_service.dart';

class LocationService {
  static Position? _currentPosition;

  // 현재 위치 가져오기
  static Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) return null;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      return _currentPosition;
    } catch (e) {
      print('위치 가져오기 오류: $e');
      return null;
    }
  }

  // 위치 권한 확인
  static Future<bool> _checkLocationPermission() async {
    PermissionStatus permission = await Permission.location.status;

    if (permission.isDenied) {
      permission = await Permission.location.request();
    }

    return permission.isGranted;
  }

  // 🔥 현재 위치 기준 가까운 소방서 검색 (카카오 API 사용)
  static Future<List<FacilityModel>> fetchFireStations() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) {
        print('위치 정보를 가져올 수 없어 기본 소방서 목록을 반환합니다.');
        return _getDefaultSeoulFireStations();
      }

      print('현재 위치에서 소방서 검색 중: ${position.latitude}, ${position.longitude}');

      List<FacilityModel> results =
          await KakaoSearchService.searchNearbyFireStations(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      print('카카오 API 소방서 검색 결과: ${results.length}개');

      if (results.isEmpty) {
        print('API 검색 결과가 없어 기본 소방서 목록을 반환합니다.');
        return _getDefaultSeoulFireStations();
      }

      results.sort((a, b) {
        double distanceA = calculateDistance(
            position.latitude, position.longitude, a.latitude, a.longitude);
        double distanceB = calculateDistance(
            position.latitude, position.longitude, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });

      return results;
    } catch (e) {
      print('소방서 검색 오류: $e');
      return _getDefaultSeoulFireStations();
    }
  }

  static Future<List<FacilityModel>> fetchHospitals() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return [];

      return await KakaoSearchService.searchNearbyHospitals(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('병원 검색 오류: $e');
      return [];
    }
  }

  static Future<List<FacilityModel>> fetchPoliceStations() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return [];

      return await KakaoSearchService.searchNearbyPoliceStations(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('경찰서 검색 오류: $e');
      return [];
    }
  }

  // shelters.json에서 대피시설 리스트를 불러오는 함수
  static Future<List<FacilityModel>> fetchShelters() async {
    try {
      final String response = await rootBundle.loadString('assets/shelters.json');
      final List<dynamic> data = json.decode(response);
      return data.map((e) => FacilityModel.fromJson(e)).toList();
    } catch (e) {
      print('대피시설 데이터 로드 오류: $e');
      return [];
    }
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static FacilityModel? findNearestFacility(
    List<FacilityModel> facilities,
    Position userPosition,
  ) {
    if (facilities.isEmpty) return null;

    FacilityModel? nearest;
    double minDistance = double.infinity;

    for (final facility in facilities) {
      double distance = calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        facility.latitude,
        facility.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = facility;
      }
    }

    return nearest;
  }

  static List<FacilityModel> _getDefaultSeoulFireStations() {
    return [
      FacilityModel(
        id: 'default_1',
        name: '서울중부소방서',
        address: '서울특별시 중구 을지로 245',
        latitude: 37.5665,
        longitude: 126.9780,
        phone: '02-3706-1400',
        type: FacilityType.fireStation,
      ),
      FacilityModel(
        id: 'default_2',
        name: '서울강남소방서',
        address: '서울특별시 강남구 테헤란로 114길 11',
        latitude: 37.5172,
        longitude: 127.0473,
        phone: '02-3706-1500',
        type: FacilityType.fireStation,
      ),
      FacilityModel(
        id: 'default_3',
        name: '서울서초소방서',
        address: '서울특별시 서초구 반포대로 201',
        latitude: 37.5043,
        longitude: 126.9910,
        phone: '02-3706-1600',
        type: FacilityType.fireStation,
      ),
    ];
  }
}
