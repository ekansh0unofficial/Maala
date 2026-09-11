import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/shared_pref_helper.dart';
import '../services/sound_catalog.dart';
import '../services/theme_service.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class SoundPickerDialog extends StatefulWidget {
  const SoundPickerDialog({super.key});

  @override
  State<SoundPickerDialog> createState() => _SoundPickerDialogState();
}

class _SoundPickerDialogState extends State<SoundPickerDialog> {
  late final List<String> sounds;
  String? _selected;
  String? _previewing;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    sounds = [for (final option in soundOptions) option.path];
    _selected = SharedPrefHelper.getSelectedSound();
    _player.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePreview(String path) async {
    if (_previewing == path) {
      await _player.stop();
      if (mounted) setState(() => _previewing = null);
    } else {
      await _player.stop();
      await _player.play(AssetSource(path));
      if (mounted) setState(() => _previewing = path);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose Soundtrack",
              style: AppTextStyles.cormorantDialogTitle,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...sounds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final soundPath = entry.value;
                  final option = soundOptions[index];
                  final isSelected = _selected == soundPath;
                  final isPlaying = _previewing == soundPath;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryAccent.withValues(alpha: 0.18)
                            : theme.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                      ),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.stop_circle : Icons.play_circle,
                            color: isPlaying
                                ? theme.primaryAccent
                                : AppColors.textSecondary,
                          ),
                          onPressed: () => _togglePreview(soundPath),
                        ),
                        title: Text(
                          option.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.interBodyLgSemiBold,
                        ),
                        subtitle: Text(
                          'Pairs best with the ${option.themeName} theme',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.interXs,
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: theme.primaryAccent,
                              )
                            : null,
                        onTap: () {
                          SharedPrefHelper.setSelectedSound(soundPath);
                          setState(() {
                            _selected = soundPath;
                          });
                        },
                      ),
                    ),
);
                  }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}