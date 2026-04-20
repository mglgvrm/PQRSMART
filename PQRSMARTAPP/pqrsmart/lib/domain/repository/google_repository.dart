import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

Future<void> signInWithGoogleSupabase(BuildContext context) async {
  try {
    // Paso 1: Login con Google
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      print('Inicio de sesión cancelado');
      return;
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null || accessToken == null) {
      print('No se pudo obtener tokens de Google');
      return;
    }

    // Paso 2: Login en Supabase
    final AuthResponse response = await Supabase.instance.client.auth
        .signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

    final user = response.user;

    if (user == null) {
      print('No se pudo obtener el usuario');
      return;
    }

    print('Login exitoso: ${user.email}');

    // Paso 3: Verificar si es un nuevo usuario
    final session = response.session;
    final userMetadata = user.userMetadata;

    if (userMetadata == null || userMetadata['name'] == null) {
      // Puedes usar esto para redirigir a una pantalla donde pida nombre, teléfono, etc.
      Navigator.pushNamed(context, '/registerGoogle');
    } else {
      // Usuario ya completo sus datos
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    print('Error en el login con Google: $e');
  }
}
