/// Keys used for local storage (SharedPreferences)
class StorageKeys {
  // User Session
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String userName = 'user_name';
  static const String userProgram = 'user_program';

  // App Settings
  static const String themeMode = 'theme_mode';
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String lastSyncTime = 'last_sync_time';

  // Cache Keys
  static const String cachedCategories = 'cached_categories';
  static const String cachedFaculty = 'cached_faculty';
}
