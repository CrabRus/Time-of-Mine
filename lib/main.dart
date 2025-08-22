import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_of_mine/firebase_options.dart';
import 'package:time_of_mine/screens/auth_screen.dart';
import 'package:time_of_mine/screens/home_screen.dart';
import 'package:time_of_mine/services/auth_service.dart';
import 'package:time_of_mine/services/noti_service.dart';
import 'config/theme.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  NotiService().initNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Загружаем сохранённые настройки
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
  final showHolidays = prefs.getBool('showHolidays') ?? true;

  runApp(MainApp(
    isDarkMode: isDarkMode,
    notificationsEnabled: notificationsEnabled,
    showHolidays: showHolidays,
  ));
}

class MainApp extends StatefulWidget {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool showHolidays;

  const MainApp({
    super.key,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.showHolidays,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late ThemeMode _themeMode;
  late bool _notificationsEnabled;
  late bool _showHolidays;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _notificationsEnabled = widget.notificationsEnabled;
    _showHolidays = widget.showHolidays;
  }

  void _toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _themeMode == ThemeMode.dark);
  }

  void _setNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);
  }

  void _setShowHolidays(bool value) async {
    setState(() {
      _showHolidays = value;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showHolidays', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: AuthWrapper(
        toggleTheme: _toggleTheme,
        notificationsEnabled: _notificationsEnabled,
        showHolidays: _showHolidays,
        setNotifications: _setNotifications,
        setShowHolidays: _setShowHolidays,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool notificationsEnabled;
  final bool showHolidays;
  final Function(bool) setNotifications;
  final Function(bool) setShowHolidays;

  const AuthWrapper({
    super.key,
    required this.toggleTheme,
    required this.notificationsEnabled,
    required this.showHolidays,
    required this.setNotifications,
    required this.setShowHolidays,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen(
            toggleTheme: toggleTheme,
            notificationsEnabled: notificationsEnabled,
            showHolidays: showHolidays,
            setNotifications: setNotifications,
            setShowHolidays: setShowHolidays,
          );
        } else {
          return AuthScreen();
        }
      },
    );
  }
}
