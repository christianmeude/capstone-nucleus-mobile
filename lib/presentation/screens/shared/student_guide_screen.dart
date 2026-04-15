import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StudentGuideScreen extends StatelessWidget {
  const StudentGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
              child: Row(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Guide',
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How to use the mobile research repository',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GuideHeroCard(
                    title: 'Designed for student workflows',
                    description:
                        'Browse approved papers, submit new research, and track the progress of your own papers from one mobile app.',
                    icon: Icons.school_rounded,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Core Tasks',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GuideSectionCard(
                    title: 'Browse Research',
                    icon: Icons.explore_rounded,
                    color: AppColors.primary,
                    steps: const [
                      'Search approved papers by title, author, keyword, or category.',
                      'Switch between list and tile layouts for your preferred view.',
                      'Open any paper to read the abstract and details.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _GuideSectionCard(
                    title: 'Submit Research',
                    icon: Icons.upload_rounded,
                    color: AppColors.secondary,
                    steps: const [
                      'Prepare a PDF version of your paper before submitting.',
                      'Fill in title, abstract, keywords, category, and adviser.',
                      'Add co-authors if needed, then upload and submit.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _GuideSectionCard(
                    title: 'Track My Papers',
                    icon: Icons.folder_rounded,
                    color: AppColors.accentDark,
                    steps: const [
                      'Monitor whether your paper is pending, under review, or published.',
                      'Review revision notes and rejection feedback when returned.',
                      'Use the list or tile layout to scan your submissions quickly.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _GuideSectionCard(
                    title: 'Notifications',
                    icon: Icons.notifications_rounded,
                    color: AppColors.warning,
                    steps: const [
                      'Check for updates when reviewers change your paper status.',
                      'Use the profile page or top bar icon to revisit updates quickly.',
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tips',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TipTile(
                    icon: Icons.check_circle_rounded,
                    title: 'Keep your PDF final',
                    subtitle:
                        'Make sure your uploaded document is the final submission version.',
                  ),
                  _TipTile(
                    icon: Icons.refresh_rounded,
                    title: 'Check revision notes',
                    subtitle:
                        'If a paper is returned, read the notes before resubmitting.',
                  ),
                  _TipTile(
                    icon: Icons.person_search_rounded,
                    title: 'Use search filters',
                    subtitle:
                        'Filtering by keyword or status makes it easier to find the paper you need.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideHeroCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _GuideHeroCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.10),
            AppColors.accent.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> steps;

  const _GuideSectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '•',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      step,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TipTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
