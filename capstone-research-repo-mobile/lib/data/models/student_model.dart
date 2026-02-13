/// Model representing a student for co-author selection
class StudentModel {
  final String id;
  final String fullName;
  final String email;
  final String? program;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.program,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      program: json['program']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'program': program,
    };
  }

  /// Display name for chips/selection (Name - Program)
  String get displayName {
    if (program != null && program!.isNotEmpty) {
      return '$fullName ($program)';
    }
    return fullName;
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
