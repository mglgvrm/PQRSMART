import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urbanestia/core/utils/custom_textFormFiel_utils.dart';
import 'package:urbanestia/core/utils/device_utils.dart';
import 'package:urbanestia/presentation/blocs/auth_bloc.dart';
import 'package:urbanestia/presentation/states/auth_event.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController _emailController = TextEditingController();
  void _submit() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      context.read<AuthBloc>().add(SendResetPasswordEmail(email));
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // Icono personalizado
          onPressed: () {
            Navigator.pop(context); // Navegación manual
          },
        ),
        title: Text(
          'Verifica tu correo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ), // Título de la AppBar
        centerTitle: true, // Centra el título
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tarjeta blanca con borde redondeado
              Container(
                padding: EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    Text(
                      'Enviar código de un solo uso',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Ingresa tu correo electrónico para recibir un código de verificación.',
                      style: TextStyle(fontSize: 15, color: Color(0xff8391A1)),
                    ),
                    SizedBox(height: 30),
                    CustomTextField(
                      label: "Correo Electrónico",
                      hintText: "tu@email.com",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                        text: 'Enviar',
                        width: DeviceUtils.getWitdh(context) * 1,
                        color: Color(0xff3F5A4C),
                        onTap: () {
                          _submit();
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Asegúrate de revisar tu bandeja de \n entrada y la carpeta de spam.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xff8391A1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final Function()? onTap;
  final Color color;
  final double width;
  final String text;
  const CustomButton({
    super.key,
    required this.onTap,
    required this.color,
    required this.width,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        width: width,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
