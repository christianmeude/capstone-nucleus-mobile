/// Model representing a department for submission filtering
class DepartmentModel {
  final String id;
  final String name;
  final String? code;
  final String? description;

  DepartmentModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'description': description};
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
      other is DepartmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
