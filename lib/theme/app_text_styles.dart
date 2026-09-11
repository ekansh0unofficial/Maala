import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Centralized text styles.
///
/// The app's fonts are bundled as real weight files in `assets/fonts/`, so
/// these are plain [TextStyle] constants referencing the families directly.
/// This avoids per-build font-resolution work in `google_fonts` on the hot
/// rebuild paths (e.g. the counter screen rebuilds its whole tree every tap).
abstract final class AppTextStyles {
  static const String _inter = 'Inter';
  static const String _montserrat = 'Montserrat';
  static const String _cormorant = 'CormorantGaramond';

  // ---- Inter ----

  /// Small caption / tertiary label (11pt, bold, tracked out).
  static const TextStyle interCaption = TextStyle(
    fontFamily: _inter,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: AppColors.textTertiary,
  );

  /// Small secondary text (12pt).
  static const TextStyle interXs = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  /// Small secondary text (12pt, medium weight).
  static const TextStyle interXsMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Quote / tertiary paragraph (13pt, italic, secondary).
  static const TextStyle interQuote = TextStyle(
    fontFamily: _inter,
    fontSize: 13,
    fontStyle: FontStyle.italic,
    height: 1.5,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  /// Body secondary, 13pt.
  static const TextStyle interBody = TextStyle(
    fontFamily: _inter,
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  /// Body secondary, 13pt, medium weight.
  static const TextStyle interBodyMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// 14pt secondary text.
  static const TextStyle interSub = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  /// 14pt primary text.
  static const TextStyle interSubRegular = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  /// 14pt primary text, medium weight.
  static const TextStyle interSubMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// 14pt tertiary text (input hint).
  static const TextStyle interHint = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    color: AppColors.textTertiary,
  );

  /// 14pt primary text, semi-bold.
  static const TextStyle interSubSemiBold = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 15pt secondary text.
  static const TextStyle interBodyLg = TextStyle(
    fontFamily: _inter,
    fontSize: 15,
    color: AppColors.textSecondary,
  );

  /// 13pt primary text, semi-bold.
  static const TextStyle interBodySemiBold = TextStyle(
    fontFamily: _inter,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 15pt primary text, semi-bold.
  static const TextStyle interBodyLgSemiBold = TextStyle(
    fontFamily: _inter,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 16pt primary text, semi-bold.
  static const TextStyle interTitle = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 16pt primary text.
  static const TextStyle interTitleRegular = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  /// 17pt primary text, semi-bold.
  static const TextStyle interHeading = TextStyle(
    fontFamily: _inter,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 18pt primary text.
  static const TextStyle interLabelLg = TextStyle(
    fontFamily: _inter,
    fontSize: 18,
    color: AppColors.textPrimary,
  );

  /// 20pt primary text.
  static const TextStyle interMantra = TextStyle(
    fontFamily: _inter,
    fontSize: 20,
    color: AppColors.textPrimary,
  );

  /// 12pt secondary caption, medium weight, tracked.
  static const TextStyle interCaptionMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
    color: AppColors.textSecondary,
  );

  /// 12pt secondary caption, medium weight, softly tracked.
  static const TextStyle interCaptionSoft = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  /// 14pt secondary caption, medium weight, tracked.
  static const TextStyle interTitleMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
    color: AppColors.textSecondary,
  );

  /// 11pt tertiary nav label.
  static const TextStyle interNav = TextStyle(
    fontFamily: _inter,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );

  // ---- Montserrat ----

  /// Large countdown / counter digits (semi-bold).
  static const TextStyle montserratDisplay = TextStyle(
    fontFamily: _montserrat,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ---- Cormorant Garamond ----

  /// App bar title (26pt, semi-bold).
  static const TextStyle cormorantTitle = TextStyle(
    fontFamily: _cormorant,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Modal / dialog heading (22pt, semi-bold).
  static const TextStyle cormorantDialogTitle = TextStyle(
    fontFamily: _cormorant,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Modal / dialog heading (24pt, semi-bold).
  static const TextStyle cormorantDialogHeading = TextStyle(
    fontFamily: _cormorant,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Large headline (30pt, semi-bold).
  static const TextStyle cormorantHeadline = TextStyle(
    fontFamily: _cormorant,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Big emphasis number (44pt, semi-bold).
  static const TextStyle cormorantHuge = TextStyle(
    fontFamily: _cormorant,
    fontSize: 44,
    fontWeight: FontWeight.w600,
  );
}
