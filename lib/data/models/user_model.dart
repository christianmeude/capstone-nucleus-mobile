class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? department;
  final String? departmentId;
  final String? program;
  final String? programId;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.department,
    this.departmentId,
    this.program,
    this.programId,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name']?.toString().trim() ?? json['firstName']?.toString().trim() ?? '';
    final middleName = json['middle_name']?.toString().trim() ?? json['middleName']?.toString().trim() ?? '';
    final lastName = json['last_name']?.toString().trim() ?? json['lastName']?.toString().trim() ?? '';
    final fullName = json['full_name']?.toString().trim() ??
        json['fullName']?.toString().trim() ??
        [firstName, middleName, lastName].where((part) => part.isNotEmpty).join(' ').trim();

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: fullName.isNotEmpty ? fullName : '',
      role: json['role']?.toString() ?? 'student',
      department: json['department']?.toString(),
      departmentId: json['department_id']?.toString() ?? json['departmentId']?.toString(),
      program: json['program']?.toString(),
      programId: json['program_id']?.toString() ?? json['programId']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'fullName': fullName,
      'role': role,
      'department': department,
      'department_id': departmentId,
      'departmentId': departmentId,
      'program': program,
      'program_id': programId,
      'programId': programId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
