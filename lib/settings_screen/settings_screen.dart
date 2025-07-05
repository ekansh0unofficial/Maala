// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:maala_app/services/screen_awake_service.dart';
import 'package:maala_app/settings_screen/image_picker.dart';
import '../services/shared_pref_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticEnabled = SharedPrefHelper.getHapticEnabled();
  bool _keepScreenOn = SharedPrefHelper.getKeepScreenOn();
  late TextEditingController _countLimitController;

  @override
  void initState() {
    super.initState();
    final countLimit = SharedPrefHelper.getCountLimit() ?? 108;
    _countLimitController = TextEditingController(text: countLimit.toString());
  }

  @override
  void dispose() {
    _countLimitController.dispose();
    super.dispose();
  }

  void _saveCountLimit(String value) {
    final trimmed = value.trim();
    final parsed = int.tryParse(trimmed);

    if (parsed != null && parsed >= 1 && parsed <= 9999) {
      SharedPrefHelper.setCountLimit(parsed);
      FocusScope.of(context).unfocus(); // close keyboard
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Counter limit set to $parsed")));
    } else {
      // Reset to last known value
      final fallback = SharedPrefHelper.getCountLimit() ?? 108;
      _countLimitController.text = fallback.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number (1–9999)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToggleTile(
            title: 'Enable Haptic Feedback',
            value: _hapticEnabled,
            onChanged: (val) {
              setState(() => _hapticEnabled = val);
              SharedPrefHelper.setHapticEnabled(val);
            },
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Keep Screen On',
            value: _keepScreenOn,
            onChanged: (val) async {
              setState(() => _keepScreenOn = val);
              SharedPrefHelper.setKeepScreenOn(val);
              val
                  ? await ScreenAwakeService.enable()
                  : await ScreenAwakeService.disable();
            },
          ),
          const Divider(height: 32, color: Colors.white24),
          ListTile(
            tileColor: const Color.fromARGB(96, 158, 158, 158),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Background Image',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const BackgroundPickerDialog(),
              ).then((_) => setState(() {}));
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text(
              "Counter Limit",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Number of taps before reset or vibration.",
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            tileColor: const Color.fromARGB(96, 158, 158, 158),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            trailing: SizedBox(
              width: 70,
              child: TextField(
                controller: _countLimitController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                onSubmitted: _saveCountLimit,
                onEditingComplete:
                    () => _saveCountLimit(_countLimitController.text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
      ),
    );
  }
}
