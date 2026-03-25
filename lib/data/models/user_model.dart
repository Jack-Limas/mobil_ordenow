import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.allergies,
    required super.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      allergies: List<String>.from(json['allergies'] ?? []),
      preferences: List<String>.from(json['preferences'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "allergies": allergies,
      "preferences": preferences,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      allergies: user.allergies,
      preferences: user.preferences,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      allergies: allergies,
      preferences: preferences,
    );
  }
}