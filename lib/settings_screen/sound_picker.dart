import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/shared_pref_helper.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

class SoundPickerDialog extends StatefulWidget {
  const SoundPickerDialog({super.key});

  @override
  State<SoundPickerDialog> createState() => _SoundPickerDialogState();
}

class _SoundPickerDialogState extends State<SoundPickerDialog> {
  final List<Map<String, String>> soundMeta = [
    {"title": "Meditative Gong", "subtitle": "bells"},
    {"title": "Meditative Gong 2", "subtitle": "bells"},
    {"title": "Forest Peace", "subtitle": "Pixabay"},
    {"title": "Inner peace", "subtitle": "Pixabay"},
    {"title": "Spiritual Moment", "subtitle": "Mixkit"},
    {"title": "Light Body Activation", "subtitle": "IamThatIam888 - Pixabay"},
  ];

  late final List<String> sounds;
  String? _selected;
  String? _previewing;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    sounds = List.generate(soundMeta.length, (i) => 'audio/${i + 1}.mp3');
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
      setState(() => _previewing = null);
    } else {
      await _player.stop();
      await _player.play(AssetSource(path));
      setState(() => _previewing = path);
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
              style: GoogleFonts.cormorantGaramond(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...sounds.asMap().entries.map((entry) {
              final index = entry.key;
              final soundPath = entry.value;
              final meta = soundMeta[index];
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
                        color: isPlaying ? theme.primaryAccent : AppColors.textSecondary,
                      ),
                      onPressed: () => _togglePreview(soundPath),
                    ),
                    title: Text(
                      meta["title"]!,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      meta["subtitle"]!,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: theme.primaryAccent)
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
    );
  }
}
