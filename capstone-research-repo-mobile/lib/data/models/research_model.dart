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
      id: json['id'] ?? '',
      authorId: json['author_id'] ?? '',
      title: json['title'] ?? '',
      abstract: json['abstract'] ?? '',
      keywords: json['keywords'] != null 
          ? List<String>.from(json['keywords']) 
          : null,
      category: json['category'] ?? '',
      coAuthors: json['co_authors'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      status: json['status'] ?? 'pending',
      facultyId: json['faculty_id'],
      department: json['department'],
      revisionNotes: json['revision_notes'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      publishedDate: json['published_date'] != null 
          ? DateTime.parse(json['published_date']) 
          : null,
      viewCount: json['view_count'] ?? 0,
      downloadCount: json['download_count'] ?? 0,
      authorName: json['users']?['full_name'] ?? json['author']?['full_name'],
      authorEmail: json['users']?['email'] ?? json['author']?['email'],
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
