import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: effectivePadding,
            side: BorderSide(
              color: backgroundColor ?? AppColors.primary,
              width: 1.5,
            ),
          ),
          child: _buildChild(foregroundColor ?? AppColors.primary),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.onPrimary,
          padding: effectivePadding,
        ),
        child: _buildChild(foregroundColor ?? AppColors.onPrimary),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.button),
        ],
      );
    }

    return Text(label, style: AppTextStyles.button);
  }
}

