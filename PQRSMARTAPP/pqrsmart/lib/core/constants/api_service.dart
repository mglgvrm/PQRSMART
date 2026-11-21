class ApiConstants {
  static const requestTimeout = Duration(seconds: 10);

  // Override for a physical device or a different backend:
  // flutter run --dart-define=PQRSMART_API_URL=http://192.168.1.10:8080/api
  static const String baseUrl = String.fromEnvironment(
    'PQRSMART_API_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );
}
