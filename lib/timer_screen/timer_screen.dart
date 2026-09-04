import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/sound_helper.dart';
import 'package:maala_app/services/theme_service.dart';
import 'package:maala_app/theme/app_theme.dart';
import 'package:maala_app/themes/meditation_themes.dart';
import 'package:maala_app/timer_screen/timer_helper.dart';
import 'package:maala_app/widgets/background_image.dart';
import '../services/shared_pref_helper.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isRunning = false;
  Duration _remaining = const Duration();

  @override
  void initState() {
    super.initState();
    TimerHelper.initialize(_updateRemaining);
    _isRunning = TimerHelper.isRunning;
    _remaining = TimerHelper.remaining;
  }

  void _updateRemaining() {
    if (!mounted) return;
    setState(() {
      _remaining = TimerHelper.remaining;
      _isRunning = TimerHelper.isRunning;
    });
  }

  void _startTimer() {
    if (_remaining <= Duration.zero) return;
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
    setState(() {
      _isRunning = false;
      _remaining = TimerHelper.remaining;
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

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.current;
    final background = SharedPrefHelper.getBackgroundImage();

    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

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
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            // Bug fix: when the timer wasn't running, this button was
            // disabled but still showed SoundHelper.isPlaying's icon (often
            // the "mute" icon), which read as "sound is on, but I can't tap
            // it" — confusing/broken-looking. Now it always shows a plain
            // muted-note icon while disabled, and only reflects live
            // playback state once it's actually interactive.
            icon: Icon(
              _isRunning && SoundHelper.isPlaying
                  ? Icons.music_off_rounded
                  : Icons.music_note,
              color:
                  _isRunning ? AppColors.textPrimary : AppColors.textTertiary,
              size: 28,
            ),
            tooltip:
                _isRunning
                    ? (SoundHelper.isPlaying ? 'Pause sound' : 'Play sound')
                    : 'Start the timer to enable sound',
            onPressed:
                !_isRunning
                    ? null
                    : () async {
                      if (SoundHelper.isPlaying) {
                        await SoundHelper.pause();
                      } else {
                        await SoundHelper.play();
                      }
                      setState(() {});
                    },
          ),
        ],
      ),
      body: Center(
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
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$h:$m:$s',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 56,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRunning ? 'counting down' : 'tap to set',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
                _customButton(Icons.stop_rounded, _resetTimer, theme),
              ],
            ),
          ],
        ),
      ),
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
  late final _hourController = FixedExtentScrollController(
    initialItem: widget.initial.inHours.clamp(0, 23),
  );
  late final _minuteController = FixedExtentScrollController(
    initialItem: widget.initial.inMinutes.remainder(60),
  );
  late final _secondController = FixedExtentScrollController(
    initialItem: widget.initial.inSeconds.remainder(60),
  );

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int hour = widget.initial.inHours.clamp(0, 23);
    int minute = widget.initial.inMinutes.remainder(60);
    int second = widget.initial.inSeconds.remainder(60);
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
              style: GoogleFonts.cormorantGaramond(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dial('hr', 23, _hourController, (val) => hour = val, theme),
                _dial(
                  'min',
                  59,
                  _minuteController,
                  (val) => minute = val,
                  theme,
                ),
                _dial(
                  'sec',
                  59,
                  _secondController,
                  (val) => second = val,
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
                    TimerHelper.updateDuration(hour, minute, second);
                  },
                  child: Text(
                    "Set",
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
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
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 26,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
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
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textTertiary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
