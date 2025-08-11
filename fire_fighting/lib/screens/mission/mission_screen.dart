import 'package:flutter/material.dart';
import '../../config/app_routes.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("🔥 미션 선택", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              "완료할 미션을 선택하세요",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            MissionCard(
              color: Colors.red.shade100,
              icon: Icons.fire_extinguisher,
              title: "소화기 인증 미션",
              subtitle: "소화기 위치를 확인하고 인증하세요",
              onTap: () => Navigator.pushNamed(context, AppRoutes.extinguisher),
            ),
            const SizedBox(height: 18),
            MissionCard(
              color: Colors.blue.shade100,
              icon: Icons.quiz,
              title: "안전 퀴즈 즐기기",
              subtitle: "화재 안전 지식을 테스트해보세요",
              onTap: () => Navigator.pushNamed(context, AppRoutes.quiz),
            ),
            const SizedBox(height: 18),
            MissionCard(
              color: Colors.green.shade100,
              icon: Icons.route,
              title: "대피루트 파악 미션",
              subtitle: "비상 대피 경로를 확인하세요",
              onTap: () => Navigator.pushNamed(context, AppRoutes.routeCheck),
            ),
          ],
        ),
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MissionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.black54),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
