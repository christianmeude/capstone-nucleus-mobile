import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../routes/app_routes.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  int currentPage = 0;

  final List<Map<String, dynamic>> splashData = [
    {
      "title": "Discover Research",
      "text": "Explore thousands of academic papers, theses, and research projects from National University scholars.",
      "icon": Icons.search_rounded,
    },
    {
      "title": "Share Your Work",
      "text": "Upload and publish your research to reach a wider academic community and gain recognition.",
      "icon": Icons.cloud_upload_rounded,
    },
    {
      "title": "Collaborate Together",
      "text": "Connect with fellow researchers, share insights, and build meaningful academic partnerships.",
      "icon": Icons.groups_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(StorageKeys.userId);
    final hasSeenOnboarding =
        prefs.getBool(StorageKeys.hasSeenOnboarding) ?? false;

    if (userId != null && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (hasSeenOnboarding && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.landing);
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.hasSeenOnboarding, true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.landing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Page content
              Expanded(
                flex: 3,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                    title: splashData[index]["title"],
                    text: splashData[index]["text"],
                    icon: splashData[index]["icon"],
                  ),
                ),
              ),
              
              // Bottom section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(),
                      
                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 6),
                            height: 6,
                            width: currentPage == index ? 24 : 6,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? AppColors.accent
                                  : AppColors.borderMedium,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(flex: 3),
                      
                      // Continue button
                      ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: AppTextStyles.buttonLarge,
                        ),
                      ),
                      
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashContent extends StatelessWidget {
  const SplashContent({
    super.key,
    this.title,
    this.text,
    this.icon,
  });

  final String? title, text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        
        // App name
        Text(
          "NUcleus",
          style: AppTextStyles.display.copyWith(
            fontSize: 36,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Title
        Text(
          title ?? "",
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.secondary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            text ?? "",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        
        const Spacer(flex: 2),
        
        // Icon container
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Icon(
            icon ?? Icons.school_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
