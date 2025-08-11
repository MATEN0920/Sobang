import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../../../services/location_service.dart';
import '../../../models/facility_model.dart';

class EvacuationRouteMissionScreen extends StatefulWidget {
  const EvacuationRouteMissionScreen({super.key});

  @override
  State<EvacuationRouteMissionScreen> createState() =>
      _EvacuationRouteMissionScreenState();
}

class _EvacuationRouteMissionScreenState
    extends State<EvacuationRouteMissionScreen> {
  Position? _currentPosition;
  FacilityModel? _nearestShelter;
  bool _isLoading = true;
  bool _isWithinDistance = false;

  final double _distanceThreshold = 100.0; // 100m 이내일 때 성공

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    Position? position = await LocationService.getCurrentPosition();
    if (position == null) {
      setState(() => _isLoading = false);
      return;
    }

    List<FacilityModel> shelters = await LocationService.fetchShelters();
    FacilityModel? nearest = LocationService.findNearestFacility(shelters, position);

    double distance = -1;
    bool isWithin = false;
    if (nearest != null) {
      distance = LocationService.calculateDistance(
        position.latitude,
        position.longitude,
        nearest.latitude,
        nearest.longitude,
      );
      isWithin = distance <= _distanceThreshold;
    }

    setState(() {
      _currentPosition = position;
      _nearestShelter = nearest;
      _isWithinDistance = isWithin;
      _isLoading = false;
    });
  }

  void _onMissionComplete() {
    // 여기에 포인트 지급 로직 연결
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("미션 완료! 포인트가 지급되었습니다.")),
    );
  }

  Future<void> _checkEvacuationSuccess() async {
    Position? position = await LocationService.getCurrentPosition();
    if (position == null) return;

    // 대피시설 데이터 로드 (예: assets/shelters.json)
    List<FacilityModel> shelters = await loadShelterData();

    // 가장 가까운 대피시설 찾기
    FacilityModel? nearest = LocationService.findNearestFacility(shelters, position);

    if (nearest != null) {
      double distance = LocationService.calculateDistance(
        position.latitude,
        position.longitude,
        nearest.latitude,
        nearest.longitude,
      );

      if (distance <= 10.0) {
        // 포인트 지급
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("미션 성공! 포인트가 지급되었습니다.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("대피시설 근처(10m 이내)로 이동해주세요.")),
        );
      }
    }
  }

  // shelter 데이터 로드 예시 (JSON)
  Future<List<FacilityModel>> loadShelterData() async {
    // assets/shelters.json에서 데이터 읽기
    final String response = await rootBundle.loadString('assets/shelters.json');
    final List<dynamic> data = json.decode(response);
    return data.map((e) => FacilityModel.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('대피루트 파악 미션')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _nearestShelter == null
                ? Text('대피소 정보를 가져올 수 없습니다.')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '가장 가까운 대피소: ${_nearestShelter!.name}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '주소: ${_nearestShelter!.address}',
                      ),
                      SizedBox(height: 16),
                      if (_isWithinDistance)
                        ElevatedButton(
                          onPressed: _onMissionComplete,
                          child: Text('✅ 대피 성공! 미션 완료'),
                        )
                      else
                        Text(
                          '❌ 대피소 근처(100m 이내)로 이동해주세요.',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
      ),
    );
  }
}
