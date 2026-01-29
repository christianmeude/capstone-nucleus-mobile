/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'NUcleus';
  static const String appTagline = 'Research Hub';
  static const String appDescription =
      'The central hub for academic research and collaboration at National University.';

  // Supported Roles
  static const String roleStudent = 'student';
  static const String roleFaculty = 'faculty';
  static const String roleStaff = 'staff';
  static const String roleAdmin = 'admin';

  // Research Status
  static const String statusPending = 'pending';
  static const String statusPendingFaculty = 'pending_faculty';
  static const String statusPendingEditor = 'pending_editor';
  static const String statusPendingAdmin = 'pending_admin';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusRevisionRequired = 'revision_required';

  // File Constraints
  static const int maxFileSizeMB = 10;
  static const List<String> allowedFileExtensions = ['pdf'];

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
