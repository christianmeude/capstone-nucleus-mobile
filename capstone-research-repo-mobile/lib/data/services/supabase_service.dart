import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../config/supabase_config.dart';
import '../models/user_model.dart';
import '../models/research_model.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  /// Login with email and password
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Query users table directly (same as web app)
    final response = await client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) {
      throw Exception('Invalid email or password');
    }

    // Verify password using bcrypt
    final storedHash = response['password'] as String;
    final isPasswordValid = BCrypt.checkpw(password, storedHash);
    
    if (!isPasswordValid) {
      throw Exception('Invalid email or password');
    }

    // Store user data in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', response['id']);
    await prefs.setString('user_email', response['email']);
    await prefs.setString('user_role', response['role']);
    await prefs.setString('user_name', response['full_name'] ?? '');

    return {
      'user': response,
      'message': 'Login successful',
    };
  }

  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String role = 'student',
    String? program,
  }) async {
    // Check if user already exists
    final existing = await client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      throw Exception('User already exists');
    }

    // Insert new user
    final response = await client.from('users').insert({
      'email': email,
      'password': password, // Note: In production, hash this!
      'full_name': fullName,
      'role': role,
      'program': program,
    }).select().single();

    // Store user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', response['id']);
    await prefs.setString('user_email', response['email']);
    await prefs.setString('user_role', response['role']);
    await prefs.setString('user_name', response['full_name'] ?? '');

    return {
      'user': response,
      'message': 'Registration successful',
    };
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
  }

  /// Get current user from SharedPreferences
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    if (userId == null) return null;

    final response = await client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  /// Get current user ID
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Get current user role
  static Future<String?> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // ==========================================
  // RESEARCH PAPERS
  // ==========================================

  /// Get user's own research papers
  static Future<List<ResearchModel>> getMyResearch() async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('Not authenticated');

    final response = await client
        .from('research_papers')
        .select()
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ResearchModel.fromJson(json))
        .toList();
  }

  /// Get all published/approved papers
  static Future<List<ResearchModel>> getPublishedPapers({
    String? category,
    String? search,
    String? year,
  }) async {
    try {
      // Try fetching with join first
      var query = client
          .from('research_papers')
          .select('*, users!author_id(full_name, email)')
          .or('status.eq.approved,status.eq.published');

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,abstract.ilike.%$search%');
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => ResearchModel.fromJson(json))
          .toList();
    } catch (e) {
      // If join fails, try without join
      debugPrint('⚠️ Query with join failed, trying without: $e');
      
      final response = await client
          .from('research_papers')
          .select('*')
          .or('status.eq.approved,status.eq.published')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ResearchModel.fromJson(json))
          .toList();
    }
  }

  /// Get a single research paper by ID
  static Future<ResearchModel> getResearchById(String id) async {
    final response = await client
        .from('research_papers')
        .select('*, users!author_id(full_name, email)')
        .eq('id', id)
        .single();

    // Increment view count
    await client.rpc('increment_view_count', params: {'row_id': id});

    return ResearchModel.fromJson(response);
  }

  /// Submit new research
  static Future<void> submitResearch({
    required String title,
    required String abstract,
    String? keywords,
    required String category,
    String? coAuthors,
    required Uint8List fileBytes,
    required String filename,
    String? facultyId,
    String? department,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('Not authenticated');

    // Upload file to Supabase Storage
    final filePath = '$userId/${DateTime.now().millisecondsSinceEpoch}_$filename';
    
    await client.storage.from('research-papers').uploadBinary(
      filePath,
      fileBytes,
      fileOptions: const FileOptions(contentType: 'application/pdf'),
    );

    // Get public URL
    final fileUrl = client.storage.from('research-papers').getPublicUrl(filePath);

    // Parse keywords
    List<String>? keywordsList;
    if (keywords != null && keywords.isNotEmpty) {
      keywordsList = keywords.split(',').map((k) => k.trim()).toList();
    }

    // Insert paper record
    await client.from('research_papers').insert({
      'author_id': userId,
      'title': title,
      'abstract': abstract,
      'keywords': keywordsList,
      'category': category,
      'co_authors': coAuthors,
      'file_url': fileUrl,
      'file_name': filename,
      'file_size': fileBytes.length,
      'status': facultyId != null ? 'pending_faculty' : 'pending',
      'faculty_id': facultyId,
      'department': department,
    });
  }

  /// Track download
  static Future<void> trackDownload(String paperId) async {
    final userId = await getCurrentUserId();
    
    await client.rpc('increment_download_count', params: {'row_id': paperId});

    if (userId != null) {
      await client.from('paper_downloads').insert({
        'paper_id': paperId,
        'user_id': userId,
      });
    }
  }

  /// Get research categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await client
        .from('research_categories')
        .select()
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get faculty members
  static Future<List<Map<String, dynamic>>> getFacultyMembers({String? department}) async {
    var query = client
        .from('users')
        .select('id, full_name, email, department')
        .eq('role', 'faculty');

    if (department != null && department.isNotEmpty) {
      query = query.eq('department', department);
    }

    final response = await query.order('full_name');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Search students (for co-author selection)
  static Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    if (query.length < 2) return [];

    final response = await client
        .from('users')
        .select('id, full_name, email, program')
        .eq('role', 'student')
        .or('full_name.ilike.%$query%,email.ilike.%$query%')
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // STAFF/ADMIN FUNCTIONS
  // ==========================================

  /// Get all research papers (staff/admin)
  static Future<List<ResearchModel>> getAllResearch({String? status}) async {
    var query = client
        .from('research_papers')
        .select('*, users!author_id(full_name, email)');

    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => ResearchModel.fromJson(json))
        .toList();
  }

  /// Approve research
  static Future<void> approveResearch(String paperId, {String? comments}) async {
    final userId = await getCurrentUserId();
    final userRole = await getCurrentUserRole();
    
    if (userId == null || userRole == null) throw Exception('Not authenticated');

    // Get current paper status
    final paper = await client
        .from('research_papers')
        .select('status, faculty_id')
        .eq('id', paperId)
        .single();

    String newStatus;
    if (userRole == 'faculty' && paper['status'] == 'pending_faculty') {
      newStatus = 'pending_editor';
    } else if (userRole == 'staff' && paper['status'] == 'pending_editor') {
      newStatus = 'pending_admin';
    } else if (userRole == 'admin') {
      newStatus = 'approved';
    } else {
      throw Exception('Invalid approval workflow');
    }

    await client.from('research_papers').update({
      'status': newStatus,
      'published_date': newStatus == 'approved' ? DateTime.now().toIso8601String() : null,
    }).eq('id', paperId);
  }

  /// Reject research
  static Future<void> rejectResearch(String paperId, String reason) async {
    await client.from('research_papers').update({
      'status': 'rejected',
      'rejection_reason': reason,
    }).eq('id', paperId);
  }

  /// Request revision
  static Future<void> requestRevision(String paperId, String notes) async {
    final userRole = await getCurrentUserRole();
    
    await client.from('research_papers').update({
      'status': 'revision_required',
      'revision_notes': notes,
      'last_reviewer_role': userRole,
    }).eq('id', paperId);
  }

  // ==========================================
  // ADMIN USER MANAGEMENT
  // ==========================================

  /// Get all users (admin only)
  static Future<List<UserModel>> getAllUsers({String? role}) async {
    var query = client.from('users').select();

    if (role != null && role.isNotEmpty) {
      query = query.eq('role', role);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  /// Delete user (admin only)
  static Future<void> deleteUser(String userId) async {
    await client.from('users').delete().eq('id', userId);
  }
}
