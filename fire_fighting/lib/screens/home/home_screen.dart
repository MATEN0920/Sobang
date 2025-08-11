import 'package:flutter/material.dart';
import '../../config/app_routes.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("안전한 하루 되세요! 👋", style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "화재 안전을 위한 다양한 기능을 이용해보세요",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Text("주요 기능", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 1.1,
                children: [
                  _HomeCard(
                    icon: Icons.location_on,
                    color: Colors.blue.shade100,
                    title: "서울 안전 지도 보기",
                    subtitle: "가까운 안전시설",
                    onTap: () => Navigator.pushNamed(context, AppRoutes.safetyMap),
                  ),
                  _HomeCard(
                    icon: Icons.assignment_turned_in,
                    color: Colors.green.shade100,
                    title: "미션 수행",
                    subtitle: "안전 대전 완료",
                    onTap: () => Navigator.pushNamed(context, AppRoutes.mission),
                  ),
                  _HomeCard(
                    icon: Icons.person,
                    color: Colors.purple.shade100,
                    title: "마이페이지",
                    subtitle: "내 정보 관리",
                    onTap: () => Navigator.pushNamed(context, AppRoutes.mypage),
                  ),
                  _HomeCard(
                    icon: Icons.store,
                    color: Colors.orange.shade100,
                    title: "포인트 상점",
                    subtitle: "리워드 교환",
                    onTap: () => Navigator.pushNamed(context, AppRoutes.points),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 38, color: Colors.black54),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
