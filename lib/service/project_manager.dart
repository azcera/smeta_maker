import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ProjectManager {
  static late final Directory _projectsDir;

  Directory get projectsDir => _projectsDir;

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

  static Future<void> saveProject(String name, List<RowsModel> rows) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    final fileName = name.trim();

    // Add data rows
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final rowData = [row.name, row.category.name, row.count, row.price];

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.getRangeByIndex(i + 2, j + 1);
        cell.setValue(rowData[j]);
      }
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final file = File('${_projectsDir.path}/$fileName.smeta');
    await file.writeAsBytes(bytes, flush: true);
  }

  static List<String> getProjectsList() {
    final files = _projectsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.smeta'))
        .toList();

    return files
        .map((f) => f.uri.pathSegments.last.replaceAll('.smeta', ''))
        .toList();
  }

  static Future<List<RowsModel>> loadProject(String name) async {
    final file = _getProjectFile(name);
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

    return rows;
  }

  static Future<void> deleteProject(String name) async {
    final file = _getProjectFile(name);

    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<bool> projectExists(String name) async {
    try {
      final file = _getProjectFile(name);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  static File _getProjectFile(String name) {
    return File('${_projectsDir.path}/$name.smeta');
  }
}
