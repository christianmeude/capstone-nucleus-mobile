import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/exceptions/app_exceptions.dart';

/// Repository for authentication operations
class AuthRepository {
  /// Login with email and password
  static Future<UserModel> login(String email, String password) async {
    final result = await SupabaseService.login(email, password);
    final userData = Map<String, dynamic>.from(result['user'] as Map);
    final user = UserModel.fromJson(userData);

    if (user.role != AppConstants.roleStudent) {
      await SupabaseService.logout();
      throw ValidationException('Only student accounts are supported in this app.');
    }

    return user;
  }

  /// Register a new user
  static Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String role = AppConstants.roleStudent,
    String? department,
    String? departmentId,
    String? program,
    String? programId,
  }) async {
    final result = await SupabaseService.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      department: department,
      departmentId: departmentId,
      program: program,
      programId: programId,
    );

    final userData = Map<String, dynamic>.from(result['user'] as Map);
    final user = UserModel.fromJson(userData);

    if (user.role != AppConstants.roleStudent) {
      await SupabaseService.logout();
      throw ValidationException('Only student accounts are supported in this app.');
    }

    return user;
  }

  /// Logout the current user
  static Future<void> logout() async {
    await SupabaseService.logout();
  }

  /// Get the current logged-in user
  static Future<UserModel?> getCurrentUser() async {
    return await SupabaseService.getCurrentUser();
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(StorageKeys.accessToken) ?? '').isNotEmpty ||
        (prefs.getString(StorageKeys.refreshToken) ?? '').isNotEmpty ||
        (prefs.getString(StorageKeys.userId) ?? '').isNotEmpty;
  }

  /// Get current user's role
  static Future<String?> getCurrentUserRole() async {
    return await SupabaseService.getCurrentUserRole();
  }
}
