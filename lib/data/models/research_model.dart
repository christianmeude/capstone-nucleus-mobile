class ResearchModel {
  final String id;
  final String authorId;
  final String title;
  final String abstract;
  final List<String>? keywords;
  final String category;
  final String? coAuthors;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String status;
  final String? facultyId;
  final String? department;
  final String? revisionNotes;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? publishedDate;
  final int viewCount;
  final int downloadCount;
  final bool allowDownload;
  final bool allowHighlight;
  final String? authorName;
  final String? authorEmail;

  ResearchModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.abstract,
    this.keywords,
    required this.category,
    this.coAuthors,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.status,
    this.facultyId,
    this.department,
    this.revisionNotes,
    this.rejectionReason,
    this.createdAt,
    this.publishedDate,
    this.viewCount = 0,
    this.downloadCount = 0,
    this.allowDownload = true,
    this.allowHighlight = true,
    this.authorName,
    this.authorEmail,
  });

  factory ResearchModel.fromJson(Map<String, dynamic> json) {
    final users = json['users'] is Map<String, dynamic>
        ? json['users'] as Map<String, dynamic>
        : (json['users'] is Map
              ? Map<String, dynamic>.from(json['users'] as Map)
              : null);

    final author = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : (json['author'] is Map
              ? Map<String, dynamic>.from(json['author'] as Map)
              : null);

    final authorEmail =
        users?['email']?.toString() ?? author?['email']?.toString();

    final usersFirst = users?['first_name']?.toString().trim() ?? '';
    final usersLast = users?['last_name']?.toString().trim() ?? '';
    final usersFull = users?['full_name']?.toString().trim() ?? '';
    final authorFull = author?['full_name']?.toString().trim() ?? '';

    final composedName = [
      usersFirst,
      usersLast,
    ].where((part) => part.isNotEmpty).join(' ').trim();

    String? resolvedAuthorName;
    if (usersFull.isNotEmpty) {
      resolvedAuthorName = usersFull;
    } else if (authorFull.isNotEmpty) {
      resolvedAuthorName = authorFull;
    } else if (composedName.isNotEmpty) {
      resolvedAuthorName = composedName;
    } else if (authorEmail != null && authorEmail.contains('@')) {
      resolvedAuthorName = authorEmail.split('@').first;
    }

    return ResearchModel(
      id: json['id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      abstract: json['abstract']?.toString() ?? '',
      keywords: json['keywords'] != null
          ? (json['keywords'] is List
                ? List<String>.from(
                    json['keywords'].map((e) => e?.toString() ?? ''),
                  )
                : <String>[])
          : null,
      category: json['category']?.toString() ?? '',
      coAuthors: json['co_authors']?.toString(),
      fileUrl: json['file_url']?.toString(),
      fileName: json['file_name']?.toString(),
      fileSize: json['file_size'] is int ? json['file_size'] : null,
      status: json['status']?.toString() ?? 'pending',
      facultyId: json['faculty_id']?.toString(),
      department: json['department']?.toString(),
      revisionNotes: json['revision_notes']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at'] != null
          ? (json['created_at'] is DateTime
                ? json['created_at']
                : DateTime.tryParse(json['created_at'].toString()))
          : null,
      publishedDate: json['published_date'] != null
          ? (json['published_date'] is DateTime
                ? json['published_date']
                : DateTime.tryParse(json['published_date'].toString()))
          : null,
      viewCount: json['view_count'] is int ? json['view_count'] : 0,
      downloadCount: json['download_count'] is int ? json['download_count'] : 0,
      allowDownload: _parseBool(json['allow_download'], true),
      allowHighlight: _parseBool(json['allow_highlight'], true),
      authorName: resolvedAuthorName,
      authorEmail: authorEmail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'title': title,
      'abstract': abstract,
      'keywords': keywords,
      'category': category,
      'co_authors': coAuthors,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'status': status,
      'faculty_id': facultyId,
      'department': department,
      'revision_notes': revisionNotes,
      'rejection_reason': rejectionReason,
      'created_at': createdAt?.toIso8601String(),
      'published_date': publishedDate?.toIso8601String(),
      'view_count': viewCount,
      'download_count': downloadCount,
      'allow_download': allowDownload,
      'allow_highlight': allowHighlight,
    };
  }

  static bool _parseBool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return fallback;
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'pending_faculty':
        return 'Awaiting Faculty Review';
      case 'pending_editor':
        return 'Awaiting Editor Review';
      case 'pending_admin':
        return 'Awaiting Admin Approval';
      case 'approved':
        return 'Published';
      case 'rejected':
        return 'Rejected';
      case 'revision_required':
        return 'Revision Required';
      default:
        return status;
    }
  }
}
