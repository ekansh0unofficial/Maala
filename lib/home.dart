import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:maala_app/counter_screen/counter_screen.dart';
import 'package:maala_app/timer_screen/timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<Widget> _screens = const [CounterScreen(), TimerScreen()];

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
        physics: const BouncingScrollPhysics(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 28.0, left: 32.0, right: 32.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: GNav(
              gap: 4,
              color: Colors.white54,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.white10,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              backgroundColor: Colors.transparent,
              selectedIndex: _selectedIndex,
              mainAxisAlignment: MainAxisAlignment.center,
              onTabChange: _onNavTapped,
              tabs: const [
                GButton(icon: Icons.fingerprint, iconSize: 28, text: 'Counter'),
                GButton(icon: Icons.timer, iconSize: 28, text: 'Timer'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
