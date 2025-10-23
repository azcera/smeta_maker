import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/service/project_manager.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class SaveIntent extends Intent {
  void save(List<RowsModel> rows, String fileName) =>
      ExcelService.saveAsFile(rows, fileName);
}

abstract class ExcelService {
  static Future<Workbook> _generateDocument(
    List<RowsModel> rows,
    String fileName,
  ) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0]..enableSheetCalculations();
    sheet.name = AppConstants.excelSheetName;

    // Маркировка проекта
    sheet.getRangeByName('A1')
      ..setText('a')
      ..cellStyle.fontColor = AppConstants.whiteColor;

    // Размер колонок
    sheet.getRangeByName('B1').columnWidth = 32.64;
    sheet.getRangeByName('F6').columnWidth = 13.82;

    Range c2 = sheet.getRangeByName('C2')..setText('Примерный сметный расчет');
    c2.cellStyle.italic = true;
    c2.cellStyle.bold = true;
    c2.cellStyle.underline = true;
    c2.columnWidth = 9;

    // Данные заголовка
    final titleData = [
      ['Объект:', fileName],
      ['Заказчик:', ''],
      [
        'Приложение №1',
        'к Договору №1                от                   ${DateTime.now().year}.',
      ],
    ];

    // Стилизация ячеек
    final firstAndSecondStyle = [
      (range) {
        range.cellStyle.hAlign = HAlignType.right;
        range.cellStyle.bold = true;
      },
      (range) {
        range.cellStyle.underline = true;
        range.cellStyle.italic = true;
      },
    ];

    final List<List<void Function(Range range)>> styles = [
      firstAndSecondStyle,
      firstAndSecondStyle,
      [
        (range) => range.cellStyle.hAlign = HAlignType.right,
        (range) => range.cellStyle.hAlign = HAlignType.center,
      ],
    ];

    for (int i = 3; i < 6; i++) {
      sheet.getRangeByIndex(i, 3, i, 6).merge();
      for (int j = 2; j < 4; j++) {
        Range range = sheet.getRangeByIndex(i, j);
        range.setText(titleData[i - 3][j - 2]);
        styles[i - 3][j - 2](range);
      }
    }

    // Данные таблицы с заголовком
    final tableData = [
      [
        '№ п/п',
        'Наименование работы',
        'Ед. изм',
        'Кол-во',
        'Цена за единицу',
        'Общая стоимость',
      ],
      ...List.generate(
        rows.length,
        (index) => rows[index].toExcelRow(index + 1),
      ),
    ];

    // Стилизация и заполненение таблицы
    for (int i = 7; i < 8 + rows.length; i++) {
      for (int j = 1; j < 7; j++) {
        Range range = sheet.getRangeByIndex(i, j);

        range.cellStyle.vAlign = VAlignType.center;
        range.cellStyle.wrapText = true;

        // Выравнивание по левому краю для наименования и по центру для остальных
        range.cellStyle.hAlign = j == 2 && i > 7
            ? HAlignType.left
            : HAlignType.center;
        // Цвета ячеек таблицы
        range.cellStyle.backColor = i % 2 == 0
            ? AppConstants.lightBlueColor
            : AppConstants.whiteColor;
        range.cellStyle.fontColor = AppConstants.blackColor;
        range.cellStyle.borders.all.lineStyle = LineStyle.thin;

        // Установка значения
        if (i > 7 && j == 6) {
          range.setFormula('=D$i*E$i');
        } else {
          final item = tableData[i - 7][j - 1];
          range.setValue(item);
        }
        // Денежный формат
        if (j >= 5) {
          range.numberFormat = AppConstants.currencyFormat;
        }
        // Ячейка заголовка
        if (i == 7) {
          range.cellStyle.fontColor = AppConstants.whiteColor;
          range.cellStyle.bold = true;
          range.cellStyle.backColor = AppConstants.darkBlueColor;
        }
      }
    }

    // Строка итогов
    Range totalRange = sheet.getRangeByIndex(
      8 + rows.length,
      1,
      8 + rows.length,
      6,
    );
    totalRange
      ..cellStyle.backColor = AppConstants.darkBlueColor
      ..cellStyle.bold = true
      ..cellStyle.hAlign = HAlignType.center
      ..cellStyle.borders.all.lineStyle = LineStyle.thin
      ..cellStyle.fontColor = AppConstants.whiteColor;

    // Текст "Итого"
    Range itogo = sheet.getRangeByIndex(8 + rows.length, 2);
    itogo.setText(AppConstants.totalLabel);
    itogo.cellStyle.italic = true;
    itogo.cellStyle.hAlign = HAlignType.right;

    // Итоговая сумма
    if (rows.isNotEmpty) {
      sheet.getRangeByIndex(8 + rows.length, 6)
        ..setFormula('=SUM(F8:F${7 + rows.length})')
        ..numberFormat = AppConstants.currencyFormat;
    }

    // Дополнительные работы
    sheet.getRangeByName('A${10 + rows.length}:F${10 + rows.length}')
      ..merge()
      ..setText(AppConstants.additionalWorkText)
      ..cellStyle.bold = true;

    // Строка соглашения
    sheet.getRangeByName('A${11 + rows.length}:F${11 + rows.length}')
      ..merge()
      ..setText(AppConstants.agreementText)
      ..cellStyle.italic = true;

    return workbook;
  }

  static Future<void> saveAsFile(List<RowsModel> rows, String fileName) async {
    try {
      final workbook = await _generateDocument(rows, fileName);
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      String? outputPath;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        String? directoryPath = await FilePicker.platform.saveFile(
          type: FileType.custom,
          allowedExtensions: [AppConstants.excelExtension],
          fileName: '$fileName.${AppConstants.excelExtension}',
          dialogTitle: 'Выберите папку для сохранения файла',
        );
        if (directoryPath == null) return;
        outputPath = directoryPath.contains('.${AppConstants.excelExtension}')
            ? directoryPath
            : '$directoryPath.${AppConstants.excelExtension}';
      } else if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        outputPath = '$dir/$fileName.${AppConstants.excelExtension}';
      }
      final file = File(outputPath!);
      await file.writeAsBytes(bytes, flush: true);
      if (!Platform.isWindows) {
        await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
      }
      ProjectManager.saveProject(fileName, rows);
    } catch (e) {
      print('${AppConstants.saveError}: $e');
    }
  }

  static Future<XFile?> import(AppState appState, {XFile? xfile}) async {
    late Uint8List bytes;
    late XFile file;
    if (xfile != null) {
      file = xfile;
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result == null) return null;
      file = XFile(result.files.single.path!);
    }
    bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    final sheetName = excel.tables.keys.first;
    var sheet = excel.tables[sheetName]!;

    final name = sheet.row(2)[2]?.value.toString();
    if (name != null && name.isNotEmpty) {
      appState.updateSettingsName(name);
    }

    for (int rowIndex = 7; rowIndex < sheet.maxRows; rowIndex++) {
      var row = sheet.row(rowIndex);

      if (row.isEmpty) break;
      var firstCell = row[1]?.value?.toString().trim() ?? '';
      if (firstCell.toLowerCase().contains('итого')) break;
      appState.addRow(
        RowsModel(
          name: row[1]?.value?.toString() ?? '',
          category: row[2]?.value?.toString() == 'м2'
              ? Category.quadMeters
              : Category.values.firstWhere(
                  (e) => e.name == row[2]?.value?.toString(),
                  orElse: () => Category.quadMeters,
                ),
          count: double.tryParse(row[3]?.value?.toString() ?? '0') ?? 1,
          price: double.tryParse(row[4]?.value?.toString() ?? '0') ?? 0,
        ),
      );
    }
    return file;
  }
}
