import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        counterText: maxLength != null ? null : '',
      ),
    );
  }
}
