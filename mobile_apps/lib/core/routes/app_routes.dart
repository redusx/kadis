import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/request/create_request_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/request/requests_list_screen.dart';

class AppRoutes {
  // Route names
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';
  static const String createRequest = '/create-request';
  static const String profile = '/profile';
  static const String requestsList = '/requests-list';
  
  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case createRequest:
        return MaterialPageRoute(builder: (_) => const CreateRequestScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case requestsList:
        return MaterialPageRoute(builder: (_) => const RequestsListScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
