import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/research_repository.dart';
import '../../../data/models/research_model.dart';
import '../../widgets/common/animated_widgets.dart';

class MyResearchScreen extends StatefulWidget {
  final Future<List<ResearchModel>>? papersFuture;

  const MyResearchScreen({super.key, this.papersFuture});

  @override
  State<MyResearchScreen> createState() => _MyResearchScreenState();
}

class _MyResearchScreenState extends State<MyResearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Published, Pending, Rejected
  String _viewMode = 'list'; // 'list' or 'tile'
  Future<List<ResearchModel>>? _papersFuture;

  @override
  void initState() {
    super.initState();
    _papersFuture = widget.papersFuture;
  }

  @override
  void didUpdateWidget(covariant MyResearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.papersFuture != widget.papersFuture &&
        widget.papersFuture != null) {
      _papersFuture = widget.papersFuture;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reloadPapers() async {
    setState(() {
      _papersFuture = ResearchRepository.getMyResearch();
    });
    await _papersFuture;
  }

  List<ResearchModel> _filterPapers(List<ResearchModel> papers) {
    var filtered = papers;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((paper) {
        if (_selectedFilter == 'Published') {
          return paper.status == AppConstants.statusApproved ||
              paper.status == 'published';
        } else if (_selectedFilter == 'Pending') {
          return paper.status == AppConstants.statusPending;
        } else if (_selectedFilter == 'Rejected') {
          return paper.status == AppConstants.statusRejected;
        }
        return true;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((paper) {
        final query = _searchQuery.toLowerCase();
        return paper.title.toLowerCase().contains(query) ||
            (paper.authorName?.toLowerCase().contains(query) ?? false) ||
            (paper.department?.toLowerCase().contains(query) ?? false) ||
            (paper.keywords?.any((k) => k.toLowerCase().contains(query)) ??
                false);
      }).toList();
    }

    // Sort by created date (newest first)
    filtered.sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
        a.createdAt ?? DateTime.now(),
      ),
    );

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final papersFuture = _papersFuture ??= ResearchRepository.getMyResearch();

    return FutureBuilder<List<ResearchModel>>(
      future: papersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final allPapers = snapshot.data ?? [];
        final filteredPapers = _filterPapers(allPapers);

        return RefreshIndicator(
          onRefresh: _reloadPapers,
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
                _buildStatsRow(allPapers),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 20),
                if (allPapers.isEmpty)
                  _buildEmptyState()
                else if (filteredPapers.isEmpty)
                  _buildNoResultsState()
                else
                  _buildPapersList(filteredPapers),
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

  Widget _buildErrorState(String message) {
    final clean = message.replaceFirst('Exception: ', '');

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unable to load your papers',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clean,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search by title, author, keywords...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textLight,
            height: 1.1,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textLight,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textLight,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Published', 'Pending', 'Rejected'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          Color chipColor;

          switch (filter) {
            case 'Published':
              chipColor = AppColors.success;
              break;
            case 'Pending':
              chipColor = AppColors.warning;
              break;
            case 'Rejected':
              chipColor = AppColors.error;
              break;
            default:
              chipColor = AppColors.primary;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: AppColors.surfaceLight,
              selectedColor: chipColor.withOpacity(0.12),
              checkmarkColor: chipColor,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? chipColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? chipColor : AppColors.borderLight,
                width: isSelected ? 1.5 : 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              showCheckmark: true,
              shape: const StadiumBorder(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 30,
                color: AppColors.textLight,
              ),
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

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 30,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            Text("No Results Found", style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search\nor filter criteria",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedFilter = 'All';
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear Filters'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedFilter == 'All'
                  ? "All Submissions"
                  : "$_selectedFilter Submissions",
              style: AppTextStyles.labelMedium,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${papers.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildViewToggle(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_viewMode == 'list')
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: papers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final paper = papers[index];
              return _PaperStatusCard(paper: paper);
            },
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
              return _PaperTileCard(paper: paper);
            },
          ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.borderLight, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildViewToggleButton(
            icon: Icons.view_list_rounded,
            mode: 'list',
            isSelected: _viewMode == 'list',
          ),
          _buildViewToggleButton(
            icon: Icons.apps_rounded,
            mode: 'tile',
            isSelected: _viewMode == 'tile',
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required String mode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textLight,
          size: 19,
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: AppTextStyles.heading4.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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

class _PaperTileCard extends StatelessWidget {
  final ResearchModel paper;

  const _PaperTileCard({required this.paper});

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
      statusLabel = "Pending";
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
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
