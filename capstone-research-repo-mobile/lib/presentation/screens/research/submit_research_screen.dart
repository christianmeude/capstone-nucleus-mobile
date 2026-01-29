import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/research_repository.dart';
import '../../widgets/common/animated_widgets.dart';

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
  final _categoryController = TextEditingController();
  final _coauthorsController = TextEditingController();

  final _titleFocus = FocusNode();
  final _abstractFocus = FocusNode();
  final _keywordsFocus = FocusNode();
  final _categoryFocus = FocusNode();
  final _coauthorsFocus = FocusNode();

  String? _pickedPath;
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _abstractController.dispose();
    _keywordsController.dispose();
    _categoryController.dispose();
    _coauthorsController.dispose();
    _titleFocus.dispose();
    _abstractFocus.dispose();
    _keywordsFocus.dispose();
    _categoryFocus.dispose();
    _coauthorsFocus.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) return;

    final pf = result.files.single;

    if (kIsWeb || pf.path == null) {
      setState(() {
        _pickedBytes = pf.bytes;
        _pickedFilename = pf.name;
        _pickedPath = null;
      });
    } else {
      setState(() {
        _pickedPath = pf.path;
        _pickedBytes = null;
        _pickedFilename = pf.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedPath == null && _pickedBytes == null) {
      _showErrorSnackbar('Please pick a PDF file to upload');
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

      await ResearchRepository.submitResearch(
        title: _titleController.text.trim(),
        abstract: _abstractController.text.trim(),
        keywords: _keywordsController.text.trim().isEmpty
            ? null
            : _keywordsController.text.trim(),
        category: _categoryController.text.trim(),
        coAuthors: _coauthorsController.text.trim().isEmpty
            ? null
            : _coauthorsController.text.trim(),
        fileBytes: bytes,
        filename: filename,
      );

      if (!mounted) return;

      _showSuccessSnackbar('Research submitted successfully!');
      Navigator.pop(context);
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
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
        // Title
        AnimatedInputField(
              controller: _titleController,
              focusNode: _titleFocus,
              label: "Research Title",
              hint: "Enter your research title",
              prefixIcon: Icons.title_rounded,
              validator: (v) => Validators.validateRequired(v, 'Title'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _abstractFocus.requestFocus(),
            )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 18),

        // Abstract
        _buildTextAreaField(
          controller: _abstractController,
          focusNode: _abstractFocus,
          label: "Abstract",
          hint: "Provide a summary of your research...",
          icon: Icons.description_outlined,
          maxLines: 6,
          validator: (v) => Validators.validateRequired(v, 'Abstract'),
          delay: 400,
        ),

        const SizedBox(height: 18),

        // Category
        AnimatedInputField(
              controller: _categoryController,
              focusNode: _categoryFocus,
              label: "Category",
              hint: "e.g., Computer Science, Biology",
              prefixIcon: Icons.category_outlined,
              validator: (v) => Validators.validateRequired(v, 'Category'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _keywordsFocus.requestFocus(),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 18),

        // Keywords
        AnimatedInputField(
              controller: _keywordsController,
              focusNode: _keywordsFocus,
              label: "Keywords (Optional)",
              hint: "AI, Machine Learning, Neural Networks",
              prefixIcon: Icons.tag_rounded,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _coauthorsFocus.requestFocus(),
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 18),

        // Co-authors
        AnimatedInputField(
              controller: _coauthorsController,
              focusNode: _coauthorsFocus,
              label: "Co-authors (Optional)",
              hint: "John Doe, Jane Smith",
              prefixIcon: Icons.people_outline_rounded,
              textInputAction: TextInputAction.done,
            )
            .animate()
            .fadeIn(delay: 700.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
      ],
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
                        hasFile ? "File Selected!" : "Upload PDF File",
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
        .fadeIn(delay: 800.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildSubmitButton() {
    return AnimatedPrimaryButton(
          text: "Submit Research",
          icon: Icons.send_rounded,
          isLoading: _isSubmitting,
          onPressed: _submit,
        )
        .animate()
        .fadeIn(delay: 900.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}
