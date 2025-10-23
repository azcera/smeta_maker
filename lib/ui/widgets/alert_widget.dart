import 'package:flutter/material.dart';
import 'package:smeta_maker/data/modal.dart';
import 'package:smeta_maker/data/router.dart';

class AlertWidget extends StatelessWidget with Modal {
  const AlertWidget({
    required this.onTap,
    required this.title,
    required this.content,
    required this.buttons,
    super.key,
  });
  final void Function() onTap;
  final String title;
  final String content;
  final List<FilledButton> buttons;
  void tapFunction() {
    onTap();
    AppRouter.pop();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title, textAlign: TextAlign.center),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,

      children: [
        Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 30),
        Row(spacing: 10, children: [...buttons.map((e) => Expanded(child: e))]),
      ],
    ),
  );
}
