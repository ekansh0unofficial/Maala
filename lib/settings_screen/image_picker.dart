import 'package:flutter/material.dart';
import '../services/shared_pref_helper.dart';

class BackgroundPickerDialog extends StatefulWidget {
  const BackgroundPickerDialog({super.key});

  @override
  State<BackgroundPickerDialog> createState() => _BackgroundPickerDialogState();
}

class _BackgroundPickerDialogState extends State<BackgroundPickerDialog> {
  final List<String> imageAssets = List.generate(
    5,
    (index) => 'assets/images/${index + 1}.jpg',
  );

  String? _previewImage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withAlpha(220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _previewImage == null
                ? GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: imageAssets.length,
                  itemBuilder: (context, index) {
                    final img = imageAssets[index];
                    return GestureDetector(
                      onTap: () => setState(() => _previewImage = img),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(img, fit: BoxFit.cover),
                      ),
                    );
                  },
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _previewImage!,
                        fit: BoxFit.cover,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _previewImage = null),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            SharedPrefHelper.setBackgroundImage(_previewImage!);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                          ),
                          child: const Text(
                            'Set as Background',
                            style: TextStyle(color: Colors.white),
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
