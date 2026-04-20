import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> with TickerProviderStateMixin {
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

  // Función para abrir enlaces
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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


      child: Stack(
        children: [


          // Contenedor semi-transparente para evitar que el fondo opaque el contenido
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:
                  MainAxisAlignment
                      .center, // Centra los elementos horizontalmente
              children: [
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    child: Image.asset("assets/logo.png"
                    ),
                  )
                ),
                const SizedBox(height: 60),
                Center(
                  child: Text(
                    "Seguro y confiable",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Dejanos ser parte de tu viaje hacia un nuevo comienzo",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // Botón de inicio de sesión
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.9, // 90% del ancho del dispositivo
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF3F5A4C,
                      ), // Color del botón
                      elevation: 5, // Elevación del botón
                      foregroundColor: Colors.white, // Color del texto
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },

                    child: Stack(
                      alignment: Alignment.center, // Centra el contenido
                      children: [
                        const Text(
                          "Ingresa gratis",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFFDDE9E4,
                                ), // Color del fondo del círculo
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(8), // Tamaño del círculo
                              child: Icon(
                                Icons.arrow_forward, // Ícono de flecha
                                color: Color(0xFF3F5A4C), // Color del ícono
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 120),
                Center(
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/Imagotipo2Dark.svg",
                      width: 40,
                      height: 40,

                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    GestureDetector(
                      onTap: () {
                        _launchURL("https://www.instagram.com//");
                      },
                      child: Image.asset(
                        "assets/instagram.png",
                        width: 25,
                        height: 25,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
