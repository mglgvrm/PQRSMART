class AuthResponse {
  final String token;
  final List<String> authorities;

  AuthResponse({
    required this.token,
    required this.authorities,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      authorities: List<String>.from(json['authorities']),
    );
  }
}