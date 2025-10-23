import 'package:flutter/material.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/data/theme.dart';
import 'package:smeta_maker/ui/views/row_page.dart';

class AddButtonWidget extends StatelessWidget {
  AddButtonWidget({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      InkWell(
        autofocus: true,
        borderRadius: BorderRadius.circular(50),
        onTap: () => AppRouter.push(RowPage()),
        child: CircleAvatar(
          radius: 21,
          backgroundColor: AppColors.secondButton,
          child: Icon(Icons.add, color: AppColors.text),
        ),
      ),
    ],
  );
}
