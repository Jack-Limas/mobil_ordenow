class User {
  final String id;
  final String email;
  final String name;
  final List<String> allergies;
  final List<String> preferences;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.allergies,
    required this.preferences,
  });
}