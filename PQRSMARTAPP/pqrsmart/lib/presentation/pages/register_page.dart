import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/core/utils/custom_textFormFiel_utils.dart';
import 'package:pqrsmart/data/model/IdentificationTypeModal.dart';
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/states/auth_state.dart';
import 'package:pqrsmart/presentation/widgets/auth_widgets.dart';
import 'package:pqrsmart/presentation/widgets/pqr_widgets.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  // Variables para los dropdowns
  List<IdentificationTypeModal> _identificationTypes = [];
  List<PersonTypeModal> _personTypes = [];
  IdentificationTypeModal? _selectedIdentificationType;
  PersonTypeModal? _selectedPersonType;
  String? _formDataError;
  bool _isLoadingFormData = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadFormDataEvent());
  }

  @override
  void dispose() {
    userController.dispose();
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    identificationNumberController.dispose();
    numberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
              content: Text(
                '¡Registro exitoso! Revisa tu correo electrónico para verificar la cuenta.',
              ),
              backgroundColor: AppColors.attended,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.cancelled,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthRegisterFormError) {
          setState(() {
            _formDataError = state.message;
            _isLoadingFormData = false;
          });
        } else if (state is AuthRegisterLoaded) {
          setState(() {
            _identificationTypes = state.identificationTypes;
            _personTypes = state.personTypes;
            _formDataError = null;
            _isLoadingFormData = false;
          });
        } else if (state is AuthRegisterFormLoading) {
          setState(() {
            _formDataError = null;
            _isLoadingFormData = true;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: PqrAuthBrandHeader()),
                        const SizedBox(height: 30),
                        const Text(
                          "Crear cuenta",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Regístrate para crear y consultar tus solicitudes.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isLoadingFormData)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.action,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Cargando opciones de registro...',
                                    style: TextStyle(color: AppColors.muted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_formDataError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceBlue,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formDataError!,
                                    style: const TextStyle(
                                      color: Color(0xFF8A2930),
                                      fontSize: 13,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _isLoadingFormData
                                          ? null
                                          : () => context.read<AuthBloc>().add(
                                              LoadFormDataEvent(),
                                            ),
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Volver a intentar'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.dark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Usuario
                        CustomTextField(
                          label: 'Usuario',
                          hintText: 'juanperez123',
                          controller: userController,
                          icon: Icons.person_outline,
                          widthFactor: 1,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Ingresa un nombre de usuario.'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          label: 'Nombres',
                          hintText: 'Juan José',
                          widthFactor: 1,
                          controller: nameController,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Ingresa tus nombres.'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Apellidos',
                          hintText: 'Pérez López',
                          widthFactor: 1,
                          controller: lastNameController,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Ingresa tus apellidos.'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Correo
                        CustomTextField(
                          label: 'Correo electrónico',
                          hintText: 'm@ejemplo.com',
                          widthFactor: 1,
                          controller: emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Ingresa tu correo electrónico.';
                            }
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email)) {
                              return 'Ingresa un correo electrónico válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Dropdowns dinámicos con los datos del backend:
                        DropdownButtonFormField<IdentificationTypeModal>(
                          initialValue: _selectedIdentificationType,
                          key: ValueKey(
                            'identification-${_identificationTypes.length}',
                          ),
                          dropdownColor: AppColors.white,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Tipo de identificación',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: AppColors.muted,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                color: AppColors.icon,
                                width: 1.4,
                              ),
                            ),
                          ),
                          validator: (value) => value == null
                              ? 'Selecciona el tipo de identificación.'
                              : null,
                          // Texto seleccionado con ellipsis
                          selectedItemBuilder: (context) {
                            return _identificationTypes.map((tipo) {
                              return Text(
                                tipo.nameIdentificationType,
                                overflow: TextOverflow
                                    .ellipsis, // ← corta el texto largo
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
                          widthFactor: 1,
                          controller: identificationNumberController,
                          keyboardType: TextInputType.number,
                          icon: Icons.numbers_outlined,
                          validator: (value) {
                            final number = value?.trim() ?? '';
                            if (number.isEmpty) {
                              return 'Ingresa tu número de identificación.';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(number) ||
                                int.tryParse(number) == null) {
                              return 'Usa solo números válidos.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<PersonTypeModal>(
                          initialValue: _selectedPersonType,
                          key: ValueKey('person-${_personTypes.length}'),
                          hint: const Text('Tipo de persona'),
                          dropdownColor: AppColors.white,
                          decoration: InputDecoration(
                            labelText: 'Tipo de persona',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: AppColors.muted,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: const BorderSide(
                                color: AppColors.icon,
                                width: 1.4,
                              ),
                            ),
                          ),
                          validator: (value) => value == null
                              ? 'Selecciona el tipo de persona.'
                              : null,
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
                          widthFactor: 1,
                          controller: numberController,
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_outlined,
                          validator: (value) {
                            final number = value?.trim() ?? '';
                            if (number.isEmpty) return 'Ingresa tu teléfono.';
                            if (!RegExp(r'^\d+$').hasMatch(number) ||
                                int.tryParse(number) == null) {
                              return 'Usa solo números válidos.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Contraseña
                        CustomTextField(
                          label: 'Contraseña',
                          hintText: 'Ingresa una contraseña segura',
                          icon: Icons.lock_outline,
                          widthFactor: 1,
                          controller: passwordController,
                          obscureText: _obscureText,
                          suffixIcon: _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onSuffixIconTap: () =>
                              setState(() => _obscureText = !_obscureText),
                          onChanged: (value) {
                            setState(() => _password = value);
                            _comparePasswords();
                            _validatePassword(value);
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Ingresa una contraseña.'
                              : null,
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          'La contraseña debe cumplir estos requisitos:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _validationRules.keys.map((rule) {
                            return Row(
                              children: [
                                Icon(
                                  _validationRules[rule]!
                                      ? Icons.check
                                      : Icons.close,
                                  color: _validationRules[rule]!
                                      ? AppColors.attended
                                      : AppColors.cancelled,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  rule,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Confirmar contraseña
                        CustomTextField(
                          label: 'Confirmar contraseña',
                          hintText: 'Escribe nuevamente tu contraseña',
                          icon: Icons.lock_outline,
                          widthFactor: 1,
                          controller: confirmPasswordController,
                          obscureText: _obscureText,
                          suffixIcon: _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onSuffixIconTap: () =>
                              setState(() => _obscureText = !_obscureText),
                          onChanged: (value) {
                            setState(() {
                              _confirmPassword = value;
                              _comparePasswords();
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirma tu contraseña.';
                            }
                            if (value != passwordController.text) {
                              return 'Las contraseñas no coinciden.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _confirmPassword.isEmpty
                                ? ""
                                : _passwordsMatch
                                ? 'Las contraseñas coinciden.'
                                : 'Las contraseñas no coinciden.',
                            style: TextStyle(
                              color: _passwordsMatch
                                  ? AppColors.attended
                                  : AppColors.cancelled,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Botón registrar
                        PqrPrimaryButton(
                          label: 'Crear cuenta',
                          icon: Icons.person_add_alt_1_outlined,
                          loading: state is AuthLoading,
                          onPressed: _registerUser,
                        ),
                        const SizedBox(height: 8),

                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.action,
                            ),
                            child: const Text(
                              '¿Ya tienes una cuenta? Inicia sesión',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
