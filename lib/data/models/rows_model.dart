import 'package:flutter/widgets.dart';
import 'package:smeta_maker/data/theme.dart';

enum Category {
  complex('комплекс', AppColors.complex),
  quadMeters('м²', AppColors.quadMeters),
  sht('шт', AppColors.sht),
  cubeMeters('м³', AppColors.cubeMeters),
  meters('м/п', AppColors.meters);

  final String name;
  final Color color;
  const Category(this.name, this.color);

  static Category getCategoryFromName(String? name) {
    return Category.values.firstWhere(
      (e) => e.name == name,
      orElse: () => Category.cubeMeters,
    );
  }
}

class RowsModel {
  final String name;
  final double price;
  final Category category;
  final double count;

  double get calcPrice => count * price;
  const RowsModel({
    required this.name,
    required this.category,
    required this.count,
    required this.price,
  });

  static RowsModel start(Category lastCategory) =>
      RowsModel(name: '', category: lastCategory, count: 1, price: 0);

  static RowsModel blank({
    required String name,
    required Category category,
    required double price,
  }) => RowsModel(name: name, category: category, count: 1, price: price);

  RowsModel copyWith({
    String? name,
    Category? category,
    double? count,
    double? price,
  }) {
    return RowsModel(
      name: name ?? this.name,
      category: category ?? this.category,
      count: count ?? this.count,
      price: price ?? this.price,
    );
  }

  List<dynamic> toExcelRow(int index) {
    return [index, name, category.name, count, price, calcPrice];
  }
}
