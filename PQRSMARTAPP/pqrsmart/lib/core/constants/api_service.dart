import 'package:flutter/foundation.dart';

class ApiConstants {
  static const requestTimeout = Duration(seconds: 10);

  // Override for a physical device or a different backend:
  // flutter run --dart-define=PQRSMART_API_URL=http://192.168.1.10:8080/api
  static const String _configuredBaseUrl = String.fromEnvironment(
    'PQRSMART_API_URL',
  );
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }
}
