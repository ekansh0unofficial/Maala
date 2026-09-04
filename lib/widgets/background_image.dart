import 'dart:io';
import 'package:flutter/material.dart';

/// Full-bleed background image from an asset or a user-picked file.
/// Falls back to the default asset if the file is missing or unreadable.
class BackgroundImage extends StatelessWidget {
  final String? path;

  const BackgroundImage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null) return const SizedBox.shrink();
    return path!.startsWith('assets/')
        ? Image.asset(path!, fit: BoxFit.cover)
        : Image.file(
            File(path!),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Image.asset(
              'assets/images/1.jpg',
              fit: BoxFit.cover,
            ),
          );
  }
}
