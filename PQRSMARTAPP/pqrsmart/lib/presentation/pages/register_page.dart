import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:urbanestia/core/utils/custom_textFormFiel_utils.dart';
import 'package:urbanestia/core/utils/cusatom_dropdownButtonField_utils.dart';
import 'package:urbanestia/presentation/blocs/auth_bloc.dart';
import 'package:urbanestia/presentation/states/auth_event.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _obscureText = true;
  String _selectedType = '';
  String? _selectedTypePerson; // Opción seleccionada del segundo dropdown
  String? _password;
  String? role;
  String _confirmPassword = '';
  bool _passwordsMatch = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController identificationController =
      TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nitController = TextEditingController();
  final TextEditingController nitNumberController = TextEditingController();

  //Validaciones
  final Map<String, bool> _validationRules = {
    "Al menos 8 caracteres": false,
    "Al menos una mayúscula": false,
    "Al menos una minúscula": false,
    "Al menos un número": false,
    "Al menos un carácter especial": false,
  };

  void _onTypeChanged(String? selectedType) {
    if (selectedType == null) return;
    setState(() {
      _selectedType = selectedType;
    });
  }

  //Comparar contraseña
  void _comparePasswords() {
    setState(() {
      _passwordsMatch = _password == _confirmPassword;
    });
  }

  //Función para validar la contraseña
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

  void _registerUser() async {
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
    if (_selectedTypePerson == "Persona Juridica") {
      final nit = nitNumberController.text.trim();

      final url = Uri.parse(
        "https://www.datos.gov.co/resource/c82u-588k.json?nit=$nit",
      );

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);

          if (data.isNotEmpty) {
            final empresa = data[0];

            final razonSocialApi = empresa['razon_social']?.trim() ?? '';
            final nombreTitularApi =
                empresa['representante_legal']?.trim() ?? '';

            final nombreIngresado =
                '${nameController.text.trim()} ${lastNameController.text.trim()}';
            final nombreEmpresaIngresado = nitController.text.trim();

            print('🟡 Comparando datos...');
            print('Empresa (API): $razonSocialApi');
            print('Empresa (Ingresada): $nombreEmpresaIngresado');
            print('Titular (API): $nombreTitularApi');
            print('Titular (Ingresado): $nombreIngresado');

            final coincideEmpresa =
                razonSocialApi.toLowerCase() ==
                nombreEmpresaIngresado.toLowerCase();
            final coincideTitular =
                nombreTitularApi.toLowerCase() == nombreIngresado.toLowerCase();
            if (coincideEmpresa && coincideTitular) {
              print('✅ Validación exitosa');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Los datos ingresados no coinciden con los del NIT.',
                  ),
                ),
              );
              return;
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No se encontró información para el NIT ingresado.',
                ),
              ),
            );
            return;
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al verificar la empresa: ${e.toString()}'),
          ),
        );
        return;
      }
    }

    try {
      context.read<AuthBloc>().add(
        SignInRequestedEmail(
          email: emailController.text,
          password: _password.toString(),
          name: nameController.text,
          lastname: lastNameController.text,
          role: role.toString(),
          nit:
              _selectedTypePerson == "Persona Juridica"
                  ? nitNumberController.text
                  : null,
          identification: identificationController.text,
          phoneNumber: numberController.text,
          nameCompany:
              _selectedTypePerson == "Persona Juridica"
                  ? nitController.text
                  : null,
          selectedTypePerson: _selectedTypePerson,
          img: null,
        ),
      );

      // Navegar a la siguiente pantalla después del registro exitoso
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en el registro: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF4FD),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea a la izquierda
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Crear Cuenta",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),

              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    const TextSpan(
                      text:
                          "Ingrese sus credenciales para crear una cuenta en ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: "Urbanestia",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Alinea a la izquierda

                      children: [
                        CustomTextField(
                          label: 'Nombres',
                          hintText: 'Juan Jose',
                          widthFactor: 0.3, // Ancho pequeño
                          controller: nameController,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Alinea a la izquierda
                      children: [
                        CustomTextField(
                          label: 'Apellidos',
                          hintText: 'Perez Lopez',
                          widthFactor: 0.3, // Ancho pequeño
                          controller: lastNameController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              CusatomDropdownbuttonfieldUtils<String>(
                label: 'Seleccione su Rol',
                hintText: ("¿Qué quieres ser?"),
                widthFactor: 0.9,
                value: _selectedType.isNotEmpty ? _selectedType : null,
                onChanged: _onTypeChanged,
                items: ['Venta y Alquiler', 'Compra y Renta'],
              ),

              if (_selectedType == "Venta y Alquiler")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    CusatomDropdownbuttonfieldUtils<String>(
                      label: 'Tipo de persona',
                      hintText: ("Selecciona otra opción"),
                      widthFactor: 0.9,
                      value: _selectedTypePerson,
                      items: ["Persona Natural", "Persona Juridica"],
                      onChanged: (String? selectPerson) {
                        setState(() {
                          _selectedTypePerson = selectPerson;
                        });
                      },
                    ),
                  ],
                ),

              if (_selectedTypePerson == "Persona Juridica" &&
                  _selectedType == "Venta y Alquiler")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Nombre de la empresa',
                      hintText: 'Ingrese el nombre de la empresa',
                      widthFactor: 0.9,
                      controller: nitController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'NIT',
                      hintText: 'Ingrese el NIT',
                      widthFactor: 0.9,
                      controller: nitNumberController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),

              if ((_selectedTypePerson == "Persona Natural" &&
                      _selectedType == "Venta y Alquiler") ||
                  _selectedType == "Compra y Renta")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Documento de identidad',
                      hintText: 'Ingrese el Documento de identidad',
                      widthFactor: 0.9,
                      controller: identificationController,
                      keyboardType: TextInputType.number,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(
                          "Escribe el número de identificación sin puntos ni comas",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Teléfono',
                hintText: 'Ingrese el número de teléfono',
                widthFactor: 0.9,
                controller: numberController,
                keyboardType: TextInputType.phone,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    "Escribe el número de teléfono sin puntos ni comas",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              CustomTextField(
                label: "Correo electrónico",
                hintText: "m@ejemplo.com",
                controller: emailController,
                suffixIcon: (Icons.email_outlined),
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

              const SizedBox(height: 14),
              // Campo de contraseña
              CustomTextField(
                label: "Contraseña",
                hintText: "************",
                icon: (Icons.lock_outline),
                widthFactor: 0.9,
                obscureText: _obscureText,
                suffixIcon:
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                onSuffixIconTap: () {
                  setState(() {
                    _obscureText = !_obscureText; // Alternar visibilidad
                  });
                },
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                  _comparePasswords(); // Llamar a la comparación inmediatamente después de actualizar _password
                  _validatePassword(value);
                },
              ),
              const SizedBox(height: 10),
              Text(
                "La contraseña debe cumplir con los siguientes requisitos.",
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 5),

              //Validaciones
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _validationRules.keys.map((rule) {
                      return Row(
                        children: [
                          Icon(
                            _validationRules[rule]! ? Icons.check : Icons.close,
                            color:
                                _validationRules[rule]!
                                    ? Colors.green
                                    : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(rule, style: TextStyle(color: Colors.black)),
                        ],
                      );
                    }).toList(),
              ),

              const SizedBox(height: 14),

              // Campo de contraseña
              CustomTextField(
                label: "Confirmar contraseña",
                hintText: "************",
                icon: (Icons.lock_outline),
                widthFactor: 0.9,
                obscureText: _obscureText,
                suffixIcon:
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                onSuffixIconTap: () {
                  setState(() {
                    _obscureText = !_obscureText; // Alternar visibilidad
                  });
                },
                onChanged: (value) {
                  setState(() {
                    _confirmPassword = value;
                    _comparePasswords(); // Llamar después de actualizar _confirmPassword
                  });
                },
              ),

              const SizedBox(height: 4),

              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    "Escribe nuevamente la contraseña",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Mensaje de comparación de contraseñas
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _confirmPassword.isEmpty
                      ? "" // No mostrar mensaje si el campo está vacío
                      : _passwordsMatch
                      ? "✅ Las contraseñas coinciden"
                      : "❌ Las contraseñas no coinciden",
                  style: TextStyle(
                    color: _passwordsMatch ? Colors.green : Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.9, // Usa el 90% del ancho del dispositivo
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F5A4C), // Color del botón
                    foregroundColor: Colors.white, // Color del texto
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _registerUser,
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: "¿Tienes una cuenta? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: "Iniciar sesión",
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
                                  '/passwordChanged',
                                );
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
    );
  }
}
