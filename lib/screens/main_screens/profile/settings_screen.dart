import 'package:flutter/material.dart';
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:time_of_mine/widgets/simple_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SettingsScreen({super.key, required this.toggleTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool showHolidays = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dark = await LocalStorageService.getDarkMode();
    final notif = await LocalStorageService.getNotificationsEnabled();
    final holidays = await LocalStorageService.getShowHolidays();

    setState(() {
      isDarkMode = dark;
      notificationsEnabled = notif;
      showHolidays = holidays;
    });
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: "Settings"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingTile(
              icon: Icons.dark_mode,
              title: "Dark Theme",
              description: "Switch between light and dark mode.",
              value: isDarkMode,
              onChanged: (val) async {
                setState(() => isDarkMode = val);
                await LocalStorageService.setDarkMode(val);
                widget.toggleTheme();
              },
            ),
            _buildSettingTile(
              icon: Icons.notifications,
              title: "Notifications",
              description: "Enable or disable app notifications.",
              value: notificationsEnabled,
              onChanged: (val) async {
                setState(() => notificationsEnabled = val);
                await LocalStorageService.setNotificationsEnabled(val);
              },
            ),
            _buildSettingTile(
              icon: Icons.calendar_today,
              title: "Calendar Holidays",
              description: "Show or hide holidays in the calendar.",
              value: showHolidays,
              onChanged: (val) async {
                setState(() => showHolidays = val);
                await LocalStorageService.setShowHolidays(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
