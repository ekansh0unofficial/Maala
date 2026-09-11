import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../themes/meditation_themes.dart';

/// Full-screen celebratory moment when a meditation session finishes.
/// Mirrors the mala-complete overlay's animated style (scale + fade + scrim)
/// with a calm, session-appropriate copy. Auto-dismisses or on tap.
class TimerCompleteOverlay extends StatefulWidget {
  final String durationLabel;
  final MeditationTheme theme;

  /// Called when the user taps the scrim to dismiss early.
  final VoidCallback? onDismiss;

  const TimerCompleteOverlay({
    super.key,
    required this.durationLabel,
    required this.theme,
    this.onDismiss,
  });

  @override
  State<TimerCompleteOverlay> createState() => _TimerCompleteOverlayState();
}

class _TimerCompleteOverlayState extends State<TimerCompleteOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scrimFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _scrimFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.theme.primaryAccent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scrimOpacity =
            0.45 * _scrimFadeAnimation.value * _fadeAnimation.value;

        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: Container(
              color: Colors.black.withValues(alpha: scrimOpacity),
              child: Center(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.self_improvement,
                            color: accent,
                            size: 48,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Session complete',
                            style: AppTextStyles.cormorantHeadline,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.durationLabel,
                            style: AppTextStyles.interTitle.copyWith(
                              color: accent,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'May you be at peace',
                            style: AppTextStyles.interBody.copyWith(
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: widget.onDismiss,
                            style: TextButton.styleFrom(
                              backgroundColor: accent.withValues(alpha: 0.15),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.large,
                                ),
                              ),
                            ),
                            child: Text(
                              'Dismiss',
                              style: AppTextStyles.interSubSemiBold.copyWith(
                                color: accent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}