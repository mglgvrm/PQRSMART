import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/core/utils/role_navigation.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/states/auth_state.dart';
import 'package:pqrsmart/presentation/widgets/auth_widgets.dart';
import 'package:pqrsmart/presentation/widgets/pqr_widgets.dart';

class PqrLoginScreen extends StatefulWidget {
  const PqrLoginScreen({super.key});

  @override
  State<PqrLoginScreen> createState() => _PqrLoginScreenState();
}

class _PqrLoginScreenState extends State<PqrLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = AuthStorage();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa tu usuario y contraseña.')),
      );
      return;
    }
    context.read<AuthBloc>().add(LoginEvent(username, password));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthStates>(
    listener: (context, state) async {
      if (state is AuthSuccess) {
        final route = homeRouteForAuthorities(state.data.authorities);
        if (!context.mounted) return;
        if (route == null) {
          await _storage.clear();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'El servidor no devolvió un rol válido para esta cuenta. No es posible iniciar sesión.',
              ),
              backgroundColor: AppColors.cancelled,
            ),
          );
          return;
        }
        Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
      } else if (state is AuthError || state is AuthFailure) {
        final message = state is AuthError
            ? state.message
            : (state as AuthFailure).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.cancelled,
          ),
        );
      }
    },
    builder: (context, state) => Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              bottom: -98,
              left: -80,
              right: -60,
              child: _LoginDecoration(),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 44,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: PqrAuthBrandHeader()),
                    const SizedBox(height: 35),
                    const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Ingresa tus datos para continuar',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 22),
                    PqrAuthField(
                      controller: _usernameController,
                      hintText: 'Usuario',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 13),
                    PqrAuthField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      hintText: 'Contraseña',
                      prefixIcon: Icons.lock_outline,
                      onSubmitted: (_) => _login(),
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/passwordRecovered'),
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: AppColors.action,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    PqrPrimaryButton(
                      label: 'Ingresar',
                      onPressed: _login,
                      loading: state is AuthLoading,
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes una cuenta?',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.action,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LoginDecoration extends StatelessWidget {
  const _LoginDecoration();

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 190, child: CustomPaint(painter: _LoginWavePainter()));
}

class _LoginWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 65)
      ..quadraticBezierTo(size.width * .45, 0, size.width, 55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.backgroundBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
