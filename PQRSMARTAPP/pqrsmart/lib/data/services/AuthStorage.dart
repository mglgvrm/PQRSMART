import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final _storage = const FlutterSecureStorage();

  // Guardar token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Guardar authorities (roles)
  Future<void> saveAuthorities(List<String> roles) async {
    await _storage.write(key: 'roles', value: roles.join(','));
  }

  // Obtener token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Obtener roles
  Future<List<String>> getAuthorities() async {
    final roles = await _storage.read(key: 'roles');
    return roles != null ? roles.split(',') : [];
  }

  // Logout
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}