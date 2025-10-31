import 'package:flutter/material.dart';
import 'package:smeta_maker/data/app_constants.dart';

class SettingsElement extends StatelessWidget {
  const SettingsElement({required this.child, required this.title, super.key});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: Text(title)),
        SizedBox(height: AppConstants.spacing),
        child,
        SizedBox(height: 35),
      ],
    );
  }
}
