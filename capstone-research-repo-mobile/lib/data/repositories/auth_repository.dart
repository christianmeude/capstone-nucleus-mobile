import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/exceptions/app_exceptions.dart';

/// Repository for authentication operations
class AuthRepository {
  /// Login with email and password
  static Future<UserModel> login(String email, String password) async {
    try {
      final result = await SupabaseService.login(email, password);
      final userData = result['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e.toString().contains('Invalid')) {
        throw InvalidCredentialsException();
      }
      rethrow;
    }
  }

  /// Register a new user
  static Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? program,
  }) async {
    try {
      final result = await SupabaseService.register(
        email: email,
        password: password,
        fullName: fullName,
        program: program,
      );
      final userData = result['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e.toString().contains('already exists')) {
        throw UserAlreadyExistsException();
      }
      rethrow;
    }
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
    final userId = prefs.getString(StorageKeys.userId);
    return userId != null;
  }

  /// Get current user's role
  static Future<String?> getCurrentUserRole() async {
    return await SupabaseService.getCurrentUserRole();
  }
}
