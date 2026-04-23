import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/IdentificationTypeModal.dart';
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import 'package:pqrsmart/data/repository/DependenceRepository.dart';
import 'package:pqrsmart/data/services/DependenceService.dart';
import 'package:pqrsmart/presentation/blocs/DependenceBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/DependenceEvent.dart';
import 'package:pqrsmart/presentation/states/DependenceState.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/states/auth_state.dart';

class RegisterAdminPage extends StatefulWidget {
  const RegisterAdminPage({Key? key}) : super(key: key);

  @override
  State<RegisterAdminPage> createState() => _RegisterAdminPageState();
}

class _RegisterAdminPageState extends State<RegisterAdminPage> {
  static const _verde = Color(0xFF4A6B5A);
  static const _bg    = Color(0xFFF2F4F3);

  // Controllers
  final _userController                 = TextEditingController();
  final _nameController                 = TextEditingController();
  final _lastNameController             = TextEditingController();
  final _emailController                = TextEditingController();
  final _passwordController             = TextEditingController();
  final _identificationNumberController = TextEditingController();
  final _numberController               = TextEditingController();
  // Agrega junto a los otros controllers
  final _confirmPasswordController = TextEditingController();

  // Dropdowns
  IdentificationTypeModal? _selectedIdentificationType;
  PersonTypeModal?         _selectedPersonType;
  DependenceModel?         _selectedDependence;
  String                   _rolSeleccionado = 'USER';

  // Password
  bool   _obscureText    = true;
  String _confirmPassword = '';
  bool   _passwordsMatch = true;

  // Datos del backend (vienen del AuthBloc igual que en Register)
  List<IdentificationTypeModal> _identificationTypes = [];
  List<PersonTypeModal>         _personTypes         = [];

  final Map<String, bool> _validationRules = {
    'Al menos 8 caracteres':          false,
    'Al menos una mayúscula':         false,
    'Al menos una minúscula':         false,
    'Al menos un número':             false,
    'Al menos un carácter especial':  false,
  };

  final List<Map<String, String>> _roles = [
    {'value': 'USER',  'label': 'Usuario'},
    {'value': 'ADMIN', 'label': 'Administrador'},
    {'value': 'SECRE', 'label': 'Secretario'},
  ];

  @override
  void initState() {
    super.initState();
    // Carga tipos de identificación y persona (mismo evento que Register)
    context.read<AuthBloc>().add(LoadFormDataEvent());
  }

  @override
  void dispose() {
    _userController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _identificationNumberController.dispose();
    _numberController.dispose();
    _confirmPasswordController.dispose(); // ← agrega esto
    super.dispose();
  }

