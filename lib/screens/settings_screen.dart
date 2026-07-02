import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // User preferences (in production, persist with SharedPreferences)
  bool _notificationsEnabled = true;
  bool _doorAlerts = true;
  bool _expiryReminders = true;
  bool _weeklyReport = false;
  String _selectedTheme = 'System';
  String _temperatureUnit = 'Celsius (°C)';

  final List<String> _themes = ['Light', 'Dark', 'System'];
  final List<String> _tempUnits = ['Celsius (°C)', 'Fahrenheit (°F)'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── NOTIFICATIONS ───────────────────────────────────
          _buildSectionHeader('🔔 ${l.notifications}'),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    l.enableNotifications,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  subtitle: const Text('Get updates about your fridge'),
                  secondary: const Icon(Icons.notifications_active_outlined,
                      color: AppTheme.primaryGreen),
                  value: _notificationsEnabled,
                  activeTrackColor: AppTheme.primaryGreen,
                  onChanged: (val) =>
                      setState(() => _notificationsEnabled = val),
                ),
                if (_notificationsEnabled) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text(l.doorAlerts,
                      style: const TextStyle(fontSize: 15)),
                    subtitle: const Text('Alert when door is left open too long'),
                    value: _doorAlerts,
                    activeTrackColor: AppTheme.primaryGreen,
                    onChanged: (val) => setState(() => _doorAlerts = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text(l.expiryReminders,
                      style: const TextStyle(fontSize: 15)),
                    subtitle: const Text('Remind me before food expires'),
                    value: _expiryReminders,
                    activeTrackColor: AppTheme.primaryGreen,
                    onChanged: (val) =>
                        setState(() => _expiryReminders = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text(l.weeklySummary,
                      style: const TextStyle(fontSize: 15)),
                    subtitle: const Text('Get a weekly report of food usage'),
                    value: _weeklyReport,
                    activeTrackColor: AppTheme.primaryGreen,
                    onChanged: (val) =>
                        setState(() => _weeklyReport = val),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ─── LANGUAGE (real switching) ──────────────────────
          _buildSectionHeader('🌐 ${l.language}'),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.appLanguage,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(l.chooseLanguage,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  ...LocaleProvider.supportedLanguages.map((lang) =>
                    RadioListTile<Locale>(
                      title: Text(
                        '${lang.nativeName} (${lang.name})',
                        style: const TextStyle(fontSize: 15),
                      ),
                      value: lang.locale,
                      groupValue: localeProvider.locale,
                      activeColor: AppTheme.primaryGreen,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (val != null) {
                          localeProvider.setLocale(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ─── APPEARANCE ────────────────────────────────────
          _buildSectionHeader('🎨 ${l.appearance}'),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.theme,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  const SizedBox(height: 12),
                  Row(
                    children: _themes
                        .map((theme) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: _buildThemeOption(theme),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ─── UNITS ─────────────────────────────────────────
          _buildSectionHeader('📏 ${l.units}'),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.temperatureUnit,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  const SizedBox(height: 12),
                  ..._tempUnits.map((unit) => RadioListTile<String>(
                        title: Text(unit, style: const TextStyle(fontSize: 15)),
                        value: unit,
                        groupValue: _temperatureUnit,
                        activeColor: AppTheme.primaryGreen,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) =>
                            setState(() => _temperatureUnit = val!),
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ─── ABOUT ─────────────────────────────────────────
          _buildSectionHeader('ℹ️ ${l.about}'),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppTheme.primaryGreen),
                  title: Text(l.appVersion,
                      style: const TextStyle(fontSize: 15)),
                  trailing: const Text(
                    'v1.0.0',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.help_outline,
                      color: AppTheme.infoBlue),
                  title: Text(l.helpSupport,
                      style: const TextStyle(fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Help center coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: AppTheme.accentOrange),
                  title: Text(l.privacyPolicy,
                      style: const TextStyle(fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Privacy policy coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildThemeOption(String theme) {
    final isSelected = _selectedTheme == theme;
    IconData icon;
    switch (theme) {
      case 'Light':
        icon = Icons.light_mode;
        break;
      case 'Dark':
        icon = Icons.dark_mode;
        break;
      default:
        icon = Icons.phone_android;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = theme),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGreen
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryGreen
                  : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              theme,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
