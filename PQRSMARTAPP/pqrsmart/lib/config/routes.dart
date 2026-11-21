import 'package:flutter/material.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import 'package:pqrsmart/core/utils/role_navigation.dart';
import 'package:pqrsmart/presentation/pages/ActivationPage.dart';
import 'package:pqrsmart/presentation/pages/ProfilePage.dart';
import 'package:pqrsmart/presentation/pages/admin/homeAdmin.dart';
import 'package:pqrsmart/presentation/pages/intro.dart';
import 'package:pqrsmart/presentation/pages/password_recovery_page.dart';
import 'package:pqrsmart/presentation/pages/register_page.dart';
import 'package:pqrsmart/presentation/pages/secretary/secretary_home_screen.dart';
import 'package:pqrsmart/presentation/pages/user/homeUser.dart';
import 'package:pqrsmart/presentation/pages/user/pqr_login_screen.dart';
import 'package:pqrsmart/presentation/pages/user/pqr_splash_screen.dart';
import 'package:pqrsmart/presentation/pages/user/request/create_request_screen.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<String?>(
            future: _getHomeRoute(), // 👈 Devuelve la ruta según rol
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
                case '/homeSecre':
                  return const SecretaryHomeScreen();
                default:
                  return const PqrSplashScreen();
              }
            },
          ),
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<String?>(
            future: _getHomeRoute(), // 👈 Mismo helper reutilizado
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
                case '/homeSecre':
                  return const SecretaryHomeScreen();
                default:
                  return const PqrLoginScreen();
              }
            },
          ),
        );

      case '/homeAdmin':
        return _protectedHome(settings, '/homeAdmin', const HomeAdmin());
      case '/homeUser':
        return _protectedHome(settings, '/homeUser', const HomeUser());
      case '/homeSecre':
        return _protectedHome(
          settings,
          '/homeSecre',
          const SecretaryHomeScreen(),
        );
      case '/newRequest':
        return _protectedHome(
          settings,
          '/homeUser',
          const CreateRequestScreen(),
        );
      case '/register':
        return MaterialPageRoute(builder: (_) => const Register());

      case '/profile':
        return _authenticatedRoute(settings, const ProfilePage());

      case '/passwordRecovered':
        return MaterialPageRoute(builder: (_) => const PasswordRecoveryPage());

      case '/activation-result':
        // Recibe el bool que mandas desde _handleLink
        final success = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => ActivationResultPage(success: success),
        );
      default:
        return MaterialPageRoute(builder: (_) => const Intro());
    }
  }

  static Route<dynamic> _authenticatedRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => FutureBuilder<String?>(
        future: _getHomeRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data == null ? const PqrLoginScreen() : page;
        },
      ),
    );
  }

  static Route<dynamic> _protectedHome(
    RouteSettings settings,
    String requiredRoute,
    Widget page,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => FutureBuilder<String?>(
        future: _getHomeRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == requiredRoute) return page;
          if (snapshot.data == '/homeAdmin') return const HomeAdmin();
          if (snapshot.data == '/homeSecre') {
            return const SecretaryHomeScreen();
          }
          if (snapshot.data == '/homeUser') return const HomeUser();
          return const PqrLoginScreen();
        },
      ),
    );
  }

  /// Retorna la ruta destino según token y rol, o null si no está autenticado.
  static Future<String?> _getHomeRoute() async {
    final storage = AuthStorage();
    final token = await storage.getToken();

    if (token == null || token.isEmpty) return null;

    final roles = await storage.getAuthorities();
    return homeRouteForAuthorities(roles);
  }
}
