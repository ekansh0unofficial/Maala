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
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [CounterScreen(), TimerScreen()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (isPortrait) {
      return Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: _screens,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GNav(
                gap: 4,
                color: Colors.white54,
                activeColor: Colors.white,
                tabBackgroundColor: Colors.white10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                backgroundColor: Colors.transparent,
                selectedIndex: _selectedIndex,
                mainAxisAlignment: MainAxisAlignment.center,
                onTabChange: _onNavTapped,
                tabs: const [
                  GButton(
                    icon: Icons.fingerprint,
                    iconSize: 28,
                    text: 'Counter',
                  ),
                  GButton(icon: Icons.timer, iconSize: 28, text: 'Timer'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // LANDSCAPE MODE
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 90,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
              ],
            ),
            child: Center(
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onNavTapped,
                labelType: NavigationRailLabelType.all,
                groupAlignment: 0.0,
                backgroundColor: const Color.fromARGB(169, 0, 0, 0),

                // Circle indicator
                indicatorColor: const Color.fromARGB(159, 158, 158, 158),
                indicatorShape: const CircleBorder(),

                selectedIconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 28,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: Colors.white60,
                  size: 24,
                ),
                selectedLabelTextStyle: const TextStyle(color: Colors.white),
                unselectedLabelTextStyle: const TextStyle(
                  color: Colors.white60,
                ),

                destinations: const [
                  NavigationRailDestination(
                    icon: SizedBox(
                      height: 48,
                      width: 48,
                      child: Center(child: Icon(Icons.fingerprint)),
                    ),
                    selectedIcon: SizedBox(
                      height: 48,
                      width: 48,
                      child: Center(child: Icon(Icons.fingerprint)),
                    ),
                    label: Text('Counter'),
                  ),
                  NavigationRailDestination(
                    icon: SizedBox(
                      height: 48,
                      width: 48,
                      child: Center(child: Icon(Icons.timer)),
                    ),
                    selectedIcon: SizedBox(
                      height: 48,
                      width: 48,
                      child: Center(child: Icon(Icons.timer)),
                    ),
                    label: Text('Timer'),
                  ),
                ],
              ),
            ),
          ),
          // Vertical PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}
