import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Logo at top (centered)
            _buildLogo(),

            // Illustration area
            Expanded(child: _buildIllustrationArea()),

            // Welcome text
            _buildWelcomeText(),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildButtonSection(context),
            ),

            // Terms footer
            _buildTermsFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Image.asset(
        'assets/images/logo.png',
        height: 60,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildIllustrationArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Research-themed isometric illustrations
              // Top row
              Positioned(
                top: constraints.maxHeight * 0.05,
                left: constraints.maxWidth * 0.05,
                child: _buildIllustrationItem(
                  Icons.science_outlined,
                  AppColors.primary,
                  40,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.02,
                left: constraints.maxWidth * 0.35,
                child: _buildIllustrationItem(
                  Icons.menu_book_rounded,
                  AppColors.accent,
                  45,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.08,
                right: constraints.maxWidth * 0.08,
                child: _buildIllustrationItem(
                  Icons.edit_document,
                  AppColors.primaryLight,
                  38,
                ),
              ),

              // Second row
              Positioned(
                top: constraints.maxHeight * 0.22,
                left: constraints.maxWidth * 0.12,
                child: _buildIllustrationItem(
                  Icons.lightbulb_outline_rounded,
                  AppColors.accent,
                  42,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.25,
                right: constraints.maxWidth * 0.15,
                child: _buildIllustrationItem(
                  Icons.school_outlined,
                  AppColors.primary,
                  48,
                ),
              ),

              // Center main illustration
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.hub_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              // Third row
              Positioned(
                top: constraints.maxHeight * 0.45,
                left: constraints.maxWidth * 0.02,
                child: _buildIllustrationItem(
                  Icons.analytics_outlined,
                  AppColors.primaryLight,
                  44,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.48,
                left: constraints.maxWidth * 0.38,
                child: _buildIllustrationItem(
                  Icons.flag_outlined,
                  AppColors.accent,
                  40,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.42,
                right: constraints.maxWidth * 0.05,
                child: _buildIllustrationItem(
                  Icons.article_outlined,
                  AppColors.primary,
                  42,
                ),
              ),

              // Bottom row
              Positioned(
                bottom: constraints.maxHeight * 0.12,
                left: constraints.maxWidth * 0.08,
                child: _buildIllustrationItem(
                  Icons.folder_open_outlined,
                  AppColors.primary,
                  38,
                ),
              ),
              Positioned(
                bottom: constraints.maxHeight * 0.08,
                left: constraints.maxWidth * 0.38,
                child: _buildIllustrationItem(
                  Icons.create_outlined,
                  AppColors.accent,
                  44,
                ),
              ),
              Positioned(
                bottom: constraints.maxHeight * 0.15,
                right: constraints.maxWidth * 0.1,
                child: _buildIllustrationItem(
                  Icons.inventory_2_outlined,
                  AppColors.primaryLight,
                  40,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIllustrationItem(IconData icon, Color color, double size) {
    return Container(
      padding: EdgeInsets.all(size * 0.3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  Widget _buildWelcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            "Welcome to NUcleus",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your gateway to academic research",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Column(
      children: [
        // Primary Button - Sign up (filled)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              "Sign up free",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Button - Log in (outlined)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.borderMedium, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              "Log in",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: "By signing up, you agree to NUcleus's "),
            TextSpan(
              text: "Terms of Use",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            const TextSpan(text: "\nand "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            const TextSpan(text: "."),
          ],
        ),
      ),
    );
  }
}
