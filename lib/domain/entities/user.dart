class User {
  final String id;
  final String email;
  final String fullName;
  final String password;
  final List<String> allergies;
  final List<String> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.password,
    required this.allergies,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });
}
