import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/config/routes.dart';
import 'package:pqrsmart/data/repository/auth_repositories.dart';
import 'package:pqrsmart/data/services/AuthService.dart';
import 'package:pqrsmart/data/services/IdentificationTypeService.dart';
import 'package:pqrsmart/data/services/PersonTypeService.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService                = AuthService();
  final personTypeService          = PersonTypeService();
  final identificationTypeService  = IdentificationTypeService();
  final authRepository             = AuthRepository(
    authService,
    identificationTypeService,
    personTypeService,
  );

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatefulWidget {
  final AuthRepository authRepository;
  const MyApp({super.key, required this.authRepository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    // App estaba cerrada y se abrió por el link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
      }
    } catch (_) {}

    // App estaba abierta en segundo plano
    _appLinks.uriLinkStream.listen(
          (uri) => _handleLink(uri),
      onError: (_) {},
    );
  }

  void _handleLink(Uri uri) {
    // pqrsmart://auth/verified?success=true
    if (uri.scheme == 'pqrsmart' && uri.host == 'auth') {
      if (uri.path.contains('verified')) {
        final success = uri.queryParameters['success'] == 'true';
        navigatorKey.currentState?.pushReplacementNamed(
          '/activation-result',
          arguments: success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(widget.authRepository),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'PQRSmart',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFECF4FD),
        ),
        initialRoute: '/',
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}