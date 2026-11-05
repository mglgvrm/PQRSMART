import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/states/auth_state.dart';
import 'package:pqrsmart/presentation/widgets/auth_widgets.dart';
import 'package:pqrsmart/presentation/widgets/pqr_widgets.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _requestSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _requestSent = false);
    context.read<AuthBloc>().add(
      RequestPasswordResetEvent(_emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthStates>(
    listener: (context, state) {
      if (state is ResetPasswordSent) {
        setState(() => _requestSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se enviaron las instrucciones de recuperación.'),
            backgroundColor: AppColors.attended,
          ),
        );
      } else if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.cancelled,
          ),
        );
      }
    },
    child: Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        leading: IconButton(
          tooltip: 'Regresar',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: PqrCard(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: PqrAuthBrandHeader()),
                      const SizedBox(height: 26),
                      const Text(
                        'Recupera el acceso a tu cuenta',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Ingresa el correo asociado a tu cuenta. Te enviaremos las instrucciones para restablecer la contraseña.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 22),
                      PqrAuthField(
                        label: 'Correo electrónico',
                        hintText: 'tu@email.com',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Ingresa tu correo.';
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)) {
                            return 'Ingresa un correo válido.';
                          }
                          return null;
                        },
                      ),
                      if (_requestSent) ...[
                        const SizedBox(height: 14),
                        const PqrCard(
                          color: AppColors.surfaceBlue,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.mark_email_read_outlined,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Revisa tu bandeja de entrada y la carpeta de correo no deseado.',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      BlocBuilder<AuthBloc, AuthStates>(
                        builder: (context, state) => PqrPrimaryButton(
                          label: 'Enviar instrucciones',
                          icon: Icons.send_outlined,
                          loading: state is AuthLoading,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
