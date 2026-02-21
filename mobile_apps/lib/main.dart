import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(const KabisApp());
}

class KabisApp extends StatelessWidget {
  const KabisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kadis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
