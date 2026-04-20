import 'package:flutter/material.dart';
import 'package:urbanestia/presentation/pages/dashboard/property/new_properties_page.dart';
import 'package:urbanestia/presentation/pages/drawer_user.dart';
import 'package:urbanestia/presentation/pages/home_page.dart';
import 'package:urbanestia/presentation/pages/intro.dart';
import 'package:urbanestia/presentation/pages/login_page.dart';
import 'package:urbanestia/presentation/pages/password_changed_page.dart';
import 'package:urbanestia/presentation/pages/password_recovery_page.dart';
import 'package:urbanestia/presentation/pages/register_google_page.dart';
import 'package:urbanestia/presentation/pages/register_meta_page.dart';
import 'package:urbanestia/presentation/pages/register_page.dart';
import 'package:urbanestia/presentation/pages/validation_document_page_1.dart';
import 'package:urbanestia/presentation/pages/validation_document_page_2.dart';
import 'package:urbanestia/presentation/pages/validation_document_page_3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        if (Supabase.instance.client.auth.currentUser != null) {
          // Usuario ya logueado: redirige directamente a home
          return MaterialPageRoute(builder: (_) => HomePage());
        } else {
          return MaterialPageRoute(builder: (_) => Intro());
        }
      case '/login':
        return MaterialPageRoute(builder: (_) => const Login());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const Register());
      case '/registerGoogle':
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => RegisterGooglePage(userId: userId),
        );
      case '/registerMeta':
        return MaterialPageRoute(builder: (_) => const RegisterMetaPage());
      case '/passwordChanged':
        return MaterialPageRoute(builder: (_) => const PasswordChangedPage());
      case '/newPassword':
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => RegisterGooglePage(userId: userId),
        );
      case '/passwordRecovered':
        return MaterialPageRoute(builder: (_) => const PasswordRecoveryPage());
      case '/validateDocument1':
        return MaterialPageRoute(
          builder: (_) => const ValidationDocumentPage1(),
        );
      case '/validateDocument2':
        return MaterialPageRoute(
          builder: (_) => const ValidationDocumentPage2(),
        );
      case '/validateDocument3':
        return MaterialPageRoute(
          builder: (_) => const ValidationDocumentPage3(),
        );
      case '/drawer':
        return MaterialPageRoute(builder: (_) => const DrawerUser());
      case '/newProperties':
        return MaterialPageRoute(builder: (_) => const NewPropertiesPage());
      default:
        return MaterialPageRoute(builder: (_) => const Intro());
    }
  }
}
