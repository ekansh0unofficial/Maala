import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/sound_helper.dart';
import 'package:maala_app/services/theme_service.dart';
import 'package:maala_app/theme/app_text_styles.dart';
import 'package:maala_app/theme/app_theme.dart';
import 'package:maala_app/themes/meditation_themes.dart';
import 'package:maala_app/timer_screen/timer_helper.dart';
import 'package:maala_app/widgets/background_image.dart';
import 'package:maala_app/widgets/timer_complete_overlay.dart';
import '../services/shared_pref_helper.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isRunning = false;
  Duration _remaining = const Duration();
  bool _showSessionComplete = false;
  String _completedDurationLabel = '';

  @override
  void initState() {
    super.initState();
    TimerHelper.initialize(_updateRemaining);
    _isRunning = TimerHelper.isRunning;
    _remaining = TimerHelper.remaining;
    _handleJustCompleted();
  }

  // Called on every timer event. The ticking HH:MM:SS readout is isolated
  // to notifier-driven rebuilds (see the ValueListenableBuilder), so this
  // only needs to refresh state that changes rarely (running flag) plus the
  // completion overlay — not the whole tree every second. [_remaining] is
  // still synced silently on every call (no setState) so the start-button
  // guard and the time-picker initial value never go stale.
  void _updateRemaining() {
    if (!mounted) return;
    _remaining = TimerHelper.remaining;
    final running = TimerHelper.isRunning;
    if (running != _isRunning) {
      setState(() => _isRunning = running);
    }
    _handleJustCompleted();
  }

  /// If the timer finished (live tick or wall-clock reconciliation after a
  /// restart), raise the completion overlay for the just-finished session.
  void _handleJustCompleted() {
    if (!TimerHelper.justCompleted) return;
    TimerHelper.clearCompletedFlag();
    _completedDurationLabel = TimerHelper.formatDuration(
      TimerHelper.totalDuration,
    );
    if (!mounted) return;

    // This Future belongs to the exact timer completion that triggered this
    // overlay. It resolves only after the third bell has finished.
    final completionFuture = TimerHelper.completionFuture;

    setState(() => _showSessionComplete = true);

    if (completionFuture != null) {
      unawaited(() async {
        await completionFuture;
        if (mounted) {
          setState(() => _showSessionComplete = false);
        }
      }());
    }
  }

  void _dismissSessionComplete() {
    // Explicit dismiss cuts off the remaining alarm bells too.
    SoundHelper.stopTimerAlarm();
    if (mounted) setState(() => _showSessionComplete = false);
  }

  void _startTimer() {
    // Source of truth is the helper (wall-clock reconciled); the local copy
    // is kept in sync by [_updateRemaining] but the guard reads live state
    // so a stale field can never make Start silently no-op.
    if (TimerHelper.remaining <= Duration.zero) return;
    TimerHelper.start();
    setState(() => _isRunning = true);
  }

  void _pauseTimer() {
    TimerHelper.pause();
    SoundHelper.pause();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    TimerHelper.reset();
    SoundHelper.stop();
    unawaited(SoundHelper.stopTimerAlarm());
    setState(() {
      _isRunning = false;
      _remaining = TimerHelper.remaining;
      _showSessionComplete = false;
    });
  }

  void _showTimePickerDialog() {
    _pauseTimer();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _TimePickerDialog(initial: _remaining),
    );
  }

  void _toggleMusic() async {
    if (SoundHelper.isPlaying) {
      await SoundHelper.pause();
    } else {
      await SoundHelper.play();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TimerHelper.detachTickCallback();
    super.dispose();
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
          appBar: AppBar(
            title: Text(
              AppLocalizations.translate('meditate'),
              style: AppTextStyles.cormorantTitle,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Reflects the CURRENT music state (not the action): active accent
              // note when playing, dimmed muted icon when still. Always tappable
              // so the soundtrack can be started/paused independently of the timer.
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        SoundHelper.isPlaying
                            ? theme.primaryAccent.withValues(alpha: 0.20)
                            : Colors.transparent,
                  ),
                  child: Icon(
                    SoundHelper.isPlaying
                        ? Icons.music_note_rounded
                        : Icons.music_off_rounded,
                    size: 24,
                    color: theme.primaryAccent,
                  ),
                ),
                iconSize: 40,
                tooltip: SoundHelper.isPlaying ? 'Pause sound' : 'Play sound',
                onPressed: _toggleMusic,
              ),
            ],
          ),
          body: LayoutBuilder(
            builder:
                (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _showTimePickerDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 28,
                            ),
                            decoration: BoxDecoration(
                              color: theme.surface,
                              borderRadius: BorderRadius.circular(
                                AppRadii.large,
                              ),
                              border: Border.all(color: theme.border),
                            ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Ticking readout isolated to a ValueListenable
                                  // so only this Text rebuilds each second (the
                                  // rest of the screen no longer setStates per tick).
                                  ValueListenableBuilder<Duration>(
                                    valueListenable:
                                        TimerHelper.remainingNotifier,
                                    builder: (context, remaining, _) {
                                      final text = TimerHelper.formatDuration(
                                        remaining,
                                      );
                                      return Text(
                                        text,
                                        style: AppTextStyles.montserratDisplay
                                            .copyWith(
                                              fontSize: 56,
                                              letterSpacing: 2,
                                            ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isRunning
                                        ? 'counting down'
                                        : 'tap to set',
                                    style: AppTextStyles.interCaption.copyWith(
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _customButton(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              _isRunning ? _pauseTimer : _startTimer,
                              theme,
                            ),
                            const SizedBox(width: 24),
                            _customButton(
                              Icons.stop_rounded,
                              _resetTimer,
                              theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
        if (_showSessionComplete)
          TimerCompleteOverlay(
            durationLabel: _completedDurationLabel,
            theme: theme,
            onDismiss: _dismissSessionComplete,
          ),
      ],
    );
  }

  Widget _customButton(
    IconData icon,
    VoidCallback onPressed,
    MeditationTheme theme,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.surface,
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Icon(icon, size: 30, color: AppColors.textPrimary),
      ),
    );
  }
}

class _TimePickerDialog extends StatefulWidget {
  final Duration initial;

  const _TimePickerDialog({required this.initial});

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  late int _hour;
  late int _minute;
  late int _second;
  late final _hourController = FixedExtentScrollController(initialItem: _hour);
  late final _minuteController = FixedExtentScrollController(
    initialItem: _minute,
  );
  late final _secondController = FixedExtentScrollController(
    initialItem: _second,
  );

  @override
  void initState() {
    super.initState();
    _hour = widget.initial.inHours.clamp(0, 23);
    _minute = widget.initial.inMinutes.remainder(60);
    _second = widget.initial.inSeconds.remainder(60);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.current;

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Meditation Time',
              style: AppTextStyles.cormorantDialogTitle,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dial('hr', 23, _hourController, (val) => _hour = val, theme),
                _dial(
                  'min',
                  59,
                  _minuteController,
                  (val) => _minute = val,
                  theme,
                ),
                _dial(
                  'sec',
                  59,
                  _secondController,
                  (val) => _second = val,
                  theme,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: theme.surfaceElevated,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    TimerHelper.updateDuration(_hour, _minute, _second);
                  },
                  child: Text(
                    "Set",
                    style: AppTextStyles.interSubSemiBold,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: theme.surfaceElevated,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: AppTextStyles.interSub,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dial(
    String tag,
    int max,
    FixedExtentScrollController controller,
    ValueChanged<int> onChanged,
    MeditationTheme theme,
  ) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 96,
          decoration: BoxDecoration(
            color: theme.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            child: ListWheelScrollView.useDelegate(
              controller: controller,
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
                        style: AppTextStyles.cormorantDialogHeading.copyWith(
                          fontSize: 26,
                        ),
                      ),
                    ),
                childCount: max + 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tag,
          style: AppTextStyles.interCaption.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
