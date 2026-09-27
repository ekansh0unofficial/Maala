import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/rate_prompt_service.dart';
import 'package:maala_app/services/sound_helper.dart';
import 'package:maala_app/services/theme_service.dart';
import 'package:maala_app/theme/app_text_styles.dart';
import 'package:maala_app/services/vibration_service.dart';
import 'package:maala_app/theme/app_theme.dart';
import 'package:maala_app/widgets/background_image.dart';
import 'package:maala_app/widgets/daily_quote.dart';
import 'package:maala_app/widgets/mala_complete_overlay.dart';
import '../services/shared_pref_helper.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;
  int _countLimit = 108;
  int _sessionMalas = 0;
  int _streak = 0;
  String _mantraText = 'ॐ नमः शिवाय';
  bool _showCompletionOverlay = false;
  bool _focusMode = false;

  /// Set while a modal dialog/bottom-sheet is open so we never register a
  /// stray tap (e.g. from the on-screen keyboard) as a counter increment.
  bool _dialogOpen = false;

  static const List<Map<String, String>> _mantras = [
    {'text': 'ॐ', 'label': 'Om'},
    {'text': 'ॐ नमः शिवाय', 'label': 'Om Namah Shivaya'},
    {'text': 'ॐ मणि पद्मे हूँ', 'label': 'Om Mani Padme Hum'},
    {'text': 'राम', 'label': 'Ram'},
    {'text': 'हरे कृष्ण', 'label': 'Hare Krishna'},
    {'text': 'ॐ गं गणपतये नमः', 'label': 'Om Gam Ganapataye Namaha'},
    {'text': 'ॐ नमो भगवते वासुदेवाय', 'label': 'Om Namo Bhagavate Vasudevaya'},
    {'text': 'सो हम', 'label': 'So Hum'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCounterState();
  }

  void _loadCounterState() {
    _countLimit = SharedPrefHelper.getCountLimit() ?? 108;
    _count = SharedPrefHelper.getCounter();
    if (_count > _countLimit) {
      _count = _countLimit;
      SharedPrefHelper.setCounter(_count);
    }
    _sessionMalas = SharedPrefHelper.getSessionMalas();
    _streak = SharedPrefHelper.getStreak();
    _mantraText = SharedPrefHelper.getMantraText();
    _focusMode = SharedPrefHelper.getFocusMode();
  }

  void _updateCounter(int value) {
    if (_dialogOpen) return;
    if (value > _countLimit) {
      value = 0;
      _sessionMalas++;
      // Persist once each; the increment helpers already store the new value,
      // so no need to re-write the locals back afterward.
      SharedPrefHelper.incrementSessionMalas();
      SharedPrefHelper.incrementTotalMalas();

      _updateStreak();
      _updateTodayMalas();

      VibrationService.vibrate(durationMs: 200);
      _playCompletionSound();

      setState(() {
        _showCompletionOverlay = true;
        _count = 0;
      });

      SharedPrefHelper.setCounter(0);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _showCompletionOverlay = false);
        // Ask for a Play review only after the celebration has finished,
        // never during focus mode. The service itself enforces
        // malas/days/cooldown/lifetime-cap gates.
        if (mounted && !_focusMode && !_dialogOpen) {
          RatePromptService.promptIfEligible();
        }
      });
    } else {
      VibrationService.vibrate(durationMs: 30);
      setState(() => _count = value);
      SharedPrefHelper.setCounter(_count);
    }

    SharedPrefHelper.incrementTotalChants();
  }

  /// Returns a stable, timezone-safe "yyyy-MM-dd" key based on local calendar
  /// date only (never parses/re-derives via DateTime.parse round-trips,
  /// which is what caused streaks to wobble across a DST/timezone change).
  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _updateStreak() {
    final now = DateTime.now();
    final today = _dateKey(now);
    final lastDate = SharedPrefHelper.getLastPracticeDate();

    if (lastDate == today) return;

    int currentStreak = SharedPrefHelper.getStreak();

    if (lastDate == null) {
      currentStreak = 1;
    } else {
      // Compare calendar-day keys directly instead of DateTime.parse +
      // .difference, which is sensitive to how the stored string was
      // formatted and can misfire around timezone/DST boundaries.
      final lastParts = lastDate.split('-').map(int.parse).toList();
      final lastDay = DateTime(lastParts[0], lastParts[1], lastParts[2]);
      final todayDay = DateTime(now.year, now.month, now.day);
      final diff = todayDay.difference(lastDay).inDays;

      if (diff == 1) {
        currentStreak++;
      } else if (diff > 1) {
        currentStreak = 1;
      }
      // diff == 0 already handled by the early return above.
    }

    SharedPrefHelper.setStreak(currentStreak);
    SharedPrefHelper.setLastPracticeDate(today);

    if (currentStreak > SharedPrefHelper.getBestStreak()) {
      SharedPrefHelper.setBestStreak(currentStreak);
    }

    _streak = currentStreak;
  }

  /// Malas completed today. Tracked separately from "session" malas so that
  /// resetting the on-screen counter (which clears session progress) can
  /// never make the Day screen's "Today" stat drop back to 0.
  void _updateTodayMalas() {
    final today = _dateKey(DateTime.now());
    final storedDate = SharedPrefHelper.getTodayMalasDate();
    if (storedDate != today) {
      SharedPrefHelper.setTodayMalasDate(today);
      SharedPrefHelper.setTodayMalas(1);
    } else {
      SharedPrefHelper.setTodayMalas(SharedPrefHelper.getTodayMalas() + 1);
    }
  }

  void _playCompletionSound() async {
    try {
      await SoundHelper.playCompletionGong();
    } catch (e) {
      // Ignore sound errors
    }
  }

  void _showMantraPicker() {
    _dialogOpen = true;
    final theme = ThemeService.current;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Mantra',
                  style: AppTextStyles.cormorantDialogHeading,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _mantras.length,
                    itemBuilder: (context, index) {
                      final mantra = _mantras[index];
                      final isSelected = _mantraText == mantra['text'];
                      return ListTile(
                        tileColor:
                            isSelected
                                ? theme.primaryAccent.withValues(alpha: 0.18)
                                : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.medium),
                        ),
                        title: Text(
                          mantra['text']!,
                          style: AppTextStyles.interMantra,
                        ),
                        subtitle: Text(
                          mantra['label']!,
                          style: AppTextStyles.interBody,
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check_circle,
                                  color: theme.primaryAccent,
                                )
                                : null,
                        onTap: () {
                          setState(() => _mantraText = mantra['text']!);
                          SharedPrefHelper.setMantraText(mantra['text']!);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.edit, color: theme.primaryAccent),
                    title: Text(
                      'Custom Mantra',
                      style: AppTextStyles.interSubRegular,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCustomMantraDialog();
                    },
                  ),
                ),
              ],
            ),
          ),
    ).then((_) {
      _dialogOpen = false;
    });
  }

  void _showCustomMantraDialog() {
    _dialogOpen = true;
    final controller = TextEditingController(text: _mantraText);
    final theme = ThemeService.current;
    showDialog(
      context: context,
      // Prevent an accidental outside/keyboard tap from dismissing the dialog
      // (which would then be swallowed by the counter's tap handler).
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: theme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter Mantra',
                    style: AppTextStyles.cormorantDialogHeading,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    style: AppTextStyles.interMantra,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Type your mantra',
                      hintStyle: AppTextStyles.interHint,
                      filled: true,
                      fillColor: theme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        borderSide: BorderSide(color: theme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        borderSide: BorderSide(color: theme.primaryAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.translate('cancel'),
                          style: AppTextStyles.interSub,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            setState(() => _mantraText = text);
                            SharedPrefHelper.setMantraText(text);
                          }
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppLocalizations.translate('set'),
                          style: AppTextStyles.interSubSemiBold.copyWith(
                            color: theme.primaryAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    ).then((_) {
      _dialogOpen = false;
    });
  }

  Future<void> _confirmAndResetCounter() async {
    // Bug fix: this used to reset instantly on a single accidental tap of
    // the AppBar icon, silently destroying an in-progress count with no
    // way to undo it. Now it requires an explicit confirmation.
    if (_count == 0 && _sessionMalas == 0) return;

    final theme = ThemeService.current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
            ),
            title: Text(
              'Reset count?',
              style: AppTextStyles.cormorantDialogTitle,
            ),
            content: Text(
              'This clears your current count ($_count / $_countLimit) and this '
              "session's mala progress. Your streak and totals are not affected.",
              style: AppTextStyles.interBody,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  AppLocalizations.translate('cancel'),
                  style: AppTextStyles.interSub,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Reset',
                  style: AppTextStyles.interSubSemiBold.copyWith(
                    color: theme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) _resetCounter();
  }

  void _resetCounter() {
    setState(() {
      _count = 0;
      _sessionMalas = 0;
    });
    SharedPrefHelper.setCounter(0);
    SharedPrefHelper.resetSessionMalas();
    _sessionMalas = 0;
  }

  void _toggleFocusMode() {
    setState(() => _focusMode = !_focusMode);
    if (_focusMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.current;
    final background = SharedPrefHelper.getBackgroundImage();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (background != null) BackgroundImage(path: background),
        // Scrim keeps text/icons readable over the full-bleed image.
        Container(color: theme.overlayColor),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar:
              _focusMode
                  ? null
                  : AppBar(
                    title: Text(
                      AppLocalizations.translate('pray'),
                      style: AppTextStyles.cormorantTitle,
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        // Bug fix: was directly wired to _resetCounter with no
                        // confirmation. Now routes through a confirm dialog.
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: _confirmAndResetCounter,
                      ),
                      IconButton(
                        // UX fix: focus mode previously only had a hidden
                        // long-press gesture with no visible affordance at
                        // all. It's now discoverable as a button too; the
                        // long-press still works for anyone used to it.
                        icon: const Icon(
                          Icons.fullscreen,
                          color: AppColors.textPrimary,
                        ),
                        tooltip: 'Focus mode',
                        onPressed: _toggleFocusMode,
                      ),
                    ],
                  ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _updateCounter(_count + 1),
            onLongPress: _toggleFocusMode,
            // Centers the whole portrait stack (mantra, counter, box below)
            // as one block. Center handles the case where content is
            // shorter than the screen; SingleChildScrollView guarantees no
            // overflow if it's ever taller (e.g. very short landscape
            // viewports) by letting it scroll instead of clipping.
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mantra (tappable to change). Styled as a pill/chip with a
                      // faint border and accent-tinted text so it visibly reads
                      // as an interactive control now that the icons are gone —
                      // otherwise it looks like static plain text.
                      GestureDetector(
                        onTap: _showMantraPicker,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 22,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryAccent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: theme.primaryAccent.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Text(
                            _mantraText,
                            style: AppTextStyles.interHeading.copyWith(
                              fontSize: _focusMode ? 24 : 17,
                              color: theme.primaryAccent,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Streak
                      if (!_focusMode && _streak > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_streak',
                                style: AppTextStyles.interTitle.copyWith(
                                  color: theme.primaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Counter card - flat surface
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: _focusMode ? 18 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(AppRadii.large),
                          border: Border.all(color: theme.border),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder:
                                  (child, anim) => ScaleTransition(
                                    scale: anim,
                                    child: child,
                                  ),
                              child: Text(
                                '$_count',
                                key: ValueKey(_count),
                                style: AppTextStyles.montserratDisplay.copyWith(
                                  fontSize: _focusMode ? 96 : 72,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            Text(
                              '/ $_countLimit',
                              style: AppTextStyles.interTitleMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Everything below the counter sits on top of a full-bleed
                      // background image, so it needs its own opaque-ish surface
                      // to stay readable regardless of the image underneath —
                      // matching the counter card above instead of floating
                      // directly on the scrim.
                      if (!_focusMode)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(AppRadii.large),
                            border: Border.all(color: theme.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Quote
                              const DailyQuote(),

                              // Tap hint
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  AppLocalizations.translate('longPressFocus'),
                                  style: AppTextStyles.interCaptionSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        if (_showCompletionOverlay)
          MalaCompleteOverlay(
            malasCount: _sessionMalas,
            countLimit: _countLimit,
            theme: theme,
            streak: _streak,
            onDismiss: () => setState(() => _showCompletionOverlay = false),
          ),
      ],
    );
  }
}
