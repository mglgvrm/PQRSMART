import 'package:flutter/material.dart';

class ActivationPage extends StatefulWidget {
  const ActivationPage({Key? key}) : super(key: key);

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  static const _verde = Color(0xFF4A6B5A);
  bool _loading = true;
  bool _success = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token =
    ModalRoute.of(context)?.settings.arguments as String?;
    if (token != null) {
      _activar(token);
    }
  }

  Future<void> _activar(String token) async {
    try {
      // TODO: context.read<AuthBloc>().add(ActivateUserEvent(token));
      await Future.delayed(Duration(seconds: 2)); // simula llamada
      setState(() {
        _loading = false;
        _success = true;
      });
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _loading = false;
        _success = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(32),
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading) ...[
                CircularProgressIndicator(color: _verde),
                SizedBox(height: 20),
                Text('Activando tu cuenta...',
                    style: TextStyle(
                        fontSize: 16, color: Colors.black87)),
              ] else if (_success) ...[
                Icon(Icons.check_circle_rounded,
                    color: _verde, size: 64),
                SizedBox(height: 16),
                Text('¡Cuenta activada!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                Text('Redirigiendo al inicio de sesión...',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[600])),
              ] else ...[
                Icon(Icons.error_outline,
                    color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text('Error al activar',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                Text('El enlace es inválido o ya fue usado.',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _verde,
                      foregroundColor: Colors.white),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Ir al login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}