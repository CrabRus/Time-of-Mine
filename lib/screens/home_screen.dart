import 'package:flutter/material.dart';
import 'package:time_of_mine/screens/main_screens/calendar/calendar_screen.dart';
import 'package:time_of_mine/screens/main_screens/profile/profile_screen.dart';
import 'package:time_of_mine/screens/main_screens/search_screen.dart';
import 'package:time_of_mine/screens/main_screens/tasks/tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool notificationsEnabled;
  final bool showHolidays;
  final Function(bool) setNotifications;
  final Function(bool) setShowHolidays;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.notificationsEnabled,
    required this.showHolidays,
    required this.setNotifications,
    required this.setShowHolidays,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  late bool _notificationsEnabled;
  late bool _showHolidays;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.notificationsEnabled;
    _showHolidays = widget.showHolidays;
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SearchScreen(),
          CalendarScreen(showHolidays: _showHolidays),
          const TasksScreen(),
          ProfileScreen(
            toggleTheme: widget.toggleTheme,
            notificationsEnabled: _notificationsEnabled,
            showHolidays: _showHolidays,
            setNotifications: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              widget.setNotifications(value);
            },
            setShowHolidays: (value) {
              setState(() {
                _showHolidays = value;
              });
              widget.setShowHolidays(value);
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.search,
                  label: 'Search',
                  selected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                _NavBarItem(
                  icon: Icons.calendar_today,
                  label: 'Calendar',
                  selected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                _NavBarItem(
                  icon: Icons.check_box,
                  label: 'Tasks',
                  selected: _selectedIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),
                _NavBarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: _selectedIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : Colors.grey;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
