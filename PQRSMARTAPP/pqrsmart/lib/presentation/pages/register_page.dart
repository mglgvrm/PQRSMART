import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/utils/cusatom_dropdownButtonField_utils.dart';
import 'package:pqrsmart/core/utils/custom_textFormFiel_utils.dart';
import 'package:pqrsmart/data/model/IdentificationTypeModal.dart';
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import 'dart:math' as math;
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/states/auth_state.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  // Colores del gradiente (equivalente a --gradient-color-1..4)
  final List<Color> _gradientColors = [
    const Color(0xFF3F5A4C), // verde oscuro (base de tu app)
    const Color(0xFF2D4A5A), // azul verdoso
    const Color(0xFF1A3A4A), // azul marino
    const Color(0xFF4A6B5A), // verde medio
  ];

  // Variables para los dropdowns
  List<IdentificationTypeModal> _identificationTypes = [];
  List<PersonTypeModal> _personTypes = [];
  IdentificationTypeModal? _selectedIdentificationType;
  PersonTypeModal? _selectedPersonType;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )
      ..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeInOut);
    context.read<AuthBloc>().add(LoadFormDataEvent());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _obscureText = true;
  String? _password;
  String _confirmPassword = '';
  bool _passwordsMatch = true;

  final TextEditingController userController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController identificationNumberController =
  TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Map<String, bool> _validationRules = {
    "Al menos 8 caracteres": false,
    "Al menos una mayúscula": false,
    "Al menos una minúscula": false,
    "Al menos un número": false,
    "Al menos un carácter especial": false,
  };

  void _comparePasswords() {
    setState(() {
      _passwordsMatch = _password == _confirmPassword;
    });
  }

  void _validatePassword(String password) {
    setState(() {
      _password = password;
      _validationRules["Al menos 8 caracteres"] = password.length >= 8;
      _validationRules["Al menos una mayúscula"] = password.contains(
        RegExp(r'[A-Z]'),
      );
      _validationRules["Al menos una minúscula"] = password.contains(
        RegExp(r'[a-z]'),
      );
      _validationRules["Al menos un número"] = password.contains(
        RegExp(r'[0-9]'),
      );
      _validationRules["Al menos un carácter especial"] = password.contains(
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]'),
      );
    });
  }

  void _registerUser() {
    if (!_passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    if (_validationRules.containsValue(false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña no cumple con los requisitos mínimos"),
        ),
      );
      return;
    }

    if (_selectedIdentificationType == null || _selectedPersonType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor complete todos los campos obligatorios"),
        ),
      );
      return;
    }

    try {
      context.read<AuthBloc>().add(
        SignInEvent(
          user: userController.text.trim(),
          name: nameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          password: _password.toString(),
          identificationType: _selectedIdentificationType!.idIdentificationType,
          // int ID
          identificationNumber: int.parse(
            identificationNumberController.text.trim(),
          ),
          personType: _selectedPersonType!.idPersonType,
          // int ID
          number: int.parse(numberController.text.trim()),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en el registro: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthStates>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Registro exitoso! Por favor verifique su correo electronico para la verificacion'),
              backgroundColor: Color(0xFF4A6B5A),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthRegisterLoaded) {
          setState(() {
            _identificationTypes = state.identificationTypes;
            _personTypes = state.personTypes;
          });
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFECF4FD),
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
                      Color.lerp(_gradientColors[0], _gradientColors[2], anim)!,
                      Color.lerp(_gradientColors[1], _gradientColors[3], anim)!,
                      Color.lerp(_gradientColors[3], _gradientColors[0], anim)!,
                    ],
                  ),
                ),
                child: child,
              );
            },

            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),

                    const Text(
                      "Crear Cuenta",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Colors
                            .black),
                        children: [
                          const TextSpan(
                            text:
                            "Ingrese sus credenciales para crear una cuenta en ",
                            style: TextStyle(color: Colors.white),
                          ),
                          const TextSpan(
                            text: "PQRSMART",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Usuario
                    CustomTextField(
                      label: 'Usuario',
                      hintText: 'juanperez123',
                      controller: userController,
                      suffixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),

                    // Nombre y Apellido
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Nombres',
                            hintText: 'Juan José',
                            widthFactor: 0.3,
                            controller: nameController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Apellidos',
                            hintText: 'Pérez López',
                            widthFactor: 0.3,
                            controller: lastNameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Correo
                    CustomTextField(
                      label: "Correo electrónico",
                      hintText: "m@ejemplo.com",
                      controller: emailController,
                      suffixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Correo electrónico con que te has registrado",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 14),

                    // Dropdowns dinámicos con los datos del backend:
                    DropdownButtonFormField<IdentificationTypeModal>(
                      value: _selectedIdentificationType,
                      dropdownColor: Colors.white, // ← fondo blanco del menú desplegado
                      isExpanded: true, // ← clave: ocupa todo el ancho disponible
                      decoration: InputDecoration(
                        labelText: 'Tipo de Identificación',
                        prefixIcon: Icon(Icons.badge),
                        filled: true,
                        fillColor: Colors.white, // ← fondo blanco del campo
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                      ),
                      // Texto seleccionado con ellipsis
                      selectedItemBuilder: (context) {
                        return _identificationTypes.map((tipo) {
                          return Text(
                            tipo.nameIdentificationType,
                            overflow: TextOverflow.ellipsis, // ← corta el texto largo
                            maxLines: 1,
                          );
                        }).toList();
                      },
                      // Items del dropdown desplegado (pueden mostrarse completos)
                      items: _identificationTypes.map((tipo) {
                        return DropdownMenuItem<IdentificationTypeModal>(
                          value: tipo,
                          child: Text(
                            tipo.nameIdentificationType,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedIdentificationType = value);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Número de identificación
                    CustomTextField(
                      label: 'Número de identificación',
                      hintText: 'Ingrese el número sin puntos ni comas',
                      widthFactor: 0.9,
                      controller: identificationNumberController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Escribe el número de identificación sin puntos ni comas",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<PersonTypeModal>(
                      value: _selectedPersonType,
                      hint: const Text('Tipo de persona'),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white, // ← fondo blanco del campo
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                      ),
                      items: _personTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.namePersonType),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPersonType = value),
                    ),
                    // Teléfono
                    CustomTextField(
                      label: 'Teléfono',
                      hintText: 'Ingrese el número de teléfono',
                      widthFactor: 0.9,
                      controller: numberController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Escribe el número de teléfono sin puntos ni comas",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 14),

                    // Contraseña
                    CustomTextField(
                      label: "Contraseña",
                      hintText: "************",
                      icon: Icons.lock_outline,
                      widthFactor: 0.9,
                      obscureText: _obscureText,
                      suffixIcon: _obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixIconTap: () =>
                          setState(() => _obscureText = !_obscureText),
                      onChanged: (value) {
                        setState(() => _password = value);
                        _comparePasswords();
                        _validatePassword(value);
                      },
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      "La contraseña debe cumplir con los siguientes requisitos.",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 5),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _validationRules.keys.map((rule) {
                        return Row(
                          children: [
                            Icon(
                              _validationRules[rule]! ? Icons.check : Icons
                                  .close,
                              color: _validationRules[rule]!
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              rule,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Confirmar contraseña
                    CustomTextField(
                      label: "Confirmar contraseña",
                      hintText: "************",
                      icon: Icons.lock_outline,
                      widthFactor: 0.9,
                      obscureText: _obscureText,
                      suffixIcon: _obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixIconTap: () =>
                          setState(() => _obscureText = !_obscureText),
                      onChanged: (value) {
                        setState(() {
                          _confirmPassword = value;
                          _comparePasswords();
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Escribe nuevamente la contraseña",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _confirmPassword.isEmpty
                            ? ""
                            : _passwordsMatch
                            ? "✅ Las contraseñas coinciden"
                            : "❌ Las contraseñas no coinciden",
                        style: TextStyle(
                          color: _passwordsMatch ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón registrar
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.9,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F5A4C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _registerUser,
                        child: const Text(
                          "Crear cuenta",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.center,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          children: [
                            const TextSpan(
                              text: "¿Ya tienes una cuenta? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: "Iniciar sesión",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                      context,
                                      '/login');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
