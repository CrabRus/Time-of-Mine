import 'package:flutter/material.dart';

class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const SimpleAppBar({super.key, required this.title});
  @override
  Size get preferredSize => const Size.fromHeight(40);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      surfaceTintColor: theme.scaffoldBackgroundColor,
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Padding(
        padding: EdgeInsetsGeometry.only(top: 0),
        child: Text(title, style: theme.textTheme.titleMedium),
      ),
      centerTitle: true,
    );
  }
}
