import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../models/facility_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late KakaoMapController _mapController;
  Position? _currentPosition;
  List<FacilityModel> _facilities = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  FacilityType _selectedType = FacilityType.fireStation;

  // 기본 서울 좌표
  static const double DEFAULT_LAT = 37.5665;
  static const double DEFAULT_LNG = 126.9780;

  // 가장 가까운 소방서 정보
  FacilityModel? _nearestFireStation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadFacilities();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    _currentPosition = await LocationService.getCurrentPosition();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      switch (_selectedType) {
        case FacilityType.fireStation:
          _facilities = await LocationService.fetchFireStations();
          break;
        case FacilityType.hospital:
          _facilities = await LocationService.fetchHospitals();
          break;
        case FacilityType.policeStation:
          _facilities = await LocationService.fetchPoliceStations();
          break;
        case FacilityType.shelter:
          _facilities = await LocationService.fetchShelters();
          break;
        default:
          _facilities = [];
      }

      _createMarkers();
    } catch (e) {
      print('시설 로드 오류: $e');
      _facilities = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _createMarkers() {
    Set<Marker> newMarkers = {};

    // 시설 마커들
    for (int i = 0; i < _facilities.length; i++) {
      final facility = _facilities[i];

      newMarkers.add(
        Marker(
          markerId: '${facility.type.toString()}_$i',
          latLng: LatLng(facility.latitude, facility.longitude),
          width: 40,
          height: 40,
          offsetX: 20,
          offsetY: 20,
        ),
      );
    }

    // 가장 가까운 소방서 찾기
    if (_currentPosition != null && _selectedType == FacilityType.fireStation) {
      _nearestFireStation =
          LocationService.findNearestFacility(_facilities, _currentPosition!);
    }

    // 현재 위치 마커
    if (_currentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: 'current_location',
          latLng:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 30,
          height: 30,
          offsetX: 15,
          offsetY: 15,
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _showFacilityDetails(FacilityModel facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // 시설 정보
                Row(
                  children: [
                    Icon(
                      _getIconForType(facility.type),
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            facility.type.displayName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // 주소
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600]),
                    SizedBox(width: 10),
                    Expanded(child: Text(facility.address)),
                  ],
                ),

                SizedBox(height: 10),

                // 전화번호
                if (facility.phone.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey[600]),
                      SizedBox(width: 10),
                      Text(facility.phone),
                    ],
                  ),

                // 거리 정보
                if (_currentPosition != null) ...[
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.directions, color: Colors.grey[600]),
                      SizedBox(width: 10),
                      Text(
                        '${(LocationService.calculateDistance(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              facility.latitude,
                              facility.longitude,
                            ) / 1000).toStringAsFixed(1)}km',
                      ),
                    ],
                  ),
                ],

                // 설명
                if (facility.description.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Text(
                    facility.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],

                SizedBox(height: 30),

                // 액션 버튼들
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // 길 찾기 기능
                        },
                        icon: Icon(Icons.directions),
                        label: Text('길찾기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    if (facility.phone.isNotEmpty) ...[
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // 전화 걸기 기능
                          },
                          icon: Icon(Icons.phone),
                          label: Text('전화하기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(FacilityType type) {
    switch (type) {
      case FacilityType.fireStation:
        return Icons.local_fire_department;
      case FacilityType.hospital:
        return Icons.local_hospital;
      case FacilityType.shelter:
        return Icons.home;
      case FacilityType.policeStation:
        return Icons.local_police;
      case FacilityType.emergencyExit:
        return Icons.exit_to_app;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('화재안전 지도'),
        actions: [
          PopupMenuButton<FacilityType>(
            icon: Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _selectedType = type;
              });
              _loadFacilities();
            },
            itemBuilder: (context) => FacilityType.values.map((type) {
              return PopupMenuItem<FacilityType>(
                value: type,
                child: Row(
                  children: [
                    Icon(_getIconForType(type)),
                    SizedBox(width: 10),
                    Text(type.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () async {
              await _getCurrentLocation();
              if (_currentPosition != null) {
                _mapController.setCenter(LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude));
                await _loadFacilities(); // 새 위치에서 재검색
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 🗺️ KakaoMap 파라미터 수정
                KakaoMap(
                  onMapCreated: (KakaoMapController controller) {
                    _mapController = controller;
                  },
                  center: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude)
                      : LatLng(DEFAULT_LAT, DEFAULT_LNG),
                  markers: _markers.toList(),
                  // ✅ onTap → onMapTap으로 변경
                  onMapTap: (LatLng position) {
                    _handleMapTap(position);
                  },
                ),

                // 검색 결과 개수 표시
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_selectedType.displayName} ${_facilities.length}개',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        if (_nearestFireStation != null &&
                            _selectedType == FacilityType.fireStation)
                          Text(
                            '가장 가까운: ${(_getCurrentDistanceToNearest() / 1000).toStringAsFixed(1)}km',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 🚨 가장 가까운 소방서로 이동
          if (_nearestFireStation != null)
            FloatingActionButton(
              heroTag: "nearest_fire_station",
              onPressed: () => _goToNearestFireStation(),
              backgroundColor: Colors.orange,
              child: Icon(Icons.local_fire_department),
              tooltip: '가장 가까운 소방서',
            ),
          if (_nearestFireStation != null) SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "emergency",
            onPressed: () => _showEmergencyDialog(),
            backgroundColor: Colors.red,
            child: Icon(Icons.emergency),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "refresh",
            onPressed: _loadFacilities,
            backgroundColor: Colors.blue,
            child: Icon(Icons.refresh),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "list",
            onPressed: () => _showFacilityList(),
            backgroundColor: Colors.green,
            child: Icon(Icons.list),
          ),
        ],
      ),
    );
  }

  // 가장 가까운 소방서로 이동
  void _goToNearestFireStation() {
    if (_nearestFireStation != null) {
      _mapController.setCenter(LatLng(
          _nearestFireStation!.latitude, _nearestFireStation!.longitude));
      _showFacilityDetails(_nearestFireStation!);
    }
  }

  // 현재 위치에서 가장 가까운 시설까지의 거리
  double _getCurrentDistanceToNearest() {
    if (_currentPosition == null || _nearestFireStation == null) return 0.0;

    return LocationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _nearestFireStation!.latitude,
      _nearestFireStation!.longitude,
    );
  }

  // 지도 클릭 처리 (마커 근처 클릭 시 해당 시설 정보 표시)
  void _handleMapTap(LatLng tappedPosition) {
    const double threshold = 0.001; // 클릭 감지 범위

    for (final facility in _facilities) {
      double distance = (tappedPosition.latitude - facility.latitude).abs() +
          (tappedPosition.longitude - facility.longitude).abs();

      if (distance < threshold) {
        _showFacilityDetails(facility);
        break;
      }
    }
  }

  // 시설 목록 보기
  void _showFacilityList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 제목
              Text(
                '${_selectedType.displayName} 목록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // 시설 목록
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) {
                    final facility = _facilities[index];

                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          _getIconForType(facility.type),
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(facility.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(facility.address),
                            if (_currentPosition != null)
                              Text(
                                '거리: ${(LocationService.calculateDistance(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                      facility.latitude,
                                      facility.longitude,
                                    ) / 1000).toStringAsFixed(1)}km',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pop(context);
                          _showFacilityDetails(facility);
                          // 지도에서 해당 위치로 이동
                          _mapController.setCenter(
                              LatLng(facility.latitude, facility.longitude));
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 10),
            Text('🚨 응급상황'),
          ],
        ),
        content: Text('119에 신고하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 전화 걸기 기능 구현
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('신고'),
          ),
        ],
      ),
    );
  }
}
