import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImagePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick image from gallery or camera
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      } else {
        return null;
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Compress and convert image to Base64
  Future<String?> compressAndEncodeImage(File imageFile) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();

      // Decode the image
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Resize the image to reduce size
      final resizedImage = img.copyResize(image, width: 200, height: 200);

      // Encode to JPEG with quality 80
      final compressedBytes = img.encodeJpg(resizedImage, quality: 80);

      // Convert to Base64
      return base64Encode(compressedBytes);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Simple image picker that directly returns the selected image
  Future<File?> pickImageDirectly({bool fromCamera = false}) async {
    final image = await pickImage(fromCamera: fromCamera);
    return image;
  }

  /// Check if image is Base64 encoded
  bool isBase64Image(String? imageString) {
    if (imageString == null) return false;
    return !imageString.startsWith('data:image') &&
        !imageString.startsWith('http');
  }

  /// Create profile image widget
  Widget createProfileImage({
    required String? photoURL,
    double radius = 50,
    VoidCallback? onTap,
  }) {
    if (photoURL == null) {
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          child: Icon(Icons.person, size: radius),
        ),
      );
    }

    if (isBase64Image(photoURL)) {
      // Handle Base64 image
      try {
        final bytes = base64Decode(photoURL);
        return GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(bytes),
          ),
        );
      } catch (e) {
        return GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            child: Icon(Icons.person, size: radius),
          ),
        );
      }
    } else {
      // Handle network image
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(photoURL),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback to icon if network image fails
          },
          child: photoURL == null ? Icon(Icons.person, size: radius) : null,
        ),
      );
    }
  }

  /// Create profile image with camera icon overlay
  Widget createProfileImageWithCamera({
    required String? photoURL,
    double radius = 50,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        createProfileImage(photoURL: photoURL, radius: radius, onTap: onTap),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: onTap,
            ),
          ),
        ),
      ],
    );
  }
}
