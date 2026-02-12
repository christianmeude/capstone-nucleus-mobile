import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../research/browse_research_screen.dart';
import '../research/my_research_screen.dart';
import '../research/analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  UserModel? _currentUser;
  bool _isLoading = true;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await AuthRepository.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLogoutDialog(),
    );

    if (shouldLogout == true) {
      await AuthRepository.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.landing,
        (route) => false,
      );
    }
  }

  Widget _buildLogoutDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text("Log Out"),
        ],
      ),
      content: Text(
        "Are you sure you want to log out of your account?",
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            "Cancel",
            style: AppTextStyles.button.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Log Out",
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  List<Widget> get _pages => [
    const BrowseResearchScreen(),
    const MyResearchScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _pages[_currentIndex],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // NU Logo with subtle animation
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "NU",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Greeting with improved typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isLoading
                      ? "..."
                      : _currentUser?.fullName.split(' ')[0] ?? 'User',
                  style: AppTextStyles.heading4.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Notification with modern badge
          _buildAppBarButton(
            icon: Icons.notifications_outlined,
            onPressed: () {},
            showBadge: true,
          ),

          const SizedBox(width: 10),

          // Logout with tooltip
          _buildAppBarButton(
            icon: Icons.logout_rounded,
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool showBadge = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: showBadge
              ? Badge(
                  smallSize: 9,
                  backgroundColor: AppColors.accent,
                  child: Icon(icon, color: Colors.white, size: 22),
                )
              : Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.submitResearch),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add_rounded, size: 20),
        ),
        label: Text(
          "Submit Research",
          style: AppTextStyles.buttonMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.explore_rounded, Icons.explore_outlined, "Explore"),
              _buildNavItem(1, Icons.folder_rounded, Icons.folder_outlined, "My Papers"),
              _buildNavItem(2, Icons.analytics_rounded, Icons.analytics_outlined, "Analytics"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
