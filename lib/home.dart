import 'package:flutter/material.dart';
import 'package:maala_app/counter_screen/counter_screen.dart';
import 'package:maala_app/day_screen/day_screen.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/theme_service.dart';
import 'package:maala_app/theme/app_text_styles.dart';
import 'package:maala_app/theme/app_theme.dart';
import 'package:maala_app/themes/meditation_themes.dart';
import 'package:maala_app/timer_screen/timer_screen.dart';
import 'package:maala_app/settings_screen/settings_screen.dart';

const double _sideRailWidth = 88;
const double _bottomNavHeight = 60;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  Orientation? _lastOrientation;

  final GlobalKey<DayScreenState> _dayKey = GlobalKey<DayScreenState>();

  // Built once: recreating these on every build would destroy and re-create
  // the TimerScreen state (re-running TimerHelper.initialize and
  // re-registering tick callbacks) on each orientation/nav rebuild.
  late final List<Widget> _screens = [
    const CounterScreen(),
    const TimerScreen(),
    DayScreen(key: _dayKey),
    const SettingsScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    if (index == 2) _dayKey.currentState?.refresh();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final isLandscape = orientation == Orientation.landscape;

    // Rotating rebuilds the PageView; re-sync it to the selected tab so the
    // visible page always matches the highlighted nav item instead of
    // snapping back to the first screen.
    if (_lastOrientation != null && _lastOrientation != orientation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(_selectedIndex);
        }
      });
    }
    _lastOrientation = orientation;

    return ValueListenableBuilder<MeditationTheme>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, theme, _) {
        return Scaffold(
          // The PageView lives in one persistent slot and only the chrome
          // (rail vs bottom nav) is swapped around it, so its element is never
          // destroyed and recreated when the orientation changes.
          body: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: isLandscape ? _sideRailWidth : 0,
                  bottom: isPortrait
                      ? _bottomNavHeight + MediaQuery.of(context).padding.bottom
                      : 0,
                ),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) {
                    setState(() => _selectedIndex = i);
                    if (i == 2) _dayKey.currentState?.refresh();
                  },
                  scrollDirection:
                      isPortrait ? Axis.horizontal : Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  children: _screens,
                ),
              ),
              if (isPortrait)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomNavBar(
                    selectedIndex: _selectedIndex,
                    onTap: _onNavTapped,
                  ),
                ),
              if (isLandscape)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _sideRailWidth,
                  child: _SideRail(
                    selectedIndex: _selectedIndex,
                    onTap: _onNavTapped,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  static const _icons = <IconData>[
    Icons.spa,
    Icons.timer,
    Icons.auto_graph,
    Icons.tune,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) {
              final selected = selectedIndex == i;
              final label = [
                AppLocalizations.translate('counter'),
                AppLocalizations.translate('timer'),
                AppLocalizations.translate('day'),
                AppLocalizations.translate('settings'),
              ][i];
              return _NavButton(
                icon: _icons[i],
                label: label,
                selected: selected,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.saffron.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: selected ? AppColors.saffron : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.interNav.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _SideRail({required this.selectedIndex, required this.onTap});

  static const _icons = <IconData>[
    Icons.spa,
    Icons.timer,
    Icons.auto_graph,
    Icons.tune,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _sideRailWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final selected = selectedIndex == i;
          final label = [
            AppLocalizations.translate('counter'),
            AppLocalizations.translate('timer'),
            AppLocalizations.translate('day'),
            AppLocalizations.translate('settings'),
          ][i];
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.saffron.withValues(alpha: 0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icons[i],
                    size: 28,
                    color: selected ? AppColors.saffron : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTextStyles.interNav.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
