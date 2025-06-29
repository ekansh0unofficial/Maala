import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final _picker = ImagePicker();

  static Future<String?> pickAndReturnBGI(BuildContext context) async {
    // ✅ Ask for permission
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access gallery.')),
      );
      return null;
    }

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.height,
      imageQuality: 100,
    );

    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'bg_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final savedPath = p.join(appDir.path, fileName);

      await File(picked.path).copy(savedPath);
      return savedPath;
    }

    return null;
  }
}
