import 'package:flutter/material.dart';
import 'package:pqrsmart/presentation/widgets/auth_widgets.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? icon; // Ícono opcional
  final IconData? suffixIcon; // Ícono al final opcional
  final VoidCallback? onSuffixIconTap; // Acción al tocar el ícono final
  final TextInputType? keyboardType;
  final double widthFactor; // Permite modificar el ancho
  final Function(String)?
  onChanged; // Callback para detectar cambios en el texto
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.icon, // Ícono opcional
    this.suffixIcon, // Ícono al final opcional
    this.onSuffixIconTap, // Acción al tocar el ícono final
    this.keyboardType,
    this.widthFactor = 0.9, // Valor por defecto
    this.onChanged,
    this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * widthFactor,
      ),
      child: PqrAuthField(
        label: label,
        hintText: hintText,
        controller: controller,
        obscureText: obscureText,
        prefixIcon: icon,
        suffixIcon: suffixIcon,
        onSuffixIconTap: onSuffixIconTap,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
