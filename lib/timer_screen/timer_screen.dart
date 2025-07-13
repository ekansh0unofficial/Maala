import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maala_app/services/sound_helper.dart';
import 'package:maala_app/settings_screen/settings_screen.dart';
import 'package:maala_app/timer_screen/timer_helper.dart';
import '../services/shared_pref_helper.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isRunning = false;
  Duration _remaining = const Duration();
  String? bg;

  @override
  void initState() {
    super.initState();

    _isRunning = SharedPrefHelper.getTimerRunning();
    bg = SharedPrefHelper.getBackgroundImage();
    TimerHelper.initialize(_updateRemaining);

    if (_isRunning) {
      TimerHelper.start();
    }

    _remaining = TimerHelper.remaining;
  }

  void _updateRemaining() {
    if (!mounted) return;
    setState(() {
      _remaining = TimerHelper.remaining;
    });
  }

  void _startTimer() {
    if (_remaining > Duration.zero) {
      TimerHelper.start();
      SharedPrefHelper.setTimerRunning(true);
      setState(() => _isRunning = true);
    }
  }

  void _pauseTimer() {
    TimerHelper.pause();
    SharedPrefHelper.setTimerRunning(false);
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    TimerHelper.reset();
    SharedPrefHelper.setTimerRunning(false);
    setState(() {
      _isRunning = false;
      _remaining = TimerHelper.remaining;
    });
  }

  void _showTimePickerDialog() {
    int hour = 0, minute = 0, second = 0;
    _pauseTimer();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDial('hr', 23, 0, (val) => hour = val),
                    _buildDial('min', 59, 0, (val) => minute = val),
                    _buildDial('sec', 59, 0, (val) => second = val),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        TimerHelper.updateDuration(hour, minute, second);
                        _updateRemaining();
                      },
                      child: const Text(
                        "Set",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white10,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDial(
    String tag,
    int max,
    int initial,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListWheelScrollView.useDelegate(
              itemExtent: 96,
              perspective: 0.003,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder:
                    (context, index) => Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                childCount: max + 1,
              ),
            ),
          ),
        ),
        Text(tag),
      ],
    );
  }

  Widget _buildTimeBox(String value) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget customButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromARGB(139, 56, 56, 56),
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 28, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    Widget? background;
    if (bg != null) {
      background =
          bg!.startsWith('assets/')
              ? Image.asset(bg!, fit: BoxFit.cover)
              : Image.file(File(bg!), fit: BoxFit.cover);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (background != null) background,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "MEDITATE",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            backgroundColor: Colors.black.withOpacity(0.3),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  SoundHelper.isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () async {
                  if (SoundHelper.isPlaying) {
                    await SoundHelper.pause();
                  } else {
                    await SoundHelper.play();
                  }
                  setState(() {});
                },
              ),

              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  setState(() {
                    bg = SharedPrefHelper.getBackgroundImage();
                  });
                },
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showTimePickerDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(120, 149, 148, 148),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(12),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _buildTimeBox(h),
                          _buildTimeBox(m),
                          _buildTimeBox(s),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customButton(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    _isRunning ? _pauseTimer : _startTimer,
                  ),
                  const SizedBox(width: 24),
                  customButton(Icons.stop, _resetTimer),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    TimerHelper.pause();
    super.dispose();
  }
}
