import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '화재대응 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 첫 화면을 로그인 페이지로 설정
      home: LoginScreen(),
      // 라우팅 설정
      routes: AppRoutes.getRoutes(),
    );
  }
}
