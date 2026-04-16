import 'package:flutter/material.dart';
import '../presentation/screens/auth/get_started_screen.dart';
import '../presentation/screens/auth/landing_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/shared/notifications_screen.dart';
import '../presentation/screens/shared/profile_dashboard_screen.dart';
import '../presentation/screens/shared/student_settings_screen.dart';
import '../presentation/screens/shared/student_guide_screen.dart';
import '../presentation/screens/research/submit_research_screen.dart';
import '../presentation/screens/research/research_detail_screen.dart';
import '../data/models/research_model.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String getStarted = '/get-started';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String submitResearch = '/submit-research';
  static const String researchDetail = '/research-detail';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String guide = '/guide';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case getStarted:
        return MaterialPageRoute(builder: (_) => const GetStartedScreen());
      case landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case submitResearch:
        return MaterialPageRoute(builder: (_) => const SubmitResearchScreen());
      case researchDetail:
        final args = routeSettings.arguments;
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ResearchDetailScreen(paperId: args),
          );
        }
        if (args is ResearchModel) {
          return MaterialPageRoute(
            builder: (_) =>
                ResearchDetailScreen(paperId: args.id, initialPaper: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Missing research detail route arguments'),
            ),
          ),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileDashboardScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const StudentSettingsScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case guide:
        return MaterialPageRoute(builder: (_) => const StudentGuideScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
