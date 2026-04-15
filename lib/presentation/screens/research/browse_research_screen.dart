import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/research_repository.dart';
import '../../../data/models/research_model.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common/animated_widgets.dart';

class BrowseResearchScreen extends StatefulWidget {
  const BrowseResearchScreen({super.key});

  @override
  State<BrowseResearchScreen> createState() => _BrowseResearchScreenState();
}

class _BrowseResearchScreenState extends State<BrowseResearchScreen> {
  // Category filter
  String _selectedCategory = "All";
  final List<String> _categories = ["All", "Published", "Recent", "Popular"];
  String _viewMode = 'list'; // 'list' or 'tile'

  bool _showFilters = false;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _selectedSearchFilter = 'All';
  final List<String> _searchFilters = ['All', 'Title', 'Author', 'Keywords'];

  List<ResearchModel> _papers = [];
  List<ResearchModel> _filteredPapers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _loadPapers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {});
  }

  Future<void> _loadPapers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('📚 Loading published papers...');
      final papers = await ResearchRepository.getPublishedPapers();
      debugPrint('📚 Loaded ${papers.length} papers');
      if (mounted) {
        setState(() {
          _papers = papers;
          _filteredPapers = papers;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading papers: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    List<ResearchModel> results = _papers;

    // Apply search filter
    if (query.isNotEmpty) {
      switch (_selectedSearchFilter) {
        case 'Title':
          results = results
              .where((p) => p.title.toLowerCase().contains(query))
              .toList();
          break;
        case 'Author':
          results = results
              .where((p) => (p.authorName ?? '').toLowerCase().contains(query))
              .toList();
          break;
        case 'Keywords':
          results = results
              .where(
                (p) =>
                    p.keywords?.any((k) => k.toLowerCase().contains(query)) ??
                    false,
              )
              .toList();
          break;
        default:
          results = results
              .where(
                (p) =>
                    p.title.toLowerCase().contains(query) ||
                    (p.authorName ?? '').toLowerCase().contains(query) ||
                    (p.keywords?.any((k) => k.toLowerCase().contains(query)) ??
                        false) ||
                    p.abstract.toLowerCase().contains(query),
              )
              .toList();
      }
    }

    // Apply category filter
    switch (_selectedCategory) {
      case 'Recent':
        results.sort(
          (a, b) => (b.createdAt ?? DateTime(1900)).compareTo(
            a.createdAt ?? DateTime(1900),
          ),
        );
        break;
      case 'Popular':
        results.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'Published':
        // Already filtered to published papers
        break;
    }

    setState(() {
      _filteredPapers = results;
    });
  }

  void _onSearchChanged(String value) {
    _applyFilters();
  }

  void _clearSearch() {
    _searchController.clear();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Search Header
          _buildSearchHeader(),

          // Research List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                ? _buildErrorState(_error!)
                : _filteredPapers.isEmpty
                ? _buildEmptyState()
                : _buildResearchList(_filteredPapers),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Explore Research",
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "${_papers.length} papers available",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_searchController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    "${_filteredPapers.length} found",
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                _buildViewToggle(),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight, width: 1),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: _onSearchChanged,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: "Search papers, authors, keywords...",
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.textLight.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textSecondary,
                                  size: 16,
                                ),
                              ),
                              visualDensity: VisualDensity.compact,
                              splashRadius: 18,
                            )
                          : null,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  Icons.tune_rounded,
                  color: _showFilters
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22,
                ),
                tooltip: 'Filters',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 42,
                  height: 42,
                ),
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
              ),
            ],
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._searchFilters.map((filter) {
                        final isSelected = _selectedSearchFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            label: filter,
                            isSelected: isSelected,
                            isPrimary: true,
                            onTap: () {
                              setState(() => _selectedSearchFilter = filter);
                              _applyFilters();
                            },
                          ),
                        );
                      }),
                      Container(
                        height: 22,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: AppColors.borderLight,
                      ),
                      ..._categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            label: category,
                            isSelected: isSelected,
                            isPrimary: false,
                            onTap: () {
                              setState(() => _selectedCategory = category);
                              _applyFilters();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 11 : 10,
          vertical: isPrimary ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isPrimary ? AppColors.primary : AppColors.accent)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isPrimary ? AppColors.primary : AppColors.accent)
                : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected
                ? (isPrimary ? Colors.white : AppColors.primary)
                : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const ShimmerBox(height: 88, borderRadius: 12);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text('Unable to Load Papers', style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPapers,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadPapers,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSearching
                          ? Icons.search_off_rounded
                          : Icons.library_books_outlined,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isSearching ? 'No Results Found' : 'No Research Papers Yet',
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearching
                        ? 'Try different keywords or\nadjust your filters'
                        : 'Published research papers will appear here.\nPull down to refresh.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSearching) ...[
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      label: const Text('Clear Search'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResearchList(List<ResearchModel> papers) {
    return RefreshIndicator(
      onRefresh: _loadPapers,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: _viewMode == 'list'
          ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: papers.length,
              itemBuilder: (context, index) {
                final paper = papers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PaperCard(paper: paper),
                );
              },
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: papers.length,
              itemBuilder: (context, index) {
                final paper = papers[index];
                return _PaperTileCard(paper: paper);
              },
            ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight, width: 1),
        borderRadius: BorderRadius.circular(12),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textLight,
          size: 20,
        ),
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final ResearchModel paper;

  const _PaperCard({required this.paper});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.researchDetail,
            arguments: paper,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1),
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
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.article_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Title & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paper.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            paper.category,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Divider
              Container(height: 1, color: AppColors.borderLight),

              const SizedBox(height: 12),

              // Footer Row - Author & Stats
              Row(
                children: [
                  // Author
                  if (paper.authorName != null) ...[
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        paper.authorName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  // Stats
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${paper.viewCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.download_rounded,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${paper.downloadCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaperTileCard extends StatelessWidget {
  final ResearchModel paper;

  const _PaperTileCard({required this.paper});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.researchDetail,
            arguments: paper,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.description_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
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
                      if (paper.authorName != null)
                        Flexible(
                          child: Text(
                            paper.authorName!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
