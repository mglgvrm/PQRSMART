import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/utils/custom_textFormFiel_utils.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/pages/password_recovery_page.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/states/auth_state.dart';
import 'dart:math' as math;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{
  bool _obscureText = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AnimationController? _controller;
  Animation<double>? _animation;

  // Colores del gradiente (equivalente a --gradient-color-1..4)
  final List<Color> _gradientColors = [
    const Color(0xFF3F5A4C), // verde oscuro (base de tu app)
    const Color(0xFF2D4A5A), // azul verdoso
    const Color(0xFF1A3A4A), // azul marino
    const Color(0xFF4A6B5A), // verde medio
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  final storage = AuthStorage();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthStates>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inicio de sesion exitoso'),
              backgroundColor: Colors.green,
            ),
          );
          final roles = await storage.getAuthorities();
          print("ROLES: $roles");

          if (roles.contains("ROLE_ADMIN")){
            print("Redirigiendo a /home...");
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/homeAdmin',
                  (route) => false,
            );
          }
          else if(roles.contains("ROLE_SECRE")){

          }
          else if(roles.contains("ROLE_USER")){

            print("Redirigiendo a /home...");
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/homeUser',
                  (route) => false,
            );
          }

        }

        else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          print(state.message);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimatedBuilder(

          animation: _animation ?? const AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            final anim = _animation?.value ?? 0.0;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    math.cos(anim * math.pi),
                    math.sin(anim * math.pi),
                  ),
                  end: Alignment(
                    -math.cos(anim * math.pi),
                    -math.sin(anim * math.pi),
                  ),
                  colors: [
                    Color.lerp(
                      _gradientColors[0],
                      _gradientColors[2],
                      anim,
                    )!,
                    Color.lerp(
                      _gradientColors[1],
                      _gradientColors[3],
                      anim,
                    )!,
                    Color.lerp(
                      _gradientColors[3],
                      _gradientColors[0],
                      anim,
                    )!,
                  ],
                ),
              ),
              child: child,
            );
          },
    child: SizedBox(
    height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),

              child: Column(
                children: [
                  Center(
                    child: Center(
                        child: Image.asset("assets/logo.png"
                        )
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Bienvenido nuevamente",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  CustomTextField(
                    label: "Usuario",
                    hintText: "user123",
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
                        "Usuario con que te has registrado",
                        style: TextStyle(color: Colors.white, fontSize: 14),
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
                          color: Colors.white,
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
                        ).add(LoginEvent(email, password));

                      },
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        const TextSpan(
                          text: "¿No tienes una cuenta? ",
                          style: TextStyle(color: Colors.white),
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
      ),
      ),
    );
  }
}

