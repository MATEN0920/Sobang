// lib/screens/mission/route_check_mission_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/location_service.dart';
import '../../../models/facility_model.dart';

class RouteCheckMissionScreen extends StatefulWidget {
  const RouteCheckMissionScreen({super.key});

  @override
  State<RouteCheckMissionScreen> createState() => _RouteCheckMissionScreenState();
}

class _RouteCheckMissionScreenState extends State<RouteCheckMissionScreen> {
  Position? _currentPosition;
  List<FacilityModel> _nearestShelters = [];
  bool _isLoading = true;

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

    shelters.sort((a, b) {
      double distA = LocationService.calculateDistance(
        position.latitude, position.longitude, a.latitude, a.longitude);
      double distB = LocationService.calculateDistance(
        position.latitude, position.longitude, b.latitude, b.longitude);
      return distA.compareTo(distB);
    });
    List<FacilityModel> nearestShelters = shelters.take(3).toList();

    setState(() {
      _currentPosition = position;
      _nearestShelters = nearestShelters;
      _isLoading = false;
    });
  }

  void _showNavigationOptions(FacilityModel shelter) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('${shelter.name}로 길찾기', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: Icon(Icons.map, color: Colors.green),
                title: Text('구글 지도'),
                onTap: () {
                  final url = 'https://www.google.com/maps/search/?api=1&query=${shelter.latitude},${shelter.longitude}';
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.map, color: Colors.yellow),
                title: Text('카카오맵'),
                onTap: () {
                  final url = 'https://map.kakao.com/link/map/${Uri.encodeComponent(shelter.name)},${shelter.latitude},${shelter.longitude}';
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.map, color: Colors.blue),
                title: Text('네이버 지도'),
                onTap: () {
                  final url = 'https://map.naver.com/v5/search/${Uri.encodeComponent(shelter.name)}/place/${shelter.latitude},${shelter.longitude}';
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.map, color: Colors.grey),
                title: Text('Windows 지도'),
                onTap: () {
                  final url = 'bingmaps:?cp=${shelter.latitude}~${shelter.longitude}';
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("대피루트 파악 미션")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _nearestShelters.isEmpty
                ? const Text('대피소 정보를 가져올 수 없습니다.')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '내 현재 위치: ${_currentPosition?.latitude?.toStringAsFixed(5)}, ${_currentPosition?.longitude?.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text('가장 가까운 대피시설 3곳:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._nearestShelters.map((shelter) {
                        double distance = LocationService.calculateDistance(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          shelter.latitude,
                          shelter.longitude,
                        );
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          child: ListTile(
                            title: Text(shelter.name),
                            subtitle: Text('주소: ${shelter.address}\n거리: ${distance.toStringAsFixed(1)}m'),
                            onTap: () => _showNavigationOptions(shelter),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
      ),
    );
  }
}
