import 'package:flutter/material.dart';

class FireCardScreen extends StatelessWidget {
  const FireCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('행동 카드 연습')),
      body: Center(
        child: Text('행동 카드 연습 페이지입니다'),
      ),
    );
  }
}
