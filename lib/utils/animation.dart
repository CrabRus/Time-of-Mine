import 'package:flutter/material.dart';

Future<T?> pushAnimatedScale<T>(
  BuildContext context,
  WidgetBuilder builder, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  return Navigator.push<T>(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.ease,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: child,
        );
      },
    ),
  );
}
