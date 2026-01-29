import 'dart:typed_data';
import '../services/supabase_service.dart';
import '../models/research_model.dart';

/// Repository for research paper operations
class ResearchRepository {
  /// Get current user's research papers
  static Future<List<ResearchModel>> getMyResearch() async {
    return await SupabaseService.getMyResearch();
  }

  /// Get all published/approved papers
  static Future<List<ResearchModel>> getPublishedPapers({
    String? category,
    String? search,
    String? year,
  }) async {
    return await SupabaseService.getPublishedPapers(
      category: category,
      search: search,
      year: year,
    );
  }

  /// Get a single research paper by ID
  static Future<ResearchModel> getResearchById(String id) async {
    return await SupabaseService.getResearchById(id);
  }

  /// Submit a new research paper
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
    await SupabaseService.submitResearch(
      title: title,
      abstract: abstract,
      keywords: keywords,
      category: category,
      coAuthors: coAuthors,
      fileBytes: fileBytes,
      filename: filename,
      facultyId: facultyId,
      department: department,
    );
  }

  /// Track a paper download
  static Future<void> trackDownload(String paperId) async {
    await SupabaseService.trackDownload(paperId);
  }

  /// Get research categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    return await SupabaseService.getCategories();
  }

  /// Get faculty members
  static Future<List<Map<String, dynamic>>> getFacultyMembers({
    String? department,
  }) async {
    return await SupabaseService.getFacultyMembers(department: department);
  }

  /// Search for students (co-author selection)
  static Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    return await SupabaseService.searchStudents(query);
  }

  /// Approve a research paper (staff/admin)
  static Future<void> approveResearch(String paperId, {String? comments}) async {
    await SupabaseService.approveResearch(paperId, comments: comments);
  }

  /// Reject a research paper (staff/admin)
  static Future<void> rejectResearch(String paperId, String reason) async {
    await SupabaseService.rejectResearch(paperId, reason);
  }

  /// Request revision for a research paper (staff/admin)
  static Future<void> requestRevision(String paperId, String notes) async {
    await SupabaseService.requestRevision(paperId, notes);
  }
}
