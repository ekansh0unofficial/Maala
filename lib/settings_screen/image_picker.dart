import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/image_picker_helper.dart';
import '../services/shared_pref_helper.dart';
import '../theme/app_theme.dart';
import '../themes/meditation_themes.dart';
import '../widgets/background_image.dart';

class BackgroundPickerDialog extends StatefulWidget {
  const BackgroundPickerDialog({super.key});

  @override
  State<BackgroundPickerDialog> createState() => _BackgroundPickerDialogState();
}

class _BackgroundPickerDialogState extends State<BackgroundPickerDialog> {
  late List<String> imageAssets;

  @override
  void initState() {
    super.initState();
    imageAssets = List.generate(5, (index) => 'assets/images/${index + 1}.jpg');
    imageAssets.add('GALLERY');
  }

  String? _previewImage;

  Future<void> _customPicker() async {
    final newImagePath = await ImagePickerHelper.pickCandidate();
    if (!mounted) return;
    if (newImagePath != null) {
      setState(() => _previewImage = newImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = meditationThemes[SharedPrefHelper.getThemeIndex()];
    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child:
            _previewImage == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Choose Background',
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: imageAssets.length,
                        itemBuilder: (context, index) {
                          final img = imageAssets[index];
                          if (img == 'GALLERY') {
                            return GestureDetector(
                              onTap: _customPicker,
                              child: GridTile(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.surfaceElevated,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.medium,
                                    ),
                                    border: Border.all(color: theme.border),
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: theme.primaryAccent,
                                    size: 32,
                                  ),
                                ),
                              ),
                            );
                          }
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
                  )
                : Column(
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
                            onPressed: () =>
                                setState(() => _previewImage = null),
                            child: Text(
                              'Back',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await ImagePickerHelper.commitBackground(
                                _previewImage!,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryAccent,
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.medium,
                                ),
                              ),
                            ),
                            child: Text(
                              'Set as Background',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
