// lib/data/auth/auth_repository.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:urbanestia/domain/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final GoogleSignIn _googleSignInOut = GoogleSignIn();
  Future<AuthResponse> signInWithGoogle() async {
    try {
      await _googleSignInOut.signOut();
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '192483495926-bg3ks7ndt7m3pjkskide8r58lddcmtp6.apps.googleusercontent.com',
      );

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Inicio de sesión cancelado');

      final emailGoogle = await googleUser.email;
      print("###################### $emailGoogle ######################");
      final supabase = Supabase.instance.client;

      final profile =
          await supabase
              .from('user_profile')
              .select()
              .eq('email', emailGoogle)
              .maybeSingle();
      ;
      print("###################### $profile ######################");
      if (profile != null && profile['auth_provider'] != 'google') {
        await Supabase.instance.client.auth
            .signOut(); // 🔒 Cerrar la sesión de Google
        return Future.error(
          'El correo electrónico ya está en uso por otro proveedor.',
        );
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) throw Exception('No se pudo obtener ID token');

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        // ✅ Verificación correcta ahora
        throw Exception('Error: No se creó el usuario en Supabase');
      }

      print("Usuario autenticado: ${response.user?.email}");
      return response;
    } catch (e) {
      print('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<UserModel> signInWithEmail(
    String email,
    String? password,
    String name,
    String lastName,
    String role,
    String? nit,
    String? identification,
    String? img,
    String? phoneNumber,
    String? nameCompany,
    String? selectedTypePerson,
  ) async {
    print("Intentando registrar usuario...");
    print(
      "Datos del registro: email=$email, name=$name, lastName=$lastName, role=$role",
    );

    // Registrar el usuario en Auth
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password ?? '',
      //emailRedirectTo: 'myapp://email-verified',
    );

    if (response.user != null) {
      print("Registro exitoso ${response.user}");

      // Determinar id_person_type (1 para Natural, 2 para Jurídica)
      final idPersonType = selectedTypePerson == "Persona Natural" ? 1 : 2;

      // Determinar id_identification_type (CC o NIT)
      final idIdentificationType =
          selectedTypePerson == "Persona Juridica" ? 2 : 1;

      // Insertar datos adicionales en la tabla user_profile
      final userProfileResponse =
          await Supabase.instance.client.from('user_profile').insert({
            'user_id': response.user!.id,
            'name': name,
            'lastname': lastName,
            'email': email,
            'phone_number': phoneNumber,
            'picture': img,
            'name_company': nameCompany,
            'id_person_type': idPersonType,
            'id_identification_type': idIdentificationType,
            'identification':
                selectedTypePerson == "Persona Juridica" ? nit : identification,
            'auth_provider': 'email',
          }).select();

      if (userProfileResponse.isEmpty) {
        throw Exception("Error al guardar perfil: respuesta vacía o nula");
      } else {
        print("Perfil creado exitosamente: $userProfileResponse");
      }

      return UserModel(
        id: response.user?.id ?? '', // Provide the required 'id' parameter
        email: response.user?.email ?? email,
        token: response.session?.accessToken ?? '',
        name: name,
        lastname: lastName,
        nit: nit ?? '',
        identification: identification,
        img: img ?? '',
      );
    } else {
      throw Exception("Error en el registro: ${response}");
    }
  }

  Future<Map<String, dynamic>?> getUserProfileByEmail(String email) async {
    return await _supabase
        .from('user_profile')
        .select()
        .eq('email', email)
        .maybeSingle();
  }

  Future<void> loginWithEmail(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.session == null) {
      throw Exception('Error al iniciar sesión: sesión no creada.');
    }
  }

  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String name,
    required String lastname,
    required String role,
    required String? nit,
    required String? identification,
    required String? img,
    required String? phoneNumber,
    required String? nameCompany,
    required String? selectedTypePerson,
  }) async {
    try {
      await _supabase.from('user_profile').insert({
        'user_id': userId,
        'email': email,
        'name': name,
        'lastname': lastname,
        'created_at': DateTime.now().toIso8601String(),
        'phone_number': phoneNumber,
        'picture': img,
        'name_company': nameCompany,
        'id_person_type': selectedTypePerson == "Persona Natural" ? 1 : 2,
        'id_identification_type':
            selectedTypePerson == "Persona Juridica" ? 2 : 1,
        'identification':
            selectedTypePerson == "Persona Juridica" ? nit : identification,
        'auth_provider': 'google',
      });
    } catch (e) {
      print('Error al crear el perfil: $e');
      throw Exception('Error al crear el perfil: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? phone,
    String? email,
    String? name,
    String? lastname,
  }) async {
    try {
      // Solo actualizar campos que no sean null
      Map<String, dynamic> updates = {};

      if (name != null && name.isNotEmpty) updates['name'] = name;
      if (lastname != null && lastname.isNotEmpty)
        updates['lastname'] = lastname;
      if (email != null && email.isNotEmpty) updates['email'] = email;
      if (phone != null && phone.isNotEmpty) updates['phone_number'] = phone;

      if (updates.isNotEmpty) {
        await _supabase
            .from('user_profile')
            .update(updates)
            .eq('user_id', userId);

        print('✅ Perfil actualizado: $updates');
      } else {
        print('⚠️ No hay campos para actualizar');
      }
    } catch (e) {
      print('❌ Error actualizando perfil: $e');
      rethrow;
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      // 1. Verifica si hay una sesión activa en Supabase
      final session = _supabase.auth.currentSession;
      if (session == null) return false;

      return true; // Si tiene perfil, retorna true
    } catch (e) {
      return false;
    }
  }

  Future<bool> logoutRequested() async {
    try {
      await _supabase.auth.signOut();
      await _googleSignInOut.signOut();
      // Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // Limpiar cualquier dato local si es necesario
      print("Sesión cerrada exitosamente");
      return true;
    } catch (e) {
      print('Error al cerrar sesión: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'urbanestia://reset-password', // este será tu deep link
    );
  }
}
