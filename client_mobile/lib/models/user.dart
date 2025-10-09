class User {
  final String id;
  final String name;
  final String role; // 'farmer' or 'vet'
  final String? token; // Optional token for API authorization

  User({required this.id, required this.name, required this.role, this.token});

  // Factory constructor required by AuthService to parse JSON response from the API.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      token: json['token'] as String?, // Assuming the API returns a token
    );
  }
}
