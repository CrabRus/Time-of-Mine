import 'package:flutter/material.dart';
import 'package:time_of_mine/screens/main_screens/profile/cloud_screen.dart';
import 'package:time_of_mine/screens/main_screens/profile/edit_profile_screen.dart';
import 'package:time_of_mine/screens/main_screens/profile/settings_screen.dart';
import 'package:time_of_mine/services/auth_service.dart';
import 'package:time_of_mine/utils/animation.dart';
import 'package:time_of_mine/widgets/custom_app_bar.dart';
import 'package:time_of_mine/widgets/custom_snack_bar.dart';
import 'package:time_of_mine/widgets/rounded_container.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const ProfileScreen({super.key, required this.toggleTheme, required bool notificationsEnabled, required bool showHolidays, required Null Function(dynamic value) setNotifications, required Null Function(dynamic value) setShowHolidays});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  String? _userEmail;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = AuthService.currentUser;
    if (user != null) {
      setState(() {
        _isGuest = user.isAnonymous;
        _userName = user.displayName;
        _userEmail = user.email;
      });
    }
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await AuthService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: "Profile"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Icon(Icons.person, size: 80, color: theme.iconTheme.color),

              const SizedBox(height: 12),
              Text(
                _isGuest ? "Guest" : (_userName ?? "No name"),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              if (!_isGuest && _userEmail != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _userEmail!,
                    style: TextStyle(color: theme.primaryColor, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),

              _buildMenuItem(
                theme: theme,
                icon: Icons.edit,
                text: "Edit Profile",
                onTap: () async {
                  if (!_isGuest) {
                    await pushAnimatedScale(
                      context,
                      (context) => EditProfileScreen(),
                    );
                    _loadProfile();
                  } else {
                    CustomSnackBar.show(
                      context,
                      message: "You can`t do it. You are guest",
                      isError: true,
                    );
                  }
                },
              ),
              const SizedBox(height: 4),
              _buildMenuItem(
                theme: theme,
                icon: Icons.settings,
                text: "Settings",
                onTap: () async {
                  await pushAnimatedScale(
                    context,
                    (context) =>
                        SettingsScreen(toggleTheme: widget.toggleTheme),
                  );
                },
              ),
              const SizedBox(height: 4),
              _buildMenuItem(
                theme: theme,
                icon: Icons.cloud,
                text: "Cloud",
                onTap: () async {
                  if (!_isGuest) {
                    await pushAnimatedScale(
                      context,
                      (context) => CloudScreen(),
                    );
                    _loadProfile();
                  } else {
                    CustomSnackBar.show(
                      context,
                      message: "You can`t do it. You are guest",
                      isError: true,
                    );
                  }
                },
              ),
              const SizedBox(height: 4),
              _buildMenuItem(
                theme: theme,
                icon: Icons.logout,
                text: "Sign Out",
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: _confirmSignOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required ThemeData theme,
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return RoundedContainer(
      color: theme.cardColor,
      child: ListTile(
        minTileHeight: 16,
        leading: Icon(icon, color: iconColor ?? theme.iconTheme.color),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? theme.textTheme.bodyMedium!.color,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
