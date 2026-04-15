import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/research_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/research_repository.dart';
import '../../widgets/common/animated_widgets.dart';
import '../../../routes/app_routes.dart';

class ProfileDashboardScreen extends StatefulWidget {
  const ProfileDashboardScreen({super.key});

  @override
  State<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends State<ProfileDashboardScreen> {
  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadProfileData();
  }

  Future<_ProfileData> _loadProfileData() async {
    final results = await Future.wait([
      AuthRepository.getCurrentUser(),
      ResearchRepository.getMyResearch(),
    ]);

    return _ProfileData(
      user: results[0] as UserModel?,
      papers: results[1] as List<ResearchModel>,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadProfileData();
    });
    await _future;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  String _initials(UserModel? user) {
    if (user == null) return '?';
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1)
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final data = snapshot.data;
        final user = data?.user;
        final papers = data?.papers ?? [];

        if (user == null) {
          return _buildErrorState('Unable to load profile data.');
        }

        final total = papers.length;
        final published = papers
            .where(
              (paper) =>
                  paper.status == 'approved' || paper.status == 'published',
            )
            .length;
        final pending = papers
            .where(
              (paper) =>
                  paper.status == 'pending' ||
                  paper.status == 'pending_faculty' ||
                  paper.status == 'pending_editor' ||
                  paper.status == 'pending_admin',
            )
            .length;
        final revisions = papers
            .where((paper) => paper.status == 'revision_required')
            .length;
        final rejected = papers
            .where((paper) => paper.status == 'rejected')
            .length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 20,
                      20,
                      24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.16),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Profile',
                              style: AppTextStyles.heading4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _initials(user),
                                  style: AppTextStyles.heading3.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.78),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _HeaderChip(label: 'Student'),
                                      if ((user.program ?? '').isNotEmpty)
                                        _HeaderChip(label: user.program!),
                                      _HeaderChip(
                                        label:
                                            'Member since ${_formatDate(user.createdAt)}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Research Snapshot',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Total',
                                value: total,
                                icon: Icons.folder_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Published',
                                value: published,
                                icon: Icons.check_circle_rounded,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Pending',
                                value: pending,
                                icon: Icons.schedule_rounded,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Revision',
                                value: revisions,
                                icon: Icons.edit_note_rounded,
                                color: AppColors.accentDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _StatCard(
                          label: 'Rejected',
                          value: rejected,
                          icon: Icons.cancel_rounded,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Quick Actions',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          title: 'Browse Repository',
                          subtitle: 'Explore approved papers',
                          icon: Icons.explore_rounded,
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.popUntil(
                              context,
                              (route) => route.settings.name == AppRoutes.home,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          title: 'Submit Research',
                          subtitle: 'Upload a new paper',
                          icon: Icons.upload_rounded,
                          color: AppColors.secondary,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.submitResearch,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          title: 'Notifications',
                          subtitle: 'See latest research updates',
                          icon: Icons.notifications_rounded,
                          color: AppColors.accentDark,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.notifications,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          title: 'User Guide',
                          subtitle: 'Learn how to use the mobile app',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.primary,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.guide),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Account Details',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailTile(label: 'Email', value: user.email),
                        _DetailTile(label: 'Role', value: 'Student'),
                        _DetailTile(
                          label: 'Program',
                          value: user.program ?? 'Not set',
                        ),
                        _DetailTile(
                          label: 'Status',
                          value: 'Active student account',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(width: 160, height: 28, borderRadius: 8),
              const SizedBox(height: 16),
              const ShimmerBox(height: 170, borderRadius: 28),
              const SizedBox(height: 20),
              const ShimmerBox(width: 140, height: 18, borderRadius: 6),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: ShimmerBox(height: 92, borderRadius: 16)),
                  SizedBox(width: 12),
                  Expanded(child: ShimmerBox(height: 92, borderRadius: 16)),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: ShimmerBox(height: 92, borderRadius: 16)),
                  SizedBox(width: 12),
                  Expanded(child: ShimmerBox(height: 92, borderRadius: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final clean = message.replaceFirst('Exception: ', '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 16),
              Text('Unable to load profile', style: AppTextStyles.heading4),
              const SizedBox(height: 8),
              Text(
                clean,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

class _ProfileData {
  final UserModel? user;
  final List<ResearchModel> papers;

  const _ProfileData({required this.user, required this.papers});
}

class _HeaderChip extends StatelessWidget {
  final String label;

  const _HeaderChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: AppTextStyles.heading4.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
