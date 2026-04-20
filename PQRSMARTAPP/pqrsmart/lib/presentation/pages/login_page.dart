import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urbanestia/core/utils/custom_textFormFiel_utils.dart';
import 'package:urbanestia/presentation/blocs/auth_bloc.dart';
import 'package:urbanestia/presentation/pages/password_recovery_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:urbanestia/presentation/states/auth_event.dart';
import 'package:urbanestia/presentation/states/auth_state.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthStates>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inicio de sesion exitoso'),
              backgroundColor: Colors.green,
            ),
          );
          print("Redirigiendo a /home...");
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (state is AuthNeedsProfileCompletion) {
          Navigator.pushReplacementNamed(
            context,
            '/registerGoogle',
            arguments: state.userId,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          print(state.message);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),

              child: Column(
                children: [
                  Center(
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/vectors/Imagotipo.svg",
                        width: 150,
                        height: 130,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Bienvenido nuevamente",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  CustomTextField(
                    label: "Correo electrónico",
                    hintText: "m@ejemplo.com",
                    controller: emailController,
                    icon: (Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 4),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Text(
                        "Correo electrónico con que te has registrado",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    label: "Contraseña",
                    hintText: "************",
                    controller: passwordController,
                    icon: (Icons.lock_outline),
                    obscureText: _obscureText,
                    suffixIcon:
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscureText = !_obscureText; // Alternar visibilidad
                      });
                    },
                  ),

                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return PasswordRecoveryPage();
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Olvidaste tu contraseña?",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width *
                        0.9, // Usa el 90% del ancho del dispositivo
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF3F5A4C,
                        ), // Color del botón
                        foregroundColor: Colors.white, // Color del texto
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Por favor completa todos los campos",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        BlocProvider.of<AuthBloc>(
                          context,
                        ).add(LoginRequested(email: email, password: password));
                      },
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        context,
                        "assets/google.png",
                        'google',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        const TextSpan(
                          text: "¿No tienes una cuenta? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextSpan(
                          text: "Crear Cuenta",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/register',
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildSocialButton(
  BuildContext context,
  String assetPath,
  String? provider,
) {
  return GestureDetector(
    onTap: () {
      if (provider == 'google') {
        context.read<AuthBloc>().add(GoogleSignInRequested());
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(assetPath, width: 24, height: 24, color: Colors.grey),
    ),
  );
}
