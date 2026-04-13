// user.dart
// This represents a registered user in our app.
// We store email and a hashed password locally.

class AppUser {
  String email;
  String password; // We will store a simple hashed version

  AppUser({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      password: json['password'],
    );
  }
}