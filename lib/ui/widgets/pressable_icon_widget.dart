import 'package:flutter/material.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/theme.dart';

class PressableIconWidget extends StatelessWidget {
  const PressableIconWidget(this.icon, {
    required this.onTap,
    super.key});
  final IconData icon;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: AppBorderRadius.all,
    child: InkWell(
      borderRadius: AppBorderRadius.all,
      onTap: onTap,
      enableFeedback: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(borderRadius: AppBorderRadius.all),
          child: Icon(icon, color: AppColors.text),
        ),
      ),
    ),
  );
}
