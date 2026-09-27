import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'shared_pref_helper.dart';

/// Non-intrusive Play In-App Review gate.
///
/// Shown only at moments of delight (after a mala completes), and only when
/// the user looks retained: enough lifetime malas + enough days installed,
/// with a long cooldown and a lifetime cap. Play itself may still suppress
/// the dialog (quota) — that is expected and counted as a prompt.
class RatePromptService {
  static const int minLifetimeMalas = 3;
  static const int minDaysInstalled = 3;
  static const int cooldownDays = 90;
  static const int maxPromptsLifetime = 3;

  static final InAppReview _review = InAppReview.instance;

  static bool shouldPrompt() {
    if (SharedPrefHelper.getReviewRated()) return false;
    if (SharedPrefHelper.getReviewDontAsk()) return false;
    if (SharedPrefHelper.getReviewPromptCount() >= maxPromptsLifetime) {
      return false;
    }
    if (SharedPrefHelper.getTotalMalas() < minLifetimeMalas) return false;

    final installedMs = SharedPrefHelper.getInstallDateMs();
    final daysInstalled =
        DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(installedMs),
        ).inDays;
    if (daysInstalled < minDaysInstalled) return false;

    final last = SharedPrefHelper.getReviewLastPromptMs();
    if (last != null) {
      final daysSince =
          DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(last),
          ).inDays;
      if (daysSince < cooldownDays) return false;
    }
    return true;
  }

  /// Requests the native review flow if eligible. Records count + timestamp
  /// whenever a request is actually sent, since Play quota counts attempts.
  static Future<void> promptIfEligible() async {
    if (!shouldPrompt()) return;
    try {
      if (!await _review.isAvailable()) return;
      SharedPrefHelper.setReviewPromptCount(
        SharedPrefHelper.getReviewPromptCount() + 1,
      );
      SharedPrefHelper.setReviewLastPromptMs(
        DateTime.now().millisecondsSinceEpoch,
      );
      await _review.requestReview();
    } catch (e) {
      debugPrint('Rate prompt failed: $e');
    }
  }

  /// Manual "Rate Maala" entry point (e.g. Settings). Opens the Play listing.
  /// Marks the user as asked so the auto-prompt backs off.
  static Future<void> openStoreListing() async {
    try {
      SharedPrefHelper.setReviewPromptCount(
        SharedPrefHelper.getReviewPromptCount() + 1,
      );
      SharedPrefHelper.setReviewLastPromptMs(
        DateTime.now().millisecondsSinceEpoch,
      );
      await _review.openStoreListing();
    } catch (e) {
      debugPrint('Open store listing failed: $e');
    }
  }
}
