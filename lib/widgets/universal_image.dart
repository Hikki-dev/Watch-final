import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UniversalImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const UniversalImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: errorWidget ?? const Icon(Icons.image_not_supported),
      );
    }

    // 1. Check for Base64 (starts with "data:image" or just raw base64 heuristics if needed)
    if (imagePath!.startsWith('data:image')) {
      try {
        final base64String = imagePath!.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: width,
              height: height,
              child: errorWidget ?? const Icon(Icons.broken_image),
            );
          },
        );
      } catch (e) {
        return SizedBox(
          width: width,
          height: height,
          child: errorWidget ?? const Icon(Icons.broken_image),
        );
      }
    }

    // 2. Network Image
    // Use CachedNetworkImage for better performance if it's a URL
    if (imagePath!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ?? const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            errorWidget ?? const Icon(Icons.broken_image),
      );
    }

    // 3. Asset Image (Fallback)
    // If it's a local asset path
    return Image.asset(
      imagePath!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: errorWidget ?? const Icon(Icons.broken_image),
        );
      },
    );
  }
}
