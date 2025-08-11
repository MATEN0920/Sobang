import 'package:flutter/material.dart';
import '../../models/user_points.dart';

class PointShopScreen extends StatefulWidget {
  const PointShopScreen({super.key});

  @override
  State<PointShopScreen> createState() => _PointShopScreenState();
}

class _PointShopScreenState extends State<PointShopScreen> {
  int userPoints = 1200; // 예시: 사용자가 가진 포인트

  final List<_ShopItem> items = [
    _ShopItem(name: "소화기", icon: Icons.fire_extinguisher, price: 1000, donatePrice: 700),
    _ShopItem(name: "화재감지기", icon: Icons.smoke_free, price: 800, donatePrice: 500),
    _ShopItem(name: "응급키트", icon: Icons.medical_services, price: 600, donatePrice: 400),
    _ShopItem(name: "손전등", icon: Icons.flashlight_on, price: 400, donatePrice: 250),
  ];

  void _exchangeItem(_ShopItem item) {
    if (userPoints >= item.price) {
      setState(() {
        userPoints -= item.price;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} 교환 완료!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('포인트가 부족합니다.')),
      );
    }
  }

  void _donateItem(_ShopItem item) {
    if (userPoints >= item.donatePrice) {
      setState(() {
        userPoints -= item.donatePrice;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('취약계층 지역에 ${item.name} 기부 완료!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('포인트가 부족합니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("💰 포인트 상점", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("내 포인트: ${UserPoints.points}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, idx) {
                  final item = items[idx];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 32, color: Colors.redAccent),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text("교환: ${item.price}P / 기부: ${item.donatePrice}P", style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(80, 36),
                                ),
                                onPressed: () => _exchangeItem(item),
                                child: const Text("교환"),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(80, 36),
                                ),
                                onPressed: () => _donateItem(item),
                                child: const Text("기부"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItem {
  final String name;
  final IconData icon;
  final int price;
  final int donatePrice;

  const _ShopItem({
    required this.name,
    required this.icon,
    required this.price,
    required this.donatePrice,
  });
}
