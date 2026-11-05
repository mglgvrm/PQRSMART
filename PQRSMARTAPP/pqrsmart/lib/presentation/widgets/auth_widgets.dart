import 'package:flutter/material.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';

class PqrAuthBrandHeader extends StatelessWidget {
  const PqrAuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.chat_bubble,
          color: AppColors.primary,
          size: 36,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'PQRSMART',
        style: TextStyle(
          color: AppColors.dark,
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
      const Text(
        'Tu voz, una mejor gestión',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
    ],
  );
}

class PqrAuthField extends StatelessWidget {
  const PqrAuthField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.obscureText = false,
  });

  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null) ...[
        Text(
          label!,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
      ],
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(alpha: .05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.muted, size: 20),
            suffixIcon: suffixIcon == null
                ? null
                : IconButton(
                    onPressed: onSuffixIconTap,
                    color: AppColors.muted,
                    icon: Icon(suffixIcon, size: 20),
                  ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppColors.icon, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppColors.cancelled),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: AppColors.cancelled,
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
