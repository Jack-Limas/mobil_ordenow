import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.password,
    required super.allergies,
    required super.preferences,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      password: json['password'] as String? ?? '',
      allergies: List<String>.from(json['allergies'] ?? []),
      preferences: List<String>.from(json['preferences'] ?? []),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "full_name": fullName,
      "password": password,
      "allergies": allergies,
      "preferences": preferences,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      password: user.password,
      allergies: user.allergies,
      preferences: user.preferences,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      password: password,
      allergies: allergies,
      preferences: preferences,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
