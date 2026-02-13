import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/faculty_member_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/research_repository.dart';
import '../../widgets/common/animated_widgets.dart';

/// Maximum file size allowed: 10MB
const int kMaxFileSizeBytes = 10 * 1024 * 1024;

/// Minimum title length required
const int kMinTitleLength = 10;

/// Minimum abstract length required
const int kMinAbstractLength = 50;

class SubmitResearchScreen extends StatefulWidget {
  const SubmitResearchScreen({super.key});

  @override
  State<SubmitResearchScreen> createState() => _SubmitResearchScreenState();
}

class _SubmitResearchScreenState extends State<SubmitResearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _abstractController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _departmentController = TextEditingController();

  final _titleFocus = FocusNode();
  final _abstractFocus = FocusNode();
  final _keywordsFocus = FocusNode();
  final _departmentFocus = FocusNode();
  final _coAuthorSearchController = TextEditingController();
  final _coAuthorSearchFocus = FocusNode();

  // Selected values
  CategoryModel? _selectedCategory;
  FacultyMemberModel? _selectedFaculty;

  // Co-author search state
  List<StudentModel> _selectedCoAuthors = [];
  List<StudentModel> _coAuthorSearchResults = [];
  bool _isSearchingCoAuthors = false;
  bool _showCoAuthorResults = false;

  // Dropdown data
  List<CategoryModel> _categories = [];
  List<FacultyMemberModel> _facultyMembers = [];
  bool _isLoadingCategories = true;
  bool _isLoadingFaculty = true;

  // File picker state
  String? _pickedPath;
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  int? _pickedFileSize;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _abstractController.dispose();
    _keywordsController.dispose();
    _departmentController.dispose();
    _coAuthorSearchController.dispose();
    _titleFocus.dispose();
    _abstractFocus.dispose();
    _keywordsFocus.dispose();
    _departmentFocus.dispose();
    _coAuthorSearchFocus.dispose();
    super.dispose();
  }

  /// Load categories and faculty members for dropdowns
  Future<void> _loadDropdownData() async {
    await Future.wait([_loadCategories(), _loadFacultyMembers()]);
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await ResearchRepository.getCategories();
      setState(() {
        _categories = categoriesData
            .map((c) => CategoryModel.fromJson(c))
            .toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        _showErrorSnackbar('Failed to load categories');
      }
    }
  }

  Future<void> _loadFacultyMembers() async {
    try {
      final facultyData = await ResearchRepository.getFacultyMembers();
      setState(() {
        _facultyMembers = facultyData
            .map((f) => FacultyMemberModel.fromJson(f))
            .toList();
        _isLoadingFaculty = false;
      });
    } catch (e) {
      debugPrint('Error loading faculty members: $e');
      setState(() => _isLoadingFaculty = false);
      // Don't show error for faculty - it's optional
    }
  }

  /// Search for students to add as co-authors
  Future<void> _searchCoAuthors(String query) async {
    if (query.length < 2) {
      setState(() {
        _coAuthorSearchResults = [];
        _showCoAuthorResults = false;
      });
      return;
    }

    setState(() => _isSearchingCoAuthors = true);

    try {
      final results = await ResearchRepository.searchStudents(query);
      setState(() {
        _coAuthorSearchResults = results
            .map((s) => StudentModel.fromJson(s))
            .where(
              (s) => !_selectedCoAuthors.any((selected) => selected.id == s.id),
            )
            .toList();
        _showCoAuthorResults = _coAuthorSearchResults.isNotEmpty;
        _isSearchingCoAuthors = false;
      });
    } catch (e) {
      debugPrint('Error searching students: $e');
      setState(() {
        _coAuthorSearchResults = [];
        _isSearchingCoAuthors = false;
      });
    }
  }

  /// Add a co-author to the selected list
  void _addCoAuthor(StudentModel student) {
    if (!_selectedCoAuthors.any((s) => s.id == student.id)) {
      setState(() {
        _selectedCoAuthors.add(student);
        _coAuthorSearchController.clear();
        _coAuthorSearchResults = [];
        _showCoAuthorResults = false;
      });
    }
  }

  /// Remove a co-author from the selected list
  void _removeCoAuthor(StudentModel student) {
    setState(() {
      _selectedCoAuthors.removeWhere((s) => s.id == student.id);
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) return;

    final pf = result.files.single;
    final fileSize = pf.size;

    // Validate file size (max 10MB)
    if (fileSize > kMaxFileSizeBytes) {
      _showErrorSnackbar(
        'File size exceeds 10MB limit. Please select a smaller file.',
      );
      return;
    }

    // Validate file type (PDF only)
    final extension = pf.extension?.toLowerCase();
    if (extension != 'pdf') {
      _showErrorSnackbar('Only PDF files are allowed.');
      return;
    }

    if (kIsWeb || pf.path == null) {
      setState(() {
        _pickedBytes = pf.bytes;
        _pickedFilename = pf.name;
        _pickedPath = null;
        _pickedFileSize = fileSize;
      });
    } else {
      setState(() {
        _pickedPath = pf.path;
        _pickedBytes = null;
        _pickedFilename = pf.name;
        _pickedFileSize = fileSize;
      });
    }
  }

  /// Validate title field (required, min 10 characters)
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < kMinTitleLength) {
      return 'Title must be at least $kMinTitleLength characters';
    }
    return null;
  }

  /// Validate abstract field (required, min 50 characters)
  String? _validateAbstract(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Abstract is required';
    }
    if (value.trim().length < kMinAbstractLength) {
      return 'Abstract must be at least $kMinAbstractLength characters';
    }
    return null;
  }

  Future<void> _submit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Validate category selection
    if (_selectedCategory == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }

    // Validate file selection
    if (_pickedPath == null && _pickedBytes == null) {
      _showErrorSnackbar('Please upload a PDF file');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      Uint8List bytes;
      String filename;

      if (_pickedBytes != null) {
        bytes = _pickedBytes!;
        filename = _pickedFilename ?? 'upload.pdf';
      } else {
        final file = File(_pickedPath!);
        bytes = await file.readAsBytes();
        filename = _pickedFilename ?? 'upload.pdf';
      }

      // Build co-authors string from selected students
      String? coAuthorsString;
      if (_selectedCoAuthors.isNotEmpty) {
        coAuthorsString = _selectedCoAuthors.map((s) => s.fullName).join(', ');
      }

      // Submit research with workflow detection:
      // - If faculty selected → pending_faculty (Faculty Review first)
      // - If no faculty → pending_editor (Staff/Editor Review first)
      await ResearchRepository.submitResearch(
        title: _titleController.text.trim(),
        abstract: _abstractController.text.trim(),
        keywords: _keywordsController.text.trim().isEmpty
            ? null
            : _keywordsController.text.trim(),
        category: _selectedCategory!.name,
        coAuthors: coAuthorsString,
        facultyId: _selectedFaculty?.id,
        department: _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
        fileBytes: bytes,
        filename: filename,
      );

      if (!mounted) return;

      // Show success message with workflow info
      final workflowMessage = _selectedFaculty != null
          ? 'Your paper will be reviewed by ${_selectedFaculty!.fullName} first.'
          : 'Your paper will be reviewed by our editorial staff.';

      _showSuccessDialog('Research Submitted Successfully!', workflowMessage);
    } catch (e) {
      _showErrorSnackbar('Submission failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _buildWorkflowSummary(),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowSummary() {
    final hasFaculty = _selectedFaculty != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Workflow:',
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildWorkflowStep(
            step: 1,
            title: hasFaculty ? 'Faculty Review' : 'Editorial Review',
            isActive: true,
            isFirst: true,
          ),
          _buildWorkflowStep(
            step: hasFaculty ? 2 : 1,
            title: hasFaculty ? 'Editorial Review' : 'Admin Approval',
            isActive: false,
            isFirst: false,
          ),
          if (hasFaculty)
            _buildWorkflowStep(
              step: 3,
              title: 'Admin Approval',
              isActive: false,
              isFirst: false,
            ),
          _buildWorkflowStep(
            step: hasFaculty ? 4 : 2,
            title: 'Published',
            isActive: false,
            isFirst: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStep({
    required int step,
    required String title,
    required bool isActive,
    required bool isFirst,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 16, color: AppColors.borderLight),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background decoration
          _buildBackground(),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 28),
                          _buildFormFields(),
                          const SizedBox(height: 24),
                          _buildFilePicker(),
                          const SizedBox(height: 24),
                          _buildApprovalWorkflowInfo(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      right: -80,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.accent.withOpacity(0.1),
              AppColors.accent.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [AppColors.softShadow],
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  color: AppColors.textPrimary,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              "Submit Research 📝",
              style: AppTextStyles.display.copyWith(fontSize: 32),
            )
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 8),

        Text(
              "Share your academic work with the community",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Title (required, min 10 characters)
        AnimatedInputField(
              controller: _titleController,
              focusNode: _titleFocus,
              label: "Research Title *",
              hint: "Enter your research title (min. 10 characters)",
              prefixIcon: Icons.title_rounded,
              validator: _validateTitle,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _abstractFocus.requestFocus(),
            )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 18),

        // Abstract (required, min 50 characters)
        _buildTextAreaField(
          controller: _abstractController,
          focusNode: _abstractFocus,
          label: "Abstract *",
          hint: "Provide a summary of your research (min. 50 characters)...",
          icon: Icons.description_outlined,
          maxLines: 6,
          validator: _validateAbstract,
          delay: 400,
        ),

        const SizedBox(height: 18),

        // Category Dropdown (required)
        _buildCategoryDropdown()
            .animate()
            .fadeIn(delay: 500.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 18),

        // Faculty Advisor Dropdown (optional)
        _buildFacultyDropdown()
            .animate()
            .fadeIn(delay: 600.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 18),

        // Department (optional)
        AnimatedInputField(
              controller: _departmentController,
              focusNode: _departmentFocus,
              label: "Department (Optional)",
              hint: "e.g., Computer Science, Biology",
              prefixIcon: Icons.business_outlined,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _keywordsFocus.requestFocus(),
            )
            .animate()
            .fadeIn(delay: 700.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 18),

        // Keywords (optional)
        AnimatedInputField(
              controller: _keywordsController,
              focusNode: _keywordsFocus,
              label: "Keywords (Optional)",
              hint: "AI, Machine Learning, Neural Networks",
              prefixIcon: Icons.tag_rounded,
              textInputAction: TextInputAction.done,
            )
            .animate()
            .fadeIn(delay: 800.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 18),

        // Co-authors (optional) - Search for students
        _buildCoAuthorField()
            .animate()
            .fadeIn(delay: 900.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildCoAuthorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Co-authors (Optional)",
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Search and add other students as co-authors',
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Selected co-authors chips
        if (_selectedCoAuthors.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedCoAuthors.map((student) {
              return Chip(
                label: Text(
                  student.fullName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                deleteIconColor: AppColors.primary,
                onDeleted: () => _removeCoAuthor(student),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Search input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.softShadow],
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _coAuthorSearchController,
                focusNode: _coAuthorSearchFocus,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search students by name or email...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                  prefixIcon: const Icon(
                    Icons.person_search_rounded,
                    color: AppColors.textLight,
                    size: 22,
                  ),
                  suffixIcon: _isSearchingCoAuthors
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      : _coAuthorSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          color: AppColors.textLight,
                          onPressed: () {
                            _coAuthorSearchController.clear();
                            setState(() {
                              _coAuthorSearchResults = [];
                              _showCoAuthorResults = false;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.borderLight.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: _searchCoAuthors,
              ),

              // Search results dropdown
              if (_showCoAuthorResults && _coAuthorSearchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.borderLight.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _coAuthorSearchResults.length,
                    itemBuilder: (context, index) {
                      final student = _coAuthorSearchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            student.fullName.isNotEmpty
                                ? student.fullName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          student.fullName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          student.program ?? student.email,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                        ),
                        onTap: () => _addCoAuthor(student),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Helper text
        const SizedBox(height: 8),
        Text(
          'Type at least 2 characters to search for students',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category *",
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.softShadow],
          ),
          child: _isLoadingCategories
              ? _buildLoadingDropdown('Loading categories...')
              : DropdownButtonFormField<CategoryModel>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: AppColors.textLight,
                      size: 22,
                    ),
                    hintText: 'Select a category',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.borderLight.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<CategoryModel>(
                      value: category,
                      child: Text(
                        category.name,
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
        ),
      ],
    );
  }

  Widget _buildFacultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Faculty Advisor (Optional)",
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message:
                  'Selecting a faculty advisor means your paper will be reviewed by them first before going to the editorial staff.',
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.softShadow],
          ),
          child: _isLoadingFaculty
              ? _buildLoadingDropdown('Loading faculty members...')
              : DropdownButtonFormField<FacultyMemberModel?>(
                  value: _selectedFaculty,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.textLight,
                      size: 22,
                    ),
                    hintText: 'Select a faculty advisor (optional)',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.borderLight.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items: [
                    // Add "None" option
                    DropdownMenuItem<FacultyMemberModel?>(
                      value: null,
                      child: Text(
                        'No faculty advisor',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    ..._facultyMembers.map((faculty) {
                      return DropdownMenuItem<FacultyMemberModel>(
                        value: faculty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              faculty.fullName,
                              style: AppTextStyles.bodyMedium,
                            ),
                            if (faculty.department != null &&
                                faculty.department!.isNotEmpty)
                              Text(
                                faculty.department!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedFaculty = value);
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingDropdown(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required int maxLines,
    String? Function(String?)? validator,
    required int delay,
  }) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.softShadow],
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                maxLines: maxLines,
                validator: validator,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 12,
                      top: 16,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      widthFactor: 1.0,
                      heightFactor: 5.5,
                      child: Icon(icon, color: AppColors.textLight, size: 22),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.borderLight.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildFilePicker() {
    final hasFile = _pickedFilename != null;
    final fileSizeFormatted = _pickedFileSize != null
        ? _formatFileSize(_pickedFileSize!)
        : null;

    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasFile
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.borderLight,
              width: hasFile ? 2 : 1,
            ),
            boxShadow: [AppColors.softShadow],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: hasFile
                        ? AppColors.success.withOpacity(0.05)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasFile
                          ? AppColors.success.withOpacity(0.2)
                          : Colors.transparent,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: hasFile
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasFile
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_rounded,
                          size: 36,
                          color: hasFile
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hasFile ? "File Selected!" : "Upload PDF File *",
                        style: AppTextStyles.heading4.copyWith(
                          color: hasFile
                              ? AppColors.success
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasFile ? _pickedFilename! : "Tap to browse your files",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (hasFile && fileSizeFormatted != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Size: $fileSizeFormatted',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                      if (!hasFile) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PDF only • Max 10MB',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (hasFile) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Change File"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Widget _buildApprovalWorkflowInfo() {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.info.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Approval Workflow',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _selectedFaculty != null
                    ? '📋 Your paper will go through:'
                    : '📋 Your paper will go through:',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedFaculty != null) ...[
                _buildWorkflowInfoStep(
                  1,
                  'Faculty Review',
                  'Your advisor ${_selectedFaculty!.fullName} will review first',
                  true,
                ),
                _buildWorkflowInfoStep(
                  2,
                  'Editorial Review',
                  'Staff editors will verify content',
                  false,
                ),
                _buildWorkflowInfoStep(
                  3,
                  'Admin Approval',
                  'Final approval for publication',
                  false,
                ),
              ] else ...[
                _buildWorkflowInfoStep(
                  1,
                  'Editorial Review',
                  'Staff editors will review your paper',
                  true,
                ),
                _buildWorkflowInfoStep(
                  2,
                  'Admin Approval',
                  'Final approval for publication',
                  false,
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 1100.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildWorkflowInfoStep(
    int step,
    String title,
    String description,
    bool isFirst,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 8, top: isFirst ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isFirst
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.borderLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  fontSize: 10,
                  color: isFirst ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isFirst ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedPrimaryButton(
          text: "Submit Research",
          icon: Icons.send_rounded,
          isLoading: _isSubmitting,
          onPressed: _submit,
        )
        .animate()
        .fadeIn(delay: 1200.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}
