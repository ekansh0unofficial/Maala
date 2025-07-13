import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/shared_pref_helper.dart';

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
    return Dialog(
      backgroundColor: Colors.black.withAlpha(230),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choose Soundtrack",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...sounds.asMap().entries.map((entry) {
              final index = entry.key;
              final soundPath = entry.value;
              final meta = soundMeta[index];
              final isSelected = _selected == soundPath;
              final isPlaying = _previewing == soundPath;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  tileColor: isSelected ? Colors.white24 : Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.stop_circle : Icons.play_circle,
                      color: isPlaying ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () => _togglePreview(soundPath),
                  ),
                  title: Text(
                    meta["title"]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    meta["subtitle"]!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  trailing:
                      isSelected
                          ? const Icon(Icons.check, color: Colors.amber)
                          : null,
                  onTap: () {
                    SharedPrefHelper.setSelectedSound(soundPath);
                    setState(() {
                      _selected = soundPath;
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
