import 'package:flutter/material.dart';

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

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hintText,
    this.controller,
    this.icon, // Ícono opcional
    this.suffixIcon, // Ícono al final opcional
    this.onSuffixIconTap, // Acción al tocar el ícono final
    this.keyboardType,
    this.widthFactor = 0.9, // Valor por defecto
    this.onChanged,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,

            onChanged: onChanged, // Se ejecuta cada vez que el usuario escribe
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * widthFactor,
                minHeight: 50,
              ),
              prefixIcon:
                  icon != null ? Icon(icon) : null, // Agrega el ícono si existe
              suffixIcon:
                  suffixIcon != null
                      ? IconButton(
                        icon: Icon(suffixIcon),
                        onPressed: onSuffixIconTap, // Acción al tocar el ícono
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
