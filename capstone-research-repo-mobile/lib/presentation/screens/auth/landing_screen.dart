import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common/animated_widgets.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(StorageKeys.userId);

    if (userId != null && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo Section
                  _buildLogoSection(),

                  const Spacer(flex: 3),

                  // Welcome Text
                  _buildWelcomeSection(),

                  const SizedBox(height: 48),

                  // Buttons
                  _buildButtonSection(),

                  const SizedBox(height: 32),

                  // Footer
                  _buildFooter(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
        ),
      ),
      child: Stack(
        children: [
          // Floating orbs
          Positioned(
            top: -100,
            right: -100,
            child: _buildFloatingOrb(300, AppColors.primary.withOpacity(0.08)),
          ),
          Positioned(
            bottom: 100,
            left: -150,
            child: _buildFloatingOrb(400, AppColors.accent.withOpacity(0.06)),
          ),
          Positioned(
            top: 200,
            left: 50,
            child: _buildFloatingOrb(
              150,
              AppColors.secondary.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb(double size, Color color) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final value = _backgroundController.value * 2 * 3.14159;
        return Transform.translate(
          offset: Offset(
            10 * (value.abs() - 3.14159).abs(),
            15 * ((value + 1).abs() - 3.14159).abs(),
          ),
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Animated Logo
        Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_rounded,
                size: 64,
                color: Colors.white,
              ),
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 400.ms),

        const SizedBox(height: 24),

        // App Name
        ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ).createShader(bounds),
              child: Text(
                "NUcleus",
                style: AppTextStyles.display.copyWith(
                  color: Colors.white,
                  fontSize: 42,
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 4),

        Text(
              "Research Hub",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
              "Discover, Share &\nCollaborate",
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1.copyWith(height: 1.2),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 16),

        Text(
              "Your central hub for academic research\nand collaboration at National University",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildButtonSection() {
    return Column(
      children: [
        AnimatedPrimaryButton(
              text: "Get Started",
              icon: Icons.arrow_forward_rounded,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            )
            .animate()
            .fadeIn(delay: 700.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 16),

        AnimatedSecondaryButton(
              text: "Create Account",
              icon: Icons.person_add_rounded,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
            )
            .animate()
            .fadeIn(delay: 800.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "Secure & Private",
          style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms, duration: 500.ms);
  }
}
