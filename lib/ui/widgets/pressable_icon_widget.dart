import 'package:flutter/material.dart';
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
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      enableFeedback: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: AppColors.text),
        ),
      ),
    ),
  );
}
