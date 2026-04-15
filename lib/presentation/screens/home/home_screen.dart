import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/research_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/research_model.dart';
import '../../../routes/app_routes.dart';
import '../research/browse_research_screen.dart';
import '../research/my_research_screen.dart';
import '../research/analytics_screen.dart';

enum _AccountAction { profile, settings, logout }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserModel? _currentUser;
  bool _isLoading = true;
  int _notificationCount = 0;
  Future<List<ResearchModel>>? _papersFuture;

  Future<List<ResearchModel>> get _sharedPapersFuture {
    return _papersFuture ??= ResearchRepository.getMyResearch();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthRepository.getCurrentUser();
    var notificationCount = 0;

    try {
      final papers = await _sharedPapersFuture;
      notificationCount = papers.where(_requiresNotificationBadge).length;
    } catch (_) {
      notificationCount = 0;
    }

    if (mounted) {
      setState(() {
        _currentUser = user;
        _notificationCount = notificationCount;
        _isLoading = false;
      });
    }
  }

  bool _requiresNotificationBadge(ResearchModel paper) {
    return paper.status != AppConstants.statusApproved &&
        paper.status != 'published';
  }

  void _openAccountAction(_AccountAction action) {
    switch (action) {
      case _AccountAction.profile:
        Navigator.pushNamed(context, AppRoutes.profile);
        return;
      case _AccountAction.settings:
        Navigator.pushNamed(context, AppRoutes.settings);
        return;
      case _AccountAction.logout:
        _handleLogout();
        return;
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BrowseResearchScreen(),
      MyResearchScreen(papersFuture: _sharedPapersFuture),
      AnalyticsScreen(papersFuture: _sharedPapersFuture),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: IndexedStack(index: _currentIndex, children: pages),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // NU Logo with subtle animation
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
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
                  fontSize: 15,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

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
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isLoading
                      ? "..."
                      : _currentUser?.fullName.split(' ')[0] ?? 'User',
                  style: AppTextStyles.heading4.copyWith(
                    fontSize: 19,
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
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
            badgeCount: _notificationCount,
          ),

          const SizedBox(width: 8),

          _buildGuideButton(),

          const SizedBox(width: 8),

          _buildAccountMenuButton(),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
          ),
          child: badgeCount > 0 || showBadge
              ? Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Center(child: Icon(icon, color: Colors.white, size: 22)),
                    if (badgeCount > 0)
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              badgeCount > 99 ? '99+' : badgeCount.toString(),
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (showBadge)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                )
              : Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildGuideButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.guide),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
          ),
          child: Center(
            child: const Icon(
              Icons.question_mark_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountMenuButton() {
    return PopupMenuButton<_AccountAction>(
      tooltip: 'Account menu',
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      offset: const Offset(0, 52),
      onSelected: _openAccountAction,
      itemBuilder: (context) => [
        PopupMenuItem<_AccountAction>(
          value: _AccountAction.profile,
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem<_AccountAction>(
          value: _AccountAction.settings,
          child: Row(
            children: [
              Icon(Icons.settings_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<_AccountAction>(
          value: _AccountAction.logout,
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error),
              const SizedBox(width: 12),
              Text(
                'Log Out',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
          size: 22,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const tabCount = 3;
                  final slotWidth = constraints.maxWidth / tabCount;
                  final selectorWidth = slotWidth - 14;
                  final selectorLeft =
                      (_currentIndex * slotWidth) +
                      ((slotWidth - selectorWidth) / 2);

                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        left: selectorLeft,
                        top: 0,
                        child: Container(
                          width: selectorWidth,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.16),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNavItem(
                              0,
                              Icons.explore_rounded,
                              Icons.explore_outlined,
                              "Explore",
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              1,
                              Icons.folder_rounded,
                              Icons.folder_outlined,
                              "My Papers",
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              2,
                              Icons.analytics_rounded,
                              Icons.analytics_outlined,
                              "Analytics",
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedSlide(
              offset: isSelected ? Offset.zero : const Offset(0, 0.06),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: AnimatedScale(
                scale: isSelected ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                  size: 22,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.vertical,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: isSelected
                  ? Center(
                      key: ValueKey('label_$index'),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(key: ValueKey('label_hidden'), height: 0),
            ),
          ],
        ),
      ),
    );
  }
}
