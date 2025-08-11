import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../models/facility_model.dart';

class NavigationService {
  // 구글 지도로 길찾기
  static Future<void> openGoogleMaps({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? destinationName,
  }) async {
    final url = 'https://www.google.com/maps/dir/$fromLat,$fromLng/$toLat,$toLng';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw '구글 지도를 열 수 없습니다.';
      }
    } catch (e) {
      print('구글 지도 오류: $e');
    }
  }

  // 카카오맵으로 길찾기
  static Future<void> openKakaoMap({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? destinationName,
  }) async {
    final encodedName = Uri.encodeComponent(destinationName ?? '목적지');
    final url = 'https://map.kakao.com/link/to/$encodedName,$toLat,$toLng';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw '카카오맵을 열 수 없습니다.';
      }
    } catch (e) {
      print('카카오맵 오류: $e');
    }
  }

  // 네이버 지도로 길찾기
  static Future<void> openNaverMap({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? destinationName,
  }) async {
    final encodedName = Uri.encodeComponent(destinationName ?? '목적지');
    final url = 'https://map.naver.com/v5/directions/$fromLat,$fromLng,$toLat,$toLng,name=$encodedName';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw '네이버 지도를 열 수 없습니다.';
      }
    } catch (e) {
      print('네이버 지도 오류: $e');
    }
  }

  // Windows 지도 앱으로 길찾기
  static Future<void> openWindowsMaps({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? destinationName,
  }) async {
    final url = 'bingmaps:?rtp=pos.${fromLat}_${fromLng}~pos.${toLat}_${toLng}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // Windows 지도 앱이 없으면 브라우저에서 Bing Maps 열기
        await openBingMaps(
          fromLat: fromLat,
          fromLng: fromLng,
          toLat: toLat,
          toLng: toLng,
          destinationName: destinationName,
        );
      }
    } catch (e) {
      print('Windows 지도 오류: $e');
    }
  }

  // Bing Maps로 길찾기
  static Future<void> openBingMaps({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? destinationName,
  }) async {
    final url = 'https://www.bing.com/maps/directions?from=$fromLat,$fromLng&to=$toLat,$toLng';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Bing Maps를 열 수 없습니다.';
      }
    } catch (e) {
      print('Bing Maps 오류: $e');
    }
  }

  // 길찾기 옵션 다이얼로그 표시
  static void showNavigationOptions({
    required BuildContext context,
    required double fromLat,
    required double fromLng,
    required FacilityModel destination,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Row(
              children: [
                Icon(Icons.directions, color: Colors.blue, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${destination.name}로 길찾기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // 길찾기 옵션들
            _NavigationOption(
              icon: Icons.map,
              title: '구글 지도',
              subtitle: '가장 정확한 길찾기',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                openGoogleMaps(
                  fromLat: fromLat,
                  fromLng: fromLng,
                  toLat: destination.latitude,
                  toLng: destination.longitude,
                  destinationName: destination.name,
                );
              },
            ),
            
            _NavigationOption(
              icon: Icons.location_on,
              title: '카카오맵',
              subtitle: '한국 도로에 특화',
              color: Colors.yellow.shade700,
              onTap: () {
                Navigator.pop(context);
                openKakaoMap(
                  fromLat: fromLat,
                  fromLng: fromLng,
                  toLat: destination.latitude,
                  toLng: destination.longitude,
                  destinationName: destination.name,
                );
              },
            ),
            
            _NavigationOption(
              icon: Icons.navigation,
              title: '네이버 지도',
              subtitle: '실시간 교통정보 제공',
              color: Colors.green.shade600,
              onTap: () {
                Navigator.pop(context);
                openNaverMap(
                  fromLat: fromLat,
                  fromLng: fromLng,
                  toLat: destination.latitude,
                  toLng: destination.longitude,
                  destinationName: destination.name,
                );
              },
            ),
            
            _NavigationOption(
              icon: Icons.computer,
              title: 'Windows 지도',
              subtitle: '시스템 기본 지도 앱',
              color: Colors.blue.shade600,
              onTap: () {
                Navigator.pop(context);
                openWindowsMaps(
                  fromLat: fromLat,
                  fromLng: fromLng,
                  toLat: destination.latitude,
                  toLng: destination.longitude,
                  destinationName: destination.name,
                );
              },
            ),
            
            SizedBox(height: 10),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
          ],
        ),
      ),
    );
  }

  // 전화 걸기
  static Future<void> makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw '전화를 걸 수 없습니다.';
      }
    } catch (e) {
      print('전화 걸기 오류: $e');
    }
  }
}

class _NavigationOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavigationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        onTap: onTap,
      ),
    );
  }
}
