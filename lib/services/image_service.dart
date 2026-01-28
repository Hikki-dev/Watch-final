import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified [source], resizes it, and returns the XFile.
  /// Returns null if no image was picked or an error occurred.
  Future<XFile?> pickImage({
    required ImageSource source,
    double maxWidth = 600,
    int quality = 50,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        imageQuality: quality,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('ImageService: Error picking image: $e');
      return null;
    }
  }

  /// Converts an [XFile] to a Base64 Data URI string capable of being displayed by UniversalImage.
  /// Format: "data:image/jpeg;base64,..."
  Future<String?> fileToBase64(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      // We assume JPEG for simplicity as ImagePicker usually outputs .jpg or .png
      // Ideally we'd check the mime type, but `data:image/jpeg` often works for png too in viewers,
      // or we can genericize it. For now, hardcoded to jpeg is safe for camera/gallery on mobile.
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('ImageService: Error converting to base64: $e');
      return null;
    }
  }
}
