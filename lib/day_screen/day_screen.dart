import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/shared_pref_helper.dart';
import 'package:maala_app/services/theme_service.dart';
import 'package:maala_app/theme/app_theme.dart';
import 'package:maala_app/themes/meditation_themes.dart';

class DayScreen extends StatefulWidget {
  const DayScreen({super.key});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
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

  void _loadData() {
    setState(() {
      _streak = SharedPrefHelper.getStreak();
      _bestStreak = SharedPrefHelper.getBestStreak();
      // Bug fix: this used to read "session" malas, which get wiped by the
      // reset button on the counter screen. That made "Today" silently
      // drop to 0 even after real progress earlier the same day. Now reads
      // a date-scoped counter that only rolls over at midnight.
      _todayMalas = SharedPrefHelper.getTodayMalas();
      _totalMalas = SharedPrefHelper.getTotalMalas();
      _totalChants = SharedPrefHelper.getTotalChants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.current;
    return Container(
      color: theme.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.translate('day'),
                style: GoogleFonts.cormorantGaramond(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.translate('streak'),
                style: GoogleFonts.inter(
                  color: AppColors.textTertiary,
                  fontSize: 12,
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
                value: _totalChants > 0 ? _totalChants.toString() : '-',
                icon: Icons.record_voice_over,
                theme: theme,
              ),

              const Spacer(),

              _buildMantraSection(theme),
            ],
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
                style: GoogleFonts.cormorantGaramond(
                  color: theme.primaryAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_bestStreak > 0)
                Text(
                  'Best: $_bestStreak days',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
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
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
          style: GoogleFonts.inter(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
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
            style: GoogleFonts.inter(
              color: theme.primaryAccent,
              fontSize: 22,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}
