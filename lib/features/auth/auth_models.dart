class User {
  final int id;
  final String name;
  final String email;
  final List<String> roles;

  final List<String> permissions;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      permissions:
          (json['permissions'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  bool get isAdmin => roles.contains('admin');

  bool get isTrainer => roles.contains('trainer');

  bool get isStudent => roles.contains('student');

  bool can(String permission) {
    return permissions.contains(permission);
  }
}

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),

      token: json['token'],
    );
  }
}
