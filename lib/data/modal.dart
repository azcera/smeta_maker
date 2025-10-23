import 'package:flutter/material.dart';
import 'package:smeta_maker/main.dart';

mixin Modal on Widget {
  Future<void> show() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    await showDialog(context: context, builder: (context) => this);
  }
}
