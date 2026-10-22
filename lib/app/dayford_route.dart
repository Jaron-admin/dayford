import 'package:flutter/material.dart';

/// 260ms fade plus a 14px rise. Reduced motion skips the transition.
class DayfordPageRoute<T> extends PageRouteBuilder<T> {
  DayfordPageRoute({required WidgetBuilder builder})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          final curved = animation.drive(
            CurveTween(curve: const Cubic(0.2, 0.7, 0.3, 1)),
          );
          return FadeTransition(
            opacity: curved,
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 14 * (1 - curved.value)),
                  child: child,
                );
              },
              child: child,
            ),
          );
        },
      );
}
