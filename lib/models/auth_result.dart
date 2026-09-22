class AuthResult {
  final String token;
  final int userId;
  final String fullName;
  final String email;

  AuthResult({
    required this.token,
    required this.userId,
    required this.fullName,
    required this.email,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    token: json['token'] as String,
    userId: json['userId'] as int,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
  );
}