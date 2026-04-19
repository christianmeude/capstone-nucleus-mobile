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
    this.allowDownload = false,
    this.allowHighlight = false,
    this.authorName,
    this.authorEmail,
  });

  factory ResearchModel.fromJson(Map<String, dynamic> json) {
    final users = _asMap(json['users']);
    final author = _asMap(json['author']);

    final authorEmail = _stringFrom(users, 'email') ?? _stringFrom(author, 'email');

    final usersFirst = _stringFrom(users, 'first_name') ?? _stringFrom(users, 'firstName') ?? '';
    final usersLast = _stringFrom(users, 'last_name') ?? _stringFrom(users, 'lastName') ?? '';
    final usersFull = _stringFrom(users, 'full_name') ?? _stringFrom(users, 'fullName') ?? '';
    final authorFull = _stringFrom(author, 'full_name') ?? _stringFrom(author, 'fullName') ?? '';

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
      id: json['id']?.toString() ?? json['researchId']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? json['authorId']?.toString() ?? '',
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
      coAuthors: json['co_authors']?.toString() ?? json['coAuthors']?.toString(),
      fileUrl: json['file_url']?.toString() ?? json['fileUrl']?.toString(),
      fileName: json['file_name']?.toString() ?? json['fileName']?.toString(),
      fileSize: _parseInt(json['file_size']) ?? _parseInt(json['fileSize']),
      status: json['status']?.toString() ?? 'pending',
      facultyId: json['faculty_id']?.toString() ?? json['facultyId']?.toString(),
      department: json['department']?.toString(),
      revisionNotes: json['revision_notes']?.toString() ?? json['revisionNotes']?.toString(),
      rejectionReason: json['rejection_reason']?.toString() ?? json['rejectionReason']?.toString(),
      createdAt: json['created_at'] != null
          ? (json['created_at'] is DateTime
                ? json['created_at']
                : DateTime.tryParse(json['created_at'].toString()))
          : json['createdAt'] != null
              ? (json['createdAt'] is DateTime
                    ? json['createdAt']
                    : DateTime.tryParse(json['createdAt'].toString()))
          : null,
      publishedDate: json['published_date'] != null
          ? (json['published_date'] is DateTime
                ? json['published_date']
                : DateTime.tryParse(json['published_date'].toString()))
          : json['publishedAt'] != null
              ? (json['publishedAt'] is DateTime
                    ? json['publishedAt']
                    : DateTime.tryParse(json['publishedAt'].toString()))
          : null,
      viewCount: _parseInt(json['view_count']) ?? _parseInt(json['viewCount']) ?? 0,
      downloadCount: _parseInt(json['download_count']) ?? _parseInt(json['downloadCount']) ?? 0,
      allowDownload: _parseBool(json['allow_download'], false),
      allowHighlight: _parseBool(json['allow_highlight'] ?? json['allowHighlight'], false),
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

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String? _stringFrom(Map<String, dynamic>? source, String key) {
    return source?[key]?.toString().trim();
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
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
