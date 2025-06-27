// lib/screens/counter_screen.dart
import 'package:flutter/material.dart';
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
                  onPressed: () {},
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
                  color: const Color.fromARGB(
                    192,
                    231,
                    230,
                    230,
                  ).withAlpha(200),
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
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(
                      Icons.self_improvement,
                      size: 32,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 8)],
                    ),
                    Icon(
                      Icons.favorite,
                      size: 32,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 8)],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
