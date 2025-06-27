// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../services/shared_pref_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticEnabled = SharedPrefHelper.getHapticEnabled();
  bool _keepScreenOn = SharedPrefHelper.getKeepScreenOn();

  void _toggleHaptic(bool value) {
    setState(() => _hapticEnabled = value);
    SharedPrefHelper.setHapticEnabled(value);
  }

  void _toggleKeepScreenOn(bool value) {
    setState(() => _keepScreenOn = value);
    SharedPrefHelper.setKeepScreenOn(value);
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
            onChanged: _toggleHaptic,
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Keep Screen On',
            value: _keepScreenOn,
            onChanged: _toggleKeepScreenOn,
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
            onTap: () {},
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
