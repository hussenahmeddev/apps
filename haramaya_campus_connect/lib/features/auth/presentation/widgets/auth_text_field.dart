import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.prefixIcon, size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

