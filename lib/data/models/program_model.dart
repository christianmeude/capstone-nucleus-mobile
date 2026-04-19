/// Model representing a program nested under a department
class ProgramModel {
  final String id;
  final String name;
  final String? code;
  final String? departmentId;
  final bool isActive;
  final DateTime? createdAt;

  ProgramModel({
    required this.id,
    required this.name,
    this.code,
    this.departmentId,
    this.isActive = true,
    this.createdAt,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      departmentId: json['department_id']?.toString() ?? json['departmentId']?.toString(),
      isActive: json['is_active'] == null
          ? true
          : json['is_active'] == true || json['is_active'].toString().toLowerCase() == 'true',
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
      'name': name,
      'code': code,
      'department_id': departmentId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get displayName {
    if (code != null && code!.isNotEmpty) {
      return '$code - $name';
    }
    return name;
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
