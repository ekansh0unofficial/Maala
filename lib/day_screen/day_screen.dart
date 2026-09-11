import 'package:flutter/material.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/shared_pref_helper.dart';
import 'package:maala_app/services/theme_service.dart';
import 'package:maala_app/theme/app_text_styles.dart';
import 'package:maala_app/theme/app_theme.dart';
import 'package:maala_app/themes/meditation_themes.dart';
import 'package:maala_app/widgets/adaptive_banner_ad.dart';

class DayScreen extends StatefulWidget {
  const DayScreen({super.key});

  @override
  State<DayScreen> createState() => DayScreenState();
}

class DayScreenState extends State<DayScreen> {
  int _streak = 0;
  int _bestStreak = 0;
  int _todayMalas = 0;
  int _totalMalas = 0;
  int _totalChants = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Read-only at startup; setState would be a no-op before first build.
  void _loadData() {
    _streak = SharedPrefHelper.getStreak();
    _bestStreak = SharedPrefHelper.getBestStreak();
    // Bug fix: this used to read "session" malas, which get wiped by the
    // reset button on the counter screen. That made "Today" silently
    // drop to 0 even after real progress earlier the same day. Now reads
    // a date-scoped counter that only rolls over at midnight.
    _todayMalas = SharedPrefHelper.getTodayMalas();
    _totalMalas = SharedPrefHelper.getTotalMalas();
    _totalChants = SharedPrefHelper.getTotalChants();
  }

  /// Refreshes stats from disk. Called when the Day tab is selected so
  /// the counters reflect any progress made on other tabs.
  void refresh() {
    _loadData();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.current;
    return Container(
      color: theme.background,
      child: SafeArea(
        // Scrollable so the stats + mantra + banner never overflow on short
        // landscape viewports. IntrinsicHeight keeps the Spacer pinning the
        // mantra section and banner to the bottom whenever there's room.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.translate('day'),
                        style: AppTextStyles.cormorantHeadline.copyWith(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.translate('streak'),
                        style: AppTextStyles.interXs.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildStreakCard(theme),
                      const SizedBox(height: 20),

                      _buildStatRow(
                        label: AppLocalizations.translate('today'),
                        value: '$_todayMalas mala${_todayMalas != 1 ? 's' : ''}',
                        icon: Icons.self_improvement,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        label: 'Total malas',
                        value: '$_totalMalas',
                        icon: Icons.auto_stories,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        label: 'Total chants',
                        value:
                            _totalChants > 0 ? _totalChants.toString() : '-',
                        icon: Icons.record_voice_over,
                        theme: theme,
                      ),

                      const Spacer(),

                      _buildMantraSection(theme),
                      const SizedBox(height: 20),
                      AdaptiveBannerAd(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(MeditationTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryAccent.withValues(alpha: 0.25),
            theme.primaryAccent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(
          color: theme.primaryAccent.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: theme.primaryAccent,
            size: 52,
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_streak ${_streak == 1 ? AppLocalizations.translate('dayLabel') : AppLocalizations.translate('daysLabel')} ${AppLocalizations.translate('streak')}',
                style: AppTextStyles.cormorantTitle.copyWith(
                  color: theme.primaryAccent,
                ),
              ),
              if (_bestStreak > 0)
                Text(
                  'Best: $_bestStreak days',
                  style: AppTextStyles.interBody,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required IconData icon,
    required MeditationTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryAccent, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.interBodyLg,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.interTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildMantraSection(MeditationTheme theme) {
    final currentMantra = SharedPrefHelper.getMantraText();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.translate('mantra'),
          style: AppTextStyles.interCaptionMedium.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(color: theme.border),
          ),
          child: Text(
            currentMantra,
            textAlign: TextAlign.center,
            style: AppTextStyles.interMantra.copyWith(
              fontSize: 22,
              color: theme.primaryAccent,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}