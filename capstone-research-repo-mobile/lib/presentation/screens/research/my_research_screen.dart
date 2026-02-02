import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/research_repository.dart';
import '../../../data/models/research_model.dart';
import '../../widgets/common/animated_widgets.dart';

class MyResearchScreen extends StatefulWidget {
  const MyResearchScreen({super.key});

  @override
  State<MyResearchScreen> createState() => _MyResearchScreenState();
}

class _MyResearchScreenState extends State<MyResearchScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ResearchModel>>(
      future: ResearchRepository.getMyResearch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final papers = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildStatsRow(papers),
                const SizedBox(height: 28),
                if (papers.isEmpty)
                  _buildEmptyState()
                else
                  _buildPapersList(papers),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 180, height: 32, borderRadius: 8),
          const SizedBox(height: 8),
          const ShimmerBox(width: 240, height: 16, borderRadius: 6),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                  child: const ShimmerBox(height: 90, borderRadius: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: const ShimmerBox(height: 80, borderRadius: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("My Research", style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text(
          "Track your submissions and progress",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(List<ResearchModel> papers) {
    final published = papers
        .where(
          (p) =>
              p.status == AppConstants.statusApproved ||
              p.status == 'published',
        )
        .length;
    final pending = papers
        .where((p) => p.status == AppConstants.statusPending)
        .length;
    final rejected = papers
        .where((p) => p.status == AppConstants.statusRejected)
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            label: "Published",
            count: published,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule_rounded,
            label: "Pending",
            count: pending,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.cancel_rounded,
            label: "Rejected",
            count: rejected,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text("No Submissions Yet", style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            Text(
              "Start sharing your research\nwith the community!",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPapersList(List<ResearchModel> papers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("All Submissions", style: AppTextStyles.labelMedium),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: papers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final paper = papers[index];
            return _PaperStatusCard(paper: paper);
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: AppTextStyles.heading4.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
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

class _PaperStatusCard extends StatelessWidget {
  final ResearchModel paper;

  const _PaperStatusCard({required this.paper});

  @override
  Widget build(BuildContext context) {
    final status = paper.status;
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (status == AppConstants.statusApproved || status == 'published') {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = "Published";
    } else if (status == AppConstants.statusRejected) {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_rounded;
      statusLabel = "Rejected";
    } else {
      statusColor = AppColors.warning;
      statusIcon = Icons.schedule_rounded;
      statusLabel = "Pending Review";
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paper.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }
}
