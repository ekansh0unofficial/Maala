import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../themes/meditation_themes.dart';

class MalaCompleteOverlay extends StatefulWidget {
  final int malasCount;
  final int countLimit;
  final MeditationTheme theme;
  final int streak;

  /// Called when the user taps the scrim to dismiss early. Optional —
  /// the overlay is still auto-dismissed by the parent's timer either way.
  final VoidCallback? onDismiss;

  const MalaCompleteOverlay({
    super.key,
    required this.malasCount,
    required this.countLimit,
    required this.theme,
    this.streak = 0,
    this.onDismiss,
  });

  @override
  State<MalaCompleteOverlay> createState() => _MalaCompleteOverlayState();
}

class _MalaCompleteOverlayState extends State<MalaCompleteOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scrimFadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Soft pulse on the glow behind the icon — cheap, tasteful motion that
    // makes the moment feel alive instead of a static card popping up.
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    // Scrim fades in fast, out slow-ish with the card, so the background
    // dim never feels like a hard flash.
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
        // Bug fix: previously this widget was dropped straight into a Stack
        // with no positioning, so it rendered pinned to the top-left corner
        // instead of centered. Positioned.fill + Center makes it a proper
        // full-screen celebratory moment, and the scrim gives it the focus
        // this moment deserves instead of competing with the counter behind it.
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
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(
                              alpha: 0.25 * _glowAnimation.value,
                            ),
                            blurRadius: 48,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Soft radiating glow behind the icon for a bit of
                          // warmth at the peak moment, without needing any
                          // new animation dependencies.
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent.withValues(
                                    alpha: 0.15 * _glowAnimation.value,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.self_improvement,
                                color: accent,
                                size: 48,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${widget.countLimit}',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 44,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.malasCount} mala${widget.malasCount > 1 ? 's' : ''} completed today',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          if (widget.streak > 1) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: accent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.streak} day streak',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
