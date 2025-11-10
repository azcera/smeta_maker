import 'package:flutter/material.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/theme.dart';

class PressableIconWidget extends StatelessWidget {
  const PressableIconWidget(this.icon, {required this.onTap, super.key});
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
      child: SizedBox(
        width: MediaQuery.of(context).size.width < 300
            ? MediaQuery.of(context).size.width / 6
            : 44,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(borderRadius: AppBorderRadius.all),
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: AppColors.text),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
