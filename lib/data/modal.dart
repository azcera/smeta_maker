import 'package:flutter/material.dart';
import 'package:smeta_maker/main.dart';

mixin Modal on Widget {
  Future<void> show({BuildContext? context}) async {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;
    await showDialog(context: context ?? ctx, builder: (context) => this);
  }
}
