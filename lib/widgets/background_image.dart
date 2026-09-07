import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-bleed background image from an asset or a user-picked file.
/// Falls back to the default asset if the file is missing or unreadable.
///
/// The base image is decoded at display resolution (largest screen dimension
/// x device pixel ratio) via [ResizeImage], which preserves aspect ratio, so
/// large backing files (e.g. 2400px) are never fully decoded just to be
/// scaled down by the compositor.
class BackgroundImage extends StatelessWidget {
  final String? path;

  const BackgroundImage({super.key, required this.path});

  /// Builds the exact [ImageProvider] [BackgroundImage] uses for [path], so
  /// callers (e.g. startup precache) can warm the same cache entry the widget
  /// will hit. Decoding happens at display resolution via [ResizeImage].
  static ImageProvider providerFor(String path, {required int target}) {
    final ImageProvider base = path.startsWith('assets/')
        ? AssetImage(path)
        : FileImage(File(path));
    if (target <= 0) return base;
    return ResizeImage(base, width: target, allowUpscaling: false);
  }

  @override
  Widget build(BuildContext context) {
    if (path == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final target =
            (math.max(constraints.maxWidth, constraints.maxHeight) * dpr)
                .round();
        // RepaintBoundary keeps the wallpaper in its own layer, so per-tap and
        // per-second repaints elsewhere never re-rasterize the full-bleed image.
        return RepaintBoundary(
          child: Image(
            image: providerFor(path!, target: target),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Image(
              image: providerFor('assets/images/1.jpg', target: target),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}