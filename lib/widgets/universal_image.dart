import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UniversalImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  /// Keep the previous frame on screen while a new one resolves (used by the 360 viewer).
  final bool gapless;

  const UniversalImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.gapless = false,
  });

  /// Image provider for a path, so callers can precache frames.
  static ImageProvider providerFor(String path) => path.startsWith('http')
      ? CachedNetworkImageProvider(path)
      : AssetImage(path);

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
    if (imagePath!.startsWith('http') && kIsWeb) {
      // On the web the browser draws and decodes the picture itself (an <img>
      // element). The canvas decoder showed some photos as black boxes in
      // Safari on iPhone. The image server allows cross-origin use.
      return Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: gapless,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: width,
          height: height,
          child: errorWidget ?? const Icon(Icons.broken_image),
        ),
      );
    }
    if (imagePath!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath!,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: gapless
            ? Duration.zero
            : const Duration(milliseconds: 500),
        fadeOutDuration: gapless
            ? Duration.zero
            : const Duration(milliseconds: 1000),
        placeholder: (context, url) =>
            // Photographs sit on a studio backdrop that shows while they fade in,
            // so there is no spinner by default.
            placeholder ?? const SizedBox.shrink(),
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
      gaplessPlayback: gapless,
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
