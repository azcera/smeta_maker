import 'dart:convert';

import 'package:smeta_maker/data/models/rows_model.dart';

abstract class WorksParser {
  static List<RowsModel> parse(String file) {
    final List<RowsModel> result = [];
    final List<String> lines = const LineSplitter().convert(file);

    for (var line in lines) {
      if (!line.contains('|')) continue;
      final splitted = line.split('|').map((e) => e.trim()).toList();
      if (splitted.length != 3) continue;

      result.add(
        RowsModel.blank(
          name: splitted.first,
          category: Category.getCategoryFromName(splitted.last),
          price: double.parse(splitted[1]),
        ),
      );
    }
    return result;
  }
}
