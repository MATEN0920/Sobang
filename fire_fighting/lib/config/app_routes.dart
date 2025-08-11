import 'package:flutter/material.dart';

// auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// home
import '../screens/home/home_screen.dart';

// map
import '../screens/map/simple_map_screen.dart';
import '../screens/map/safety_map_selector_screen.dart';

// mission
import '../screens/mission/mission_screen.dart';
import '../screens/mission/extinguisher_mission_screen.dart';
import '../screens/mission/quiz_mission_screen.dart';
import '../screens/mission/route_check_mission_screen.dart';
import '../screens/mission/evacuation_route_mission_screen.dart';

// fire card
import '../screens/fire_card/fire_card_screen.dart';

// points
import '../screens/points/point_shop_screen.dart';

// mypage
import '../screens/mypage/mypage_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String map = '/map';
  static const String safetyMap = '/safety_map';
  static const String mission = '/mission';
  static const String extinguisher = '/mission/extinguisher';
  static const String quiz = '/mission/quiz';
  static const String routeCheck = '/mission/route_check';
  static const String evacuationRoute = '/mission/evacuation';

  static const String card = '/card';
  static const String points = '/points';
  static const String mypage = '/mypage';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      main: (context) => MainScreen(),
      map: (context) => SimpleMapScreen(),
      safetyMap: (context) => SafetyMapSelectorScreen(),

      // 미션 관련
      mission: (context) => MissionScreen(),
      extinguisher: (context) => ExtinguisherMissionScreen(),
      quiz: (context) => QuizMissionScreen(),
      routeCheck: (context) => RouteCheckMissionScreen(),
      evacuationRoute: (context) => EvacuationRouteMissionScreen(),

      // 기타
      card: (context) => FireCardScreen(),
      points: (context) => PointShopScreen(),
      mypage: (context) => MyPageScreen(),
    };
  }
}
