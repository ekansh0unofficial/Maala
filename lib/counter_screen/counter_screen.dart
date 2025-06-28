import 'package:flutter/material.dart';
import 'package:maala_app/services/vibration_service.dart';
import 'package:maala_app/settings_screen/settings_screen.dart';
import '../services/shared_pref_helper.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;
  int? _countLimit;
  String? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _count = SharedPrefHelper.getCounter();
    _backgroundImage = SharedPrefHelper.getBackgroundImage();
    _countLimit = SharedPrefHelper.getCountLimit() ?? 108;
  }

  void _updateCounter(int value) {
    if (value > _countLimit!) {
      value = 0;
    }
    setState(() => _count = value);
    SharedPrefHelper.setCounter(_count);
    if (value == _countLimit!) {
      VibrationService.vibrate(durationMs: 100);
    } else {
      VibrationService.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_backgroundImage != null)
          Image.asset(_backgroundImage!, fit: BoxFit.cover),
        GestureDetector(
          onTap: () => _updateCounter(_count + 1),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text(
                "PRAY",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              backgroundColor: const Color.fromARGB(121, 0, 0, 0),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _updateCounter(0),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
            body: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(123, 0, 0, 0).withAlpha(200),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '$_count',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
