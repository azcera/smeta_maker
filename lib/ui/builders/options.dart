import 'package:flutter/material.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/theme.dart';

abstract class Options {
  static Widget optionsViewBuilder<T>(
    BuildContext context,
    void Function(T) onSelected,
    Iterable<T> options,
  ) => Align(
    alignment: Alignment.topLeft,
    child: Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        constraints: BoxConstraints(maxHeight: 300),
        child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options.elementAt(index);
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onSelected(option),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: AppConstants.defaultPadding,
                ),
                child: Text(
                  option.toString(),
                  style: TextStyle(fontSize: 18, color: AppColors.mainButton),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
