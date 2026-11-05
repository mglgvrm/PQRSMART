// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/core/utils/role_navigation.dart';
import 'package:pqrsmart/data/model/AuthResponse.dart';
import 'package:pqrsmart/data/repository/auth_repositories.dart';
import 'package:pqrsmart/data/services/AuthService.dart';
import 'package:pqrsmart/data/services/IdentificationTypeService.dart';
import 'package:pqrsmart/data/services/PersonTypeService.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/pages/register_page.dart';
import 'package:pqrsmart/presentation/pages/password_recovery_page.dart';
import 'package:pqrsmart/presentation/pages/user/pqr_login_screen.dart';
import 'package:pqrsmart/presentation/widgets/pqr_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  test('authentication roles resolve to their own home routes', () {
    expect(homeRouteForAuthorities(['ROLE_USER']), '/homeUser');
    expect(homeRouteForAuthorities(['ROLE_ADMIN']), '/homeAdmin');
    expect(homeRouteForAuthorities(['ROLE_SECRE']), '/homeSecre');
    expect(homeRouteForAuthorities(['ROLE_UNKNOWN']), isNull);
  });

  testWidgets('PQRSMART primary action uses the institutional label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PqrPrimaryButton(label: 'Enviar solicitud', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Enviar solicitud'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Enviar solicitud'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(button.style?.backgroundColor?.resolve({}), AppColors.action);
  });

  testWidgets('registration remains usable and can retry when API times out', (
    WidgetTester tester,
  ) async {
    final repository = _OfflineAuthRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(repository),
          child: const Register(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Crear cuenta'), findsNWidgets(2));
    expect(find.text('Volver a intentar'), findsOneWidget);
    expect(find.text('PQRSMART'), findsOneWidget);
    expect(find.text('Administrador'), findsNothing);
    expect(find.text('Secretario'), findsNothing);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      AppColors.white,
    );

    final firstField = find.byType(TextFormField).first;
    await tester.enterText(firstField, 'usuario_prueba');
    await tester.tap(find.text('Volver a intentar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.loadAttempts, 2);
    expect(find.text('Crear cuenta'), findsNWidgets(2));
    expect(find.text('Volver a intentar'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(firstField).controller?.text,
      'usuario_prueba',
    );
  });

  testWidgets('login has no manual role selector', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(_OfflineAuthRepository()),
          child: const PqrLoginScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Ingresa como'), findsNothing);
    expect(find.text('Administrador'), findsNothing);
    expect(find.text('Secretario'), findsNothing);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });

  testWidgets('login link opens the citizen registration screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(_OfflineAuthRepository()),
          child: const PqrLoginScreen(),
        ),
        routes: {'/register': (_) => const Text('Registration destination')},
      ),
    );

    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();
    expect(find.text('Registration destination'), findsOneWidget);
  });

  testWidgets('registration link returns to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(_OfflineAuthRepository()),
          child: const Register(),
        ),
        routes: {'/login': (_) => const Text('Login destination')},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    const registrationLink = '¿Ya tienes una cuenta? Inicia sesión';
    await tester.ensureVisible(find.text(registrationLink));
    await tester.tap(find.text(registrationLink));
    await tester.pumpAndSettle();

    expect(find.text('Login destination'), findsOneWidget);
  });

  testWidgets('password recovery submits the email and confirms instructions', (
    WidgetTester tester,
  ) async {
    final repository = _OfflineAuthRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(repository),
          child: const PasswordRecoveryPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'citizen@example.com');
    await tester.tap(find.text('Enviar instrucciones'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repository.passwordResetEmail, 'citizen@example.com');
    expect(
      find.text(
        'Revisa tu bandeja de entrada y la carpeta de correo no deseado.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('invalid login credentials do not navigate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(_OfflineAuthRepository()),
          child: const PqrLoginScreen(),
        ),
        routes: {'/homeUser': (_) => const Text('Citizen home')},
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'citizen');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Credenciales incorrectas'), findsOneWidget);
    expect(find.text('Citizen home'), findsNothing);
  });
}

class _OfflineAuthRepository extends AuthRepository {
  _OfflineAuthRepository()
    : super(AuthService(), IdentificationTypeService(), PersonTypeService());

  int loadAttempts = 0;
  String? passwordResetEmail;

  @override
  Future<AuthResponse> login(String user, String password) {
    throw Exception('invalid credentials');
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    passwordResetEmail = email;
  }

  @override
  Future<Map<String, dynamic>> getRegisterFormData() async {
    loadAttempts++;
    throw TimeoutException('Test timeout');
  }
}
