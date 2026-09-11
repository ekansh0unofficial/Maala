import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/image_picker_helper.dart';
import '../services/theme_service.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../themes/meditation_themes.dart';
import '../widgets/background_image.dart';

class BackgroundPickerDialog extends StatefulWidget {
  const BackgroundPickerDialog({super.key});

  @override
  State<BackgroundPickerDialog> createState() => _BackgroundPickerDialogState();
}

class _BackgroundPickerDialogState extends State<BackgroundPickerDialog> {
  // Loaded dynamically from the AssetManifest so the grid always matches
  // whatever files actually exist under assets/images/ (jpg, png, etc.)
  // instead of being hardcoded to a fixed list that breaks when a file is
  // missing or the format differs.
  final List<String> _imageAssets = [];
  bool _loading = true;

  String? _previewImage;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    var assets = <String>[];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      assets = manifest
          .listAssets()
          .where(
            (path) =>
                path.startsWith('assets/images/') &&
                !path.endsWith('/') &&
                path != 'assets/images/icon_image.jpg',
          )
          .toList()
        ..sort();
    } catch (e) {
      debugPrint('Failed to load background assets: $e');
    }
    if (!mounted) return;
    setState(() {
      _imageAssets
        ..clear()
        ..addAll(assets);
      _loading = false;
    });
  }

  Future<void> _customPicker() async {
    final newImagePath = await ImagePickerHelper.pickCandidate();
    if (!mounted) return;
    if (newImagePath != null) {
      setState(() => _previewImage = newImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.current;
    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child:
            _previewImage == null
                ? _buildGrid(theme)
                : _buildPreview(theme),
      ),
    );
  }

  Widget _buildGrid(MeditationTheme theme) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Background',
            style: AppTextStyles.cormorantDialogTitle,
          ),
          const SizedBox(height: 16),
          // +1 for the trailing "Pick from gallery" tile.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
            itemCount: _imageAssets.length + 1,
            itemBuilder: (context, index) {
              if (index == _imageAssets.length) {
                return GestureDetector(
                  onTap: _customPicker,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      border: Border.all(color: theme.border),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: theme.primaryAccent,
                      size: 32,
                    ),
                  ),
                );
              }
              final img = _imageAssets[index];
              return GestureDetector(
                onTap: () => setState(() => _previewImage = img),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  child: Image.asset(img, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(MeditationTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: BackgroundImage(path: _previewImage),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => setState(() => _previewImage = null),
              child: Text(
                'Back',
                style: AppTextStyles.interSub,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ImagePickerHelper.commitBackground(_previewImage!);
                if (!mounted) return;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.surfaceElevated,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                ),
              ),
              child: Text(
                'Set as Background',
                style: AppTextStyles.interSubSemiBold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
