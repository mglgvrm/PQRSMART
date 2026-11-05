class AuthResponse {
  final String token;
  final List<String> authorities;

  AuthResponse({required this.token, required this.authorities});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final authorities = json['authorities'];
    if (token is! String || token.isEmpty) {
      throw const FormatException(
        'La respuesta de autenticación no contiene un token válido.',
      );
    }
    if (authorities is! List ||
        authorities.any((authority) => authority is! String)) {
      throw const FormatException(
        'La respuesta de autenticación no contiene roles válidos.',
      );
    }
    return AuthResponse(
      token: token,
      authorities: List<String>.from(authorities),
    );
  }
}
