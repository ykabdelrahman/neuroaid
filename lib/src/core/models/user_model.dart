class UserModel {
  final int id;
  final String email;
  final String name;
  final String role;
  final String phone;
  final bool isActive;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      phone: json['phone'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    bool? isActive,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
