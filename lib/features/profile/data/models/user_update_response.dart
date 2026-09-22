// User model
class User {
  final String phone;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  User({
    required this.phone,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    };
  }
}

// Response model
class UserUpdateResponse {
  final String message;
  final User user;

  UserUpdateResponse({
    required this.message,
    required this.user,
  });

  factory UserUpdateResponse.fromJson(Map<String, dynamic> json) {
    return UserUpdateResponse(
      message: json['message'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
    };
  }
}
