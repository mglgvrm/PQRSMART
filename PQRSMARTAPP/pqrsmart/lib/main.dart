import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/config/routes.dart';
import 'package:pqrsmart/data/repository/IdentificationTypeRepository.dart';
import 'package:pqrsmart/data/repository/PersonTypeRepository.dart';
import 'package:pqrsmart/data/repository/auth_repositories.dart';
import 'package:pqrsmart/data/services/AuthService.dart';
import 'package:pqrsmart/data/services/IdentificationTypeService.dart';
import 'package:pqrsmart/data/services/PersonTypeService.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 🔥 INYECCIÓN DE DEPENDENCIAS
  final authService = AuthService();
  final personTypeService = PersonTypeService();
  final identificationTypeService = IdentificationTypeService();
  final authRepository = AuthRepository(authService, identificationTypeService, personTypeService );

  runApp(MyApp(authRepository: authRepository, ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository),
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