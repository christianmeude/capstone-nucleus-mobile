import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'routes/app_routes.dart';

class ResearchHubApp extends StatelessWidget {
  const ResearchHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NUcleus Research Hub',
      theme: buildAppTheme(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
