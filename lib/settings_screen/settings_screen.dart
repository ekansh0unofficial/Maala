import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/screen_awake_service.dart';
import 'package:maala_app/settings_screen/image_picker.dart';
import 'package:maala_app/settings_screen/sound_picker.dart';
import 'package:maala_app/theme/app_theme.dart';
import 'package:maala_app/themes/meditation_themes.dart';
import '../services/shared_pref_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticEnabled = SharedPrefHelper.getHapticEnabled();
  bool _keepScreenOn = SharedPrefHelper.getKeepScreenOn();
  bool _focusMode = SharedPrefHelper.getFocusMode();
  late TextEditingController _countLimitController;
  int _themeIndex = SharedPrefHelper.getThemeIndex();

  @override
  void initState() {
    super.initState();
    final countLimit = SharedPrefHelper.getCountLimit() ?? 108;
    _countLimitController = TextEditingController(text: countLimit.toString());
  }

  @override
  void dispose() {
    _countLimitController.dispose();
    super.dispose();
  }

  MeditationTheme get _theme => meditationThemes[_themeIndex];

  void _saveCountLimit(String value) {
    final trimmed = value.trim();
    final parsed = int.tryParse(trimmed);

    if (parsed != null && parsed >= 1 && parsed <= 9999) {
      SharedPrefHelper.setCountLimit(parsed);
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _theme.surfaceElevated,
          content: Text(
            '${AppLocalizations.translate('countLimitSet')} $parsed',
            style: GoogleFonts.inter(color: AppColors.textPrimary),
          ),
        ),
      );
    } else {
      final fallback = SharedPrefHelper.getCountLimit() ?? 108;
      _countLimitController.text = fallback.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _theme.surfaceElevated,
          content: Text(
            AppLocalizations.translate('enterCountLimit'),
            style: GoogleFonts.inter(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _theme.surface,
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
                  AppLocalizations.translate('chooseLanguage'),
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageOption('English', 'en'),
                _buildLanguageOption('हिन्दी', 'hi'),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Widget _buildLanguageOption(String label, String code) {
    final isSelected = AppLocalizations.currentLang == code;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? _theme.primaryAccent.withValues(alpha: 0.18)
                : _theme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: ListTile(
        title: Text(
          label,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18),
        ),
        trailing:
            isSelected
                ? Icon(Icons.check_circle, color: _theme.primaryAccent)
                : null,
        onTap: () {
          AppLocalizations.setLanguage(code);
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _theme.surface,
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
                  AppLocalizations.translate('chooseTheme'),
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: List.generate(meditationThemes.length, (index) {
                      final theme = meditationThemes[index];
                      final isSelected = _themeIndex == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? theme.primaryAccent.withValues(alpha: 0.18)
                                  : theme.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadii.medium),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.primaryAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            theme.name,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            theme.greeting,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? Icon(
                                    Icons.check_circle,
                                    color: theme.primaryAccent,
                                  )
                                  : null,
                          onTap: () {
                            setState(() => _themeIndex = index);
                            SharedPrefHelper.setThemeIndex(index);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _theme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.translate('settings'),
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        automaticallyImplyLeading: false,
      ),
      body: Listener(
        onPointerDown: (_) => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionLabel('PRACTICE'),
            const SizedBox(height: 8),
            _buildToggleTile(
              title: AppLocalizations.translate('enableHaptic'),
              value: _hapticEnabled,
              onChanged: (val) {
                setState(() => _hapticEnabled = val);
                SharedPrefHelper.setHapticEnabled(val);
              },
            ),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: AppLocalizations.translate('keepScreenOn'),
              value: _keepScreenOn,
              onChanged: (val) async {
                setState(() => _keepScreenOn = val);
                SharedPrefHelper.setKeepScreenOn(val);
                val
                    ? await ScreenAwakeService.enable()
                    : await ScreenAwakeService.disable();
              },
            ),
            const SizedBox(height: 12),
            _buildToggleTile(
              title: AppLocalizations.translate('focusMode'),
              subtitle: AppLocalizations.translate('focusModeSub'),
              value: _focusMode,
              onChanged: (val) {
                setState(() => _focusMode = val);
                SharedPrefHelper.setFocusMode(val);
              },
            ),

            const SizedBox(height: 24),
            _sectionLabel('APPEARANCE'),
            const SizedBox(height: 8),
            _buildNavTile(
              title: AppLocalizations.translate('language'),
              icon: Icons.language,
              value: AppLocalizations.isHindi ? 'हिन्दी' : 'English',
              onTap: _showLanguagePicker,
            ),
            const SizedBox(height: 12),
            _buildNavTile(
              title: AppLocalizations.translate('theme'),
              icon: Icons.palette,
              value: _theme.name,
              onTap: _showThemePicker,
            ),
            const SizedBox(height: 12),
            _buildNavTile(
              title: AppLocalizations.translate('backgroundImage'),
              icon: Icons.photo_outlined,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const BackgroundPickerDialog(),
                ).then((_) => setState(() {}));
              },
            ),
            const SizedBox(height: 12),
            _buildNavTile(
              title: AppLocalizations.translate('soundtrack'),
              icon: Icons.music_note_outlined,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const SoundPickerDialog(),
                ).then((_) => setState(() {}));
              },
            ),

            const SizedBox(height: 24),
            _sectionLabel('COUNTER'),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                AppLocalizations.translate('counterLimit'),
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                AppLocalizations.translate('counterLimitSub'),
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              tileColor: _theme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.medium),
                side: BorderSide(color: _theme.border),
              ),
              trailing: SizedBox(
                width: 70,
                child: TextField(
                  controller: _countLimitController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                    filled: true,
                    fillColor: _theme.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.small),
                      borderSide: BorderSide(color: _theme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.small),
                      borderSide: BorderSide(color: _theme.primaryAccent),
                    ),
                  ),
                  onSubmitted: _saveCountLimit,
                  onEditingComplete:
                      () => _saveCountLimit(_countLimitController.text),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: AppColors.textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: _theme.border),
      ),
      child: SwitchListTile.adaptive(
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
                : null,
        value: value,
        onChanged: onChanged,
        activeThumbColor: _theme.primaryAccent,
        activeTrackColor: _theme.primaryAccent.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required IconData icon,
    String? value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: _theme.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: _theme.primaryAccent),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(
                value,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
