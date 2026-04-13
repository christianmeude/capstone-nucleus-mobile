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
    this.authorName,
    this.authorEmail,
  });

  factory ResearchModel.fromJson(Map<String, dynamic> json) {
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
      authorName:
          json['users']?['full_name']?.toString() ??
          json['author']?['full_name']?.toString(),
      authorEmail:
          json['users']?['email']?.toString() ??
          json['author']?['email']?.toString(),
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
    };
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
