// Flutter imports:
import 'package:flutter/material.dart';

/// Utility class for navigation operations
class NavigationUtils {
  /// Pushes a new page onto the navigation stack
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Pushes a new page and replaces the current one
  static Future<T?> pushReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Pushes a new page and removes all previous pages
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  /// Pops the current page from the navigation stack
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  /// Checks if the navigation stack can pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Pops pages until finding one with the specified route name
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Pushes a new page with a fade transition
  static Future<T?> pushWithFade<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Pushes a new page with a slide transition
  static Future<T?> pushWithSlide<T>(
    BuildContext context,
    Widget page, {
    AxisDirection direction = AxisDirection.left,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Offset begin;
          switch (direction) {
            case AxisDirection.up:
              begin = const Offset(0, 1);
              break;
            case AxisDirection.down:
              begin = const Offset(0, -1);
              break;
            case AxisDirection.right:
              begin = const Offset(-1, 0);
              break;
            case AxisDirection.left:
              begin = const Offset(1, 0);
              break;
          }

          return SlideTransition(
            position: Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}
