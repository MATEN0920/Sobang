import 'package:flutter/material.dart';
import '../../models/facility_model.dart';
import '../../services/location_service.dart';
import '../../services/navigation_service.dart';
import 'package:geolocator/geolocator.dart';

class SimpleMapScreen extends StatefulWidget {
  @override
  _SimpleMapScreenState createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  List<FacilityModel> _facilities = [];
  Position? _currentPosition;
  bool _isLoading = true;
  FacilityType _selectedType = FacilityType.fireStation;
  FacilityModel? _nearestFireStation;
  
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }
  
  Future<void> _initializeScreen() async {
    await _getCurrentLocation();
    await _loadFacilities();
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await LocationService.getCurrentPosition();
    } catch (e) {
      print('위치 가져오기 오류: $e');
    }
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
      
      // 가장 가까운 소방서 찾기
      if (_currentPosition != null && _selectedType == FacilityType.fireStation) {
        _nearestFireStation = LocationService.findNearestFacility(_facilities, _currentPosition!);
      }
      
    } catch (e) {
      print('시설 로드 오류: $e');
      _facilities = [];
    }
    
    setState(() {
      _isLoading = false;
    });
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
        title: Text('보호시설 찾기'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
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
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('${_selectedType.displayName} 검색 중...'),
                ],
              ),
            )
          : Column(
              children: [
                // 상태 표시
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getIconForType(_selectedType), color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            '${_selectedType.displayName} ${_facilities.length}개 발견',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (_currentPosition != null)
                        Text(
                          '현재 위치: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      if (_nearestFireStation != null && _selectedType == FacilityType.fireStation)
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                '가장 가까운: ${_nearestFireStation!.name}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // 시설 목록
                Expanded(
                  child: _facilities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '${_selectedType.displayName}을(를) 찾을 수 없습니다',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadFacilities,
                                child: Text('다시 검색'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _facilities.length,
                          itemBuilder: (context, index) {
                            final facility = _facilities[index];
                            final isNearest = _nearestFireStation?.id == facility.id;
                            
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              color: isNearest ? Colors.orange.shade50 : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isNearest ? Colors.orange : Colors.blue,
                                  child: Icon(
                                    _getIconForType(facility.type),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(facility.name)),
                                    if (isNearest)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '가장 가까움',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(facility.address),
                                    if (facility.phone.isNotEmpty)
                                      Text(
                                        '📞 ${facility.phone}',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    if (_currentPosition != null)
                                      Text(
                                        '📍 ${(LocationService.calculateDistance(
                                          _currentPosition!.latitude,
                                          _currentPosition!.longitude,
                                          facility.latitude,
                                          facility.longitude,
                                        ) / 1000).toStringAsFixed(1)}km',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 길찾기 버튼
                                    IconButton(
                                      icon: Icon(Icons.directions, color: Colors.blue),
                                      onPressed: () {
                                        if (_currentPosition != null) {
                                          NavigationService.showNavigationOptions(
                                            context: context,
                                            fromLat: _currentPosition!.latitude,
                                            fromLng: _currentPosition!.longitude,
                                            destination: facility,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('현재 위치를 찾을 수 없습니다')),
                                          );
                                        }
                                      },
                                      tooltip: '길찾기',
                                    ),
                                    // 전화 버튼
                                    if (facility.phone.isNotEmpty)
                                      IconButton(
                                        icon: Icon(Icons.phone, color: Colors.green),
                                        onPressed: () {
                                          NavigationService.makePhoneCall(facility.phone);
                                        },
                                        tooltip: '전화하기',
                                      ),
                                    Icon(Icons.arrow_forward_ios, size: 16),
                                  ],
                                ),
                                onTap: () {
                                  _showFacilityDetails(facility);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadFacilities,
        backgroundColor: Colors.blue,
        child: Icon(Icons.refresh),
        tooltip: '새로고침',
      ),
    );
  }
  
  void _showFacilityDetails(FacilityModel facility) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getIconForType(facility.type)),
            SizedBox(width: 10),
            Expanded(child: Text(facility.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 ${facility.address}'),
            if (facility.phone.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('📞 ${facility.phone}'),
            ],
            if (_currentPosition != null) ...[
              SizedBox(height: 8),
              Text(
                '🚗 거리: ${(LocationService.calculateDistance(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  facility.latitude,
                  facility.longitude,
                ) / 1000).toStringAsFixed(1)}km',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (facility.description.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(facility.description),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
          if (_currentPosition != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                NavigationService.showNavigationOptions(
                  context: context,
                  fromLat: _currentPosition!.latitude,
                  fromLng: _currentPosition!.longitude,
                  destination: facility,
                );
              },
              icon: Icon(Icons.directions),
              label: Text('길찾기'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          if (facility.phone.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                NavigationService.makePhoneCall(facility.phone);
              },
              icon: Icon(Icons.phone),
              label: Text('전화하기'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
        ],
      ),
    );
  }
}
