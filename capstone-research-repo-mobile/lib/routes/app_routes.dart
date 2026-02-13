import 'package:flutter/material.dart';
import '../presentation/screens/auth/get_started_screen.dart';
import '../presentation/screens/auth/landing_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/home/home_screen.dart';
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

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
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
        final paper = settings.arguments as ResearchModel;
        return MaterialPageRoute(
          builder: (_) => ResearchDetailScreen(paper: paper),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
