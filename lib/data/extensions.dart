import 'package:intl/intl.dart';

extension DoubleExtension on double {
  String toPrice() {
    List<String> parts = toString().split('.');

    String integerPart = parts[0],
        formattedInt = NumberFormat(
          '#,###',
          'ru_RU',
        ).format(int.parse(integerPart)).replaceAll(',', ' ');

    if (this % 1 == 0) {
      return formattedInt;
    } else {
      return '$formattedInt.${parts[1]}';
    }
  }

  String cleanDouble() {
    if (this % 1 == 0) {
      return toInt().toString();
    } else {
      return toString();
    }
  }
}
