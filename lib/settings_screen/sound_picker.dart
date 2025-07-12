import 'package:flutter/material.dart';
import '../services/shared_pref_helper.dart';

class SoundPickerDialog extends StatefulWidget {
  const SoundPickerDialog({super.key});

  @override
  State<SoundPickerDialog> createState() => _SoundPickerDialogState();
}

class _SoundPickerDialogState extends State<SoundPickerDialog> {
  final List<String> sounds = List.generate(
    3,
    (i) => 'assets/audio/${i + 1}.mp3',
  );
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = SharedPrefHelper.getSelectedSound();
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
              return Padding(
                padding: EdgeInsets.all(8),
                child: ListTile(
                  tileColor: isSelected ? Colors.white24 : Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.music_note,
                    color: isSelected ? Colors.amber : Colors.white,
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
