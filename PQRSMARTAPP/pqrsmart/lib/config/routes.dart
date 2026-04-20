import 'package:flutter/material.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import 'package:pqrsmart/presentation/pages/admin/homeAdmin.dart';
import 'package:pqrsmart/presentation/pages/intro.dart';
import 'package:pqrsmart/presentation/pages/login_page.dart';
import 'package:pqrsmart/presentation/pages/password_recovery_page.dart';
import 'package:pqrsmart/presentation/pages/register_page.dart';
import 'package:pqrsmart/presentation/pages/user/homeUser.dart';

class AppRoutes {

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<String?>(
            future: _getHomeRoute(),           // 👈 Devuelve la ruta según rol
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              switch (snapshot.data) {
                case '/homeAdmin':
                  return const HomeAdmin();
                case '/homeUser':
                  return const HomeUser();
                default:
                  return const Intro();        // No logueado o rol desconocido
              }
            },
          ),
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<String?>(
            future: _getHomeRoute(),           // 👈 Mismo helper reutilizado
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              switch (snapshot.data) {
                case '/homeAdmin':
                  return const HomeAdmin();
                case '/homeUser':
                  return const HomeUser();
                default:
                  return const Login();        // No logueado → mostrar login
              }
            },
          ),
        );

      case '/homeAdmin':
        return MaterialPageRoute(builder: (_) => const HomeAdmin());
      case '/homeUser':
        return MaterialPageRoute(builder: (_) => const HomeUser());
      case '/register':
        return MaterialPageRoute(builder: (_) => const Register());

      case '/passwordRecovered':
        return MaterialPageRoute(builder: (_) => const PasswordRecoveryPage());

      default:
        return MaterialPageRoute(builder: (_) => const Intro());
    }
  }

  // Verifica si hay token guardado
  static Future<bool> _isLoggedIn() async {
    final storage = AuthStorage();
    final token = await storage.getToken();
    return token != null && token.isNotEmpty;
  }
  /// Retorna la ruta destino según token y rol, o null si no está autenticado.
  static Future<String?> _getHomeRoute() async {
    final storage = AuthStorage();
    final token = await storage.getToken();

    if (token == null || token.isEmpty) return null;

    final roles = await storage.getAuthorities();

    if (roles.contains('ROLE_ADMIN')) return '/homeAdmin';
    if (roles.contains('ROLE_SECRE')) return '/homeAdmin'; // 👈 Ajusta según tu lógica
    if (roles.contains('ROLE_USER'))  return '/homeUser';

    return null; // Token válido pero rol desconocido
  }
}
