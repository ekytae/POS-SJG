class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(id: json['id'], name: json['name']);
  }
}

class UserModel {
  final int id;
  final String name;
  final String username;
  final Role? role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  bool get isOwner => role?.name == 'owner';
  bool get isKasir => role?.name == 'kasir';
}