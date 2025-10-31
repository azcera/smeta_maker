import 'package:flutter/material.dart';
import 'package:smeta_maker/data/app_constants.dart';

class TagWidget extends StatelessWidget {
  const TagWidget({required this.color, required this.text, super.key});
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: AppBorderRadius.all,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
