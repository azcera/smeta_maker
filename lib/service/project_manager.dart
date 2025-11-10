import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

List<RowsModel> _loadProjectIsolate(Map<String, dynamic> args) {
  final name = args['name'] as String;
  final path = args['path'] as String;

  final file = File('$path/$name.smeta');
  final bytes = file.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName]!;

  final rows = <RowsModel>[];

  for (int i = 0; i < sheet.maxRows; i++) {
    final row = sheet.rows[i];
    if (row.length < 4) continue;

    try {
      final rowModel = RowsModel(
        name: row[0]?.value.toString() ?? '',
        category: Category.values.firstWhere(
          (e) => e.name == row[1]?.value.toString(),
          orElse: () => Category.complex,
        ),
        count:
            double.tryParse(row[2]?.value.toString() ?? '0') ??
            AppConstants.defaultCount,
        price:
            double.tryParse(row[3]?.value.toString() ?? '0') ??
            AppConstants.defaultPrice,
      );
      rows.add(rowModel);
    } catch (_) {
      continue;
    }
  }

  return rows;
}

abstract class ProjectManager {
  static Directory? _projectsDir;

  static Future<Directory> create() async {
    final appDir = await _getAppDir();
    final projectsDir = Directory('${appDir.path}/projects/');

    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    _projectsDir = projectsDir;
    return projectsDir;
  }

  static Future<Directory> _getAppDir() async {
    if (Platform.isWindows) {
      return await getApplicationSupportDirectory();
    } else if (Platform.isMacOS ||
        Platform.isIOS ||
        Platform.isAndroid ||
        Platform.isLinux) {
      return await getApplicationDocumentsDirectory();
    }
    return await getTemporaryDirectory();
  }

  static Future<void> saveProject(String name, AppState appState) async {
    if (_projectsDir == null) {
      await create();
    }
    try {
      final workbook = Workbook();
      final sheet = workbook.worksheets[0];
      final fileName = name.trim();

      // Add data rows
      for (int i = 0; i < appState.rowCount; i++) {
        final row = appState.rows[i];
        final rowData = [row.name, row.category.name, row.count, row.price];

        for (int j = 0; j < rowData.length; j++) {
          final cell = sheet.getRangeByIndex(i + 1, j + 1);
          cell.setValue(rowData[j]);
        }
      }

      final bytes = workbook.saveAsStream();
      workbook.dispose();

      final file = File('${_projectsDir!.path}/$fileName.smeta');
      await file.writeAsBytes(bytes, flush: true);
      appState.getProjectsList();
    } catch (e) {
      print('Ошибка при сохранении проекта: $e');
    }
  }

  static Future<List<String>> getProjectsList() async {
    if (_projectsDir == null) {
      await create();
    }

    final files = _projectsDir!
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith(AppConstants.projectExtension))
        .toList();

    return files
        .map(
          (f) => f.uri.pathSegments.last.replaceAll(
            AppConstants.projectExtension,
            '',
          ),
        )
        .toList();
  }

  static Future<List<RowsModel>> loadProject(String name) async {
    final file = await _getProjectFile(name);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;

    final rows = <RowsModel>[];

    for (int i = 0; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.length < 4) continue;

      try {
        final rowModel = RowsModel(
          name: row[0]?.value.toString() ?? '',
          category: Category.values.firstWhere(
            (e) => e.name == row[1]?.value.toString(),
            orElse: () => Category.complex,
          ),
          count:
              double.tryParse(row[2]?.value.toString() ?? '0') ??
              AppConstants.defaultCount,
          price:
              double.tryParse(row[3]?.value.toString() ?? '0') ??
              AppConstants.defaultPrice,
        );
        rows.add(rowModel);
      } catch (e) {
        continue;
      }
    }

    return await compute(_loadProjectIsolate, {
      'name': name,
      'path': _projectsDir!.path,
    });
  }

  static Future<void> deleteProject(String name) async {
    final file = await _getProjectFile(name);

    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<File> _getProjectFile(String name) async {
    if (_projectsDir == null) {
      await create();
    }
    return File('${_projectsDir!.path}/$name.smeta');
  }
}
