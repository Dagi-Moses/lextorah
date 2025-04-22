import 'dart:typed_data';
import 'package:flutter/material.dart';

class BuildDisplayImage extends StatelessWidget {
  const BuildDisplayImage({
    super.key,
    required this.fileBytes, // Web: bytes of the selected file
    required this.userImage, // Path for mobile or storage
    required this.onPressed, // Action for changing the image
  });

  final Uint8List? fileBytes; // For web (image data)
  final String userImage; // For mobile (file path or local storage)
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50.0,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              fileBytes != null
                  ? MemoryImage(fileBytes!)
                  : null, // Display image here
        ),
        Positioned(
          bottom: 0.0,
          right: 0.0,
          child: InkWell(
            onTap: onPressed,
            child: const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 20.0,
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
