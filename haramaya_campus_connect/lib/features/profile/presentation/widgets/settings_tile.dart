import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';
import 'package:haramaya_campus_connect/core/theme/app_text_styles.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: effectiveIconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: iconColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
    );
  }
}

