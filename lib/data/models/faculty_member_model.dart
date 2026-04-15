/// Model representing a faculty member for advisor selection
class FacultyMemberModel {
  final String id;
  final String fullName;
  final String email;
  final String? department;

  FacultyMemberModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.department,
  });

  factory FacultyMemberModel.fromJson(Map<String, dynamic> json) {
    final fullName = json['full_name']?.toString().trim() ?? '';
    final firstName = json['first_name']?.toString().trim() ?? '';
    final middleName = json['middle_name']?.toString().trim() ?? '';
    final lastName = json['last_name']?.toString().trim() ?? '';
    final resolvedName = fullName.isNotEmpty
        ? fullName
        : [
            firstName,
            middleName,
            lastName,
          ].where((part) => part.isNotEmpty).join(' ').trim();

    return FacultyMemberModel(
      id: json['id']?.toString() ?? '',
      fullName: resolvedName,
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'department': department,
    };
  }

  /// Display name for dropdown (Name - Department)
  String get displayName {
    if (department != null && department!.isNotEmpty) {
      return '$fullName - $department';
    }
    return fullName;
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacultyMemberModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