  void _validatePassword(String password) {
    setState(() {
      _validationRules['Al menos 8 caracteres']         = password.length >= 8;
      _validationRules['Al menos una mayúscula']        = password.contains(RegExp(r'[A-Z]'));
      _validationRules['Al menos una minúscula']        = password.contains(RegExp(r'[a-z]'));
      _validationRules['Al menos un número']            = password.contains(RegExp(r'[0-9]'));
      _validationRules['Al menos un carácter especial'] = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  void _comparePasswords() {
    setState(() {
      _passwordsMatch = _passwordController.text == _confirmPassword;
    });
  }

  void _registrar(BuildContext context) {
    if (!_passwordsMatch) {
      _snack('Las contraseñas no coinciden', Colors.red);
      return;
    }
    if (_validationRules.containsValue(false)) {
      _snack('La contraseña no cumple los requisitos mínimos', Colors.red);
      return;
    }
    if (_selectedIdentificationType == null ||
        _selectedPersonType == null) {
      _snack('Por favor completa todos los campos obligatorios', Colors.red);
      return;
    }
    if (_rolSeleccionado == 'SECRE' && _selectedDependence == null) {
      _snack('Un secretario debe tener una dependencia asignada', Colors.red);
      return;
    }

    try {
      context.read<AuthBloc>().add(
        SignInEventAmin(
          user:                 _userController.text.trim(),
          name:                 _nameController.text.trim(),
          lastName:             _lastNameController.text.trim(),
          email:                _emailController.text.trim(),
          password:             _passwordController.text.trim(),
          identificationType:   _selectedIdentificationType!.idIdentificationType,
          identificationNumber: int.parse(_identificationNumberController.text.trim()),
          personType:           _selectedPersonType!.idPersonType,
          number:               int.parse(_numberController.text.trim()),
          dependence:           _selectedDependence?.idDependence ?? 7,
          role:                 _rolSeleccionado,
        ),
      );
    } catch (e) {
      _snack('Error: ${e.toString()}', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DependenceBloc>(
      create: (_) => DependenceBloc(DependenceRepository(DependenceService()))
        ..add(LoadDependenceEvent()),
      child: BlocListener<AuthBloc, AuthStates>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            _snack('¡Usuario creado exitosamente!', _verde);
            Navigator.pop(context);
          } else if (state is AuthError) {
            _snack(state.message, Colors.red);
          } else if (state is AuthRegisterLoaded) {
            setState(() {
              _identificationTypes = state.identificationTypes;
              _personTypes         = state.personTypes;
            });
          }
        },
        child: Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _verde,
            foregroundColor: Colors.white,
            centerTitle: true,
            title: Text('Nuevo Usuario',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            leading: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
            leadingWidth: 90,
            actions: [
              BlocBuilder<AuthBloc, AuthStates>(
                builder: (context, state) => TextButton(
                  onPressed: state is AuthLoading ? null : () => _registrar(context),
                  child: state is AuthLoading
                      ? SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text('Guardar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          body: BlocBuilder<DependenceBloc, DependenceState>(
            builder: (context, depState) {
              final dependencias = depState is DependenceLoaded
                  ? depState.dependence
                  : <DependenceModel>[];

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Información básica ─────────────────
                    _seccion('Información básica'),
                    SizedBox(height: 12),

                    _campo(
                      controller: _userController,
                      label: 'Usuario',
                      hint: 'juanperez123',
                      icon: Icons.account_circle_outlined,
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _campo(
                            controller: _nameController,
                            label: 'Nombre',
                            hint: 'Juan',
                            icon: Icons.person_outline,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            controller: _lastNameController,
                            label: 'Apellido',
                            hint: 'Pérez',
                            icon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    _campo(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hint: 'm@ejemplo.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 12),

                    _campo(
                      controller: _numberController,
                      label: 'Teléfono',
                      hint: '3001234567',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: 24),

                    // ── Identificación ─────────────────────
                    _seccion('Identificación'),
                    SizedBox(height: 12),

                    // Tipo identificación — del backend
                    _dropdownDecor(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<IdentificationTypeModal>(
                          value: _selectedIdentificationType,
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Tipo de identificación',
                            prefixIcon: Icon(Icons.badge_outlined, color: _verde),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200)),
                          ),
                          selectedItemBuilder: (_) => _identificationTypes
                              .map((t) => Text(t.nameIdentificationType,
                              overflow: TextOverflow.ellipsis))
                              .toList(),
                          items: _identificationTypes
                              .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.nameIdentificationType,
                                overflow: TextOverflow.ellipsis),
                          ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedIdentificationType = v),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    _campo(
                      controller: _identificationNumberController,
                      label: 'Número de identificación',
                      hint: 'Sin puntos ni comas',
                      icon: Icons.fingerprint,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),

                    // Tipo persona — del backend
                    _dropdownDecor(
                      child: DropdownButtonFormField<PersonTypeModal>(
                        value: _selectedPersonType,
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Tipo de persona',
                          prefixIcon: Icon(Icons.person_search_outlined, color: _verde),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200)),
                        ),
                        items: _personTypes
                            .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.namePersonType),
                        ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPersonType = v),
                      ),
                    ),

                    SizedBox(height: 24),

                    // ── Rol y dependencia ──────────────────
                    _seccion('Rol y dependencia'),
                    SizedBox(height: 12),

                    // Rol — manual
                    _dropdownDecor(
                      child: DropdownButtonFormField<String>(
                        value: _rolSeleccionado,
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          prefixIcon: Icon(Icons.shield_outlined, color: _verde),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200)),
                        ),
                        items: _roles
                            .map((r) => DropdownMenuItem(
                          value: r['value'],
                          child: Text(r['label']!),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _rolSeleccionado = v!;
                          // Si cambia de SECRE limpiar dependencia
                          if (v != 'SECRE') _selectedDependence = null;
                        }),
                      ),
                    ),

                    // Dependencia — solo visible si es SECRE
                    if (_rolSeleccionado == 'SECRE') ...[
                      SizedBox(height: 12),
                      depState is DependenceLoading
                          ? _loadingField('Cargando dependencias...')
                          : _dropdownDecor(
                        child: DropdownButtonFormField<DependenceModel>(
                          value: _selectedDependence,
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Dependencia',
                            prefixIcon: Icon(Icons.business_outlined,
                                color: _verde),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200)),
                          ),
                          // Excluye la dependencia 7 (sin dependencia)
                          items: dependencias
                              .where((d) => d.idDependence != 7)
                              .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                                d.nameDependence ?? 'Sin nombre',
                                overflow: TextOverflow.ellipsis),
                          ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedDependence = v),
                        ),
                      ),
                    ],

                    SizedBox(height: 24),

                    // ── Contraseña ─────────────────────────
                    _seccion('Contraseña'),
                    SizedBox(height: 12),

                    _campoPassword(
                      controller: _passwordController,
                      label: 'Contraseña',
                      onChanged: (v) {
                        _validatePassword(v);
                        _comparePasswords();
                      },
                    ),
                    SizedBox(height: 10),

                    // Reglas de contraseña
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _validationRules.keys.map((rule) {
                          final ok = _validationRules[rule]!;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Icon(
                                  ok ? Icons.check_circle : Icons.cancel,
                                  color: ok ? Colors.green : Colors.red,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(rule,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 12),

                    _campoPassword(
                      controller: _confirmPasswordController,
                      label: 'Confirmar contraseña',
                      onChanged: (v) {
                        setState(() => _confirmPassword = v);
                        _comparePasswords();
                      },
                    ),
                    SizedBox(height: 6),

                    if (_confirmPassword.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            _passwordsMatch
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _passwordsMatch
                                ? Colors.green
                                : Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            _passwordsMatch
                                ? 'Las contraseñas coinciden'
                                : 'Las contraseñas no coinciden',
                            style: TextStyle(
                                color: _passwordsMatch
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 13),
                          ),
                        ],
                      ),

                    SizedBox(height: 32),

                    // ── Botón guardar ──────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.save_outlined),
                        label: Text('Guardar Usuario',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _verde,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _registrar(context),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Widgets helpers ──────────────────────────────────────

  Widget _seccion(String titulo) => Text(
    titulo.toUpperCase(),
    style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 1.0),
  );

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(icon, color: _verde, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _verde, width: 1.5)),
        ),
      );

  Widget _campoPassword({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) =>
      TextField(
        controller: controller,
        obscureText: _obscureText,
        onChanged: onChanged,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock_outline, color: _verde, size: 20),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscureText = !_obscureText),
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[500],
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _verde, width: 1.5)),
        ),
      );

  Widget _dropdownDecor({required Widget child}) => child;

  Widget _loadingField(String msg) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _verde)),
        SizedBox(width: 10),
        Text(msg,
            style: TextStyle(color: Colors.grey[500], fontSize: 14)),
      ],
    ),
  );
}