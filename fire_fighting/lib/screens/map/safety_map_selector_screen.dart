import 'package:flutter/material.dart';
import 'safety_map_screen.dart';

class SafetyMapSelectorScreen extends StatelessWidget {
  final List<Map<String, String>> maps = [
    {"title": "화재취약 우선도점수", "path": "assets/maps/fire_risk_priority.html"},
    {"title": "평균 화재사고수", "path": "assets/maps/avg_fire_accidents.html"},
    {"title": "평균 인명피해수", "path": "assets/maps/avg_casualties.html"},
    {"title": "평균 방화관리대상수", "path": "assets/maps/avg_fire_control_targets.html"},
    {"title": "소방장비 고장 평균개수", "path": "assets/maps/avg_fire_equipment_failures.html"},
    {"title": "노후주택수", "path": "assets/maps/old_houses_count.html"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('서울 안전 지도 선택')),
      body: ListView(
        children: maps.map((map) => ListTile(
          title: Text(map['title']!),
          trailing: Icon(Icons.map),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SafetyMapScreen(mapAssetPath: map['path']!),
              ),
            );
          },
        )).toList(),
      ),
    );
  }
}