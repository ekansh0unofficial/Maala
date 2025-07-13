import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/shared_pref_helper.dart';

class SoundPickerDialog extends StatefulWidget {
  const SoundPickerDialog({super.key});

  @override
  State<SoundPickerDialog> createState() => _SoundPickerDialogState();
}

class _SoundPickerDialogState extends State<SoundPickerDialog> {
  final List<String> sounds = List.generate(3, (i) => 'audio/${i + 1}.mp3');
  String? _selected;
  String? _previewing; // currently playing track path
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
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
            ...sounds.map((soundPath) {
              final index = sounds.indexOf(soundPath) + 1;
              final isSelected = _selected == soundPath;
              final isPlaying = _previewing == soundPath;

              return Padding(
                padding: const EdgeInsets.all(8),
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
                    "Track $index",
                    style: const TextStyle(color: Colors.white),
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
