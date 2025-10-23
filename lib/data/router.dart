import 'package:flutter/material.dart';
import 'package:smeta_maker/main.dart';

class _CustomPageRoute extends PageRouteBuilder {
  _CustomPageRoute(Widget child)
    : super(
        transitionDuration: Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
      );
}

abstract class AppRouter {
  static BuildContext _getContext() =>
      navigatorKey.currentState!.overlay!.context;

  static Future pushReplacement(Widget child) =>
      Navigator.pushReplacement(_getContext(), _CustomPageRoute(child));

  static Future push(Widget child) =>
      Navigator.push(_getContext(), _CustomPageRoute(child));

  static void pop() => Navigator.pop(_getContext());

  static void pageAnimation(
    void Function({required Duration duration, required Curve curve}) action,
  ) => action(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOutQuad,
  );
}
