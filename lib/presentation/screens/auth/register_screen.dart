import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/department_model.dart';
import '../../../data/models/program_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/research_repository.dart';
import '../../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isLoading = false;
  bool _isLoadingLookups = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  List<DepartmentModel> _departments = [];
  List<ProgramModel> _programs = [];
  DepartmentModel? _selectedDepartment;
  ProgramModel? _selectedProgram;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartment == null) {
      _showErrorSnackbar('Please select your department.');
      return;
    }

    if (_selectedProgram == null) {
      _showErrorSnackbar('Please select your program.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthRepository.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: AppConstants.roleStudent,
        department: _selectedDepartment?.name,
        departmentId: _selectedDepartment?.id,
        program: _selectedProgram?.name,
        programId: _selectedProgram?.id,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final list = await ResearchRepository.getDepartments();
      if (!mounted) return;

      setState(() {
        _departments = list.map(DepartmentModel.fromJson).toList();
        _isLoadingLookups = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _departments = [];
        _programs = [];
        _selectedDepartment = null;
        _selectedProgram = null;
        _isLoadingLookups = false;
      });
      _showErrorSnackbar('Failed to load departments and programs.');
    }
  }

  Future<void> _handleDepartmentChanged(DepartmentModel? department) async {
    setState(() {
      _selectedDepartment = department;
      _selectedProgram = null;
      _programs = department?.programs ?? [];
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildFormFields(),
                  const SizedBox(height: 28),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // NU Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "NU",
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          "Create Account",
          style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          "Join the NUcleus research community",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: (_) => onSubmitted?.call(),
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String? Function(T?) validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Full Name
        _buildInputField(
          controller: _nameController,
          focusNode: _nameFocus,
          label: "Full Name",
          hint: "Juan Dela Cruz",
          icon: Icons.person_outline_rounded,
          validator: Validators.validateName,
          textInputAction: TextInputAction.next,
          onSubmitted: () => _emailFocus.requestFocus(),
        ),

        const SizedBox(height: 18),

        // Email
        _buildInputField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: "Email Address",
          hint: "student@national-u.edu.ph",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          textInputAction: TextInputAction.next,
          onSubmitted: () => _passwordFocus.requestFocus(),
        ),

        const SizedBox(height: 18),

        // Department
        _buildDropdownField<DepartmentModel>(
          label: 'Department',
          hint: _isLoadingLookups ? 'Loading departments...' : 'Select your department',
          icon: Icons.apartment_rounded,
          value: _selectedDepartment,
          items: _departments
              .map(
                (department) => DropdownMenuItem<DepartmentModel>(
                  value: department,
                  child: Text(department.displayName),
                ),
              )
              .toList(),
          onChanged: _handleDepartmentChanged,
          validator: (value) => _isLoadingLookups || _departments.isEmpty
              ? null
              : (value == null ? 'Department is required' : null),
          enabled: !_isLoadingLookups && _departments.isNotEmpty,
        ),

        const SizedBox(height: 18),

        // Program
        _buildDropdownField<ProgramModel>(
          label: 'Program',
          hint: _selectedDepartment == null
              ? 'Select a department first'
              : (_isLoadingLookups ? 'Loading programs...' : 'Select your program'),
          icon: Icons.school_rounded,
          value: _selectedProgram,
          items: _programs
              .map(
                (program) => DropdownMenuItem<ProgramModel>(
                  value: program,
                  child: Text(program.displayName),
                ),
              )
              .toList(),
          onChanged: (program) => setState(() => _selectedProgram = program),
          validator: (value) => _isLoadingLookups || _selectedDepartment == null || _programs.isEmpty
              ? null
              : (value == null ? 'Program is required' : null),
          enabled: !_isLoadingLookups && _selectedDepartment != null && _programs.isNotEmpty,
        ),

        const SizedBox(height: 18),

        // Password
        _buildInputField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: "Password",
          hint: "Create a strong password",
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          validator: Validators.validatePassword,
          textInputAction: TextInputAction.next,
          onSubmitted: () => _confirmFocus.requestFocus(),
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Confirm Password
        _buildInputField(
          controller: _confirmController,
          focusNode: _confirmFocus,
          label: "Confirm Password",
          hint: "Re-enter your password",
          icon: Icons.lock_rounded,
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          onSubmitted: _handleRegister,
          validator: (v) =>
              Validators.validateConfirmPassword(v, _passwordController.text),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColors.disabled,
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : Text(
                "CREATE ACCOUNT",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: Text(
            "Sign In",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
