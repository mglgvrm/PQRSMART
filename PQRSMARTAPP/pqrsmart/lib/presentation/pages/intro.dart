import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage("assets/fondoIntro.jpg"), context);
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/fondoIntro.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Desenfoque
              child: Container(
                color: Colors.black.withOpacity(0.3), // Opacidad del fondo
              ),
            ),
          ),

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
                    width: 250, // Ajusta según necesites
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4DFFFFFF), // Sombra suave
                          blurRadius: 15, // Difuminado de la sombra
                          spreadRadius: 5, // Extensión de la sombra
                          offset: Offset(0, 5), // Posición de la sombra
                        ),
                      ],
                      color: Colors.black.withOpacity(0.2), // Fondo del círculo
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/isotipo2.svg",
                        width: 220,
                        height: 170,
                      ),
                    ),
                  ),
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
                        _launchURL(
                          "https://www.linkedin.com/company/urbanestia/",
                        );
                      },
                      child: Image.asset(
                        "assets/linkedin.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        _launchURL("https://www.instagram.com/dnamyk_1/");
                      },
                      child: Image.asset(
                        "assets/instagram.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
