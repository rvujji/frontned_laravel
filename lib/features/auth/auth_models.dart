class User {
  final int id;

  final String name;

  final String email;

  final String? phone;

  final String status;

  final String? emailVerifiedAt;

  final String? phoneVerifiedAt;

  final bool emailVerified;

  final bool phoneVerified;

  final List<String> roles;

  final List<String> permissions;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.emailVerifiedAt,
    required this.phoneVerifiedAt,
    required this.emailVerified,
    required this.phoneVerified,
    required this.roles,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],

      name: json['name'] ?? '',

      email: json['email'] ?? '',

      phone: json['phone'],

      status: json['status'] ?? '',

      emailVerifiedAt: json['email_verified_at'],

      phoneVerifiedAt: json['phone_verified_at'],

      emailVerified: json['email_verified'] ?? false,

      phoneVerified: json['phone_verified'] ?? false,

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
