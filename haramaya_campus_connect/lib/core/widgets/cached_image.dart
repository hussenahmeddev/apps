import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haramaya_campus_connect/core/theme/app_colors.dart';

class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData placeholderIcon;

  const CachedImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholderIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildShimmer(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
        fadeInDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        placeholderIcon,
        size: 40,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;

  const CachedAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AppColors.primaryContainer,
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
      );
    }

    final initials = _getInitials(name ?? '');
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }
}

