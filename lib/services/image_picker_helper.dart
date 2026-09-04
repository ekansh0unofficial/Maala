import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'shared_pref_helper.dart';
import 'theme_service.dart';

class ImagePickerHelper {
  static final _picker = ImagePicker();

  /// Picks a new background image from the system photo picker and copies it
  /// into the app documents directory. Returns the copied file's path, or
  /// null if the user cancelled or picking failed.
  ///
  /// Does NOT touch the currently set background - call [commitBackground]
  /// only after the user confirms the preview.
  static Future<String?> pickCandidate() async {
    try {
      // The system photo picker (Android Photo Picker / iOS PHPicker) needs
      // no storage permission, including Android 14+ "limited access".
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'bg_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final savedPath = p.join(appDir.path, fileName);

      await File(picked.path).copy(savedPath);
      return savedPath;
    } catch (e) {
      debugPrint('Background image pick failed: $e');
      return null;
    }
  }

  /// Persists [newPath] as the selected background and deletes the previous
  /// custom image file if one exists.
  static Future<void> commitBackground(String newPath) async {
    final oldPath = SharedPrefHelper.getBackgroundImage();
    SharedPrefHelper.setBackgroundImage(newPath);

    if (oldPath != null &&
        !oldPath.startsWith('assets/') &&
        oldPath != newPath &&
        File(oldPath).existsSync()) {
      try {
        await File(oldPath).delete();
      } catch (e) {
        debugPrint('Failed to delete old background image: $e');
      }
    }

    // Re-derive the theme from the newly selected background image.
    await ThemeService.initFromBackground();
  }
}
