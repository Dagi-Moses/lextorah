import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AniProps { opacity, translateY }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final tween =
        MovieTween()
          ..tween(
            AniProps.opacity,
            Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
          )
          ..tween(
            AniProps.translateY,
            Tween(begin: -30.0, end: 0.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      delay: Duration(milliseconds: (500 * delay).round()),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              -30 * (1 - value),
            ), // Animating from -30 to 0 based on opacity
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
