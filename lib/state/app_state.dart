import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/extensions.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/data/models/settings_model.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/service/project_manager.dart';
import 'package:smeta_maker/service/update_service.dart';
import 'package:smeta_maker/state/input_controller.dart';
import 'package:smeta_maker/ui/widgets/alert_widget.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _init();
  }

  _init() async {
    var packageInfo = await PackageInfo.fromPlatform();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _version = packageInfo.version,
    );
    getProjectsList();
  }

  void getProjectsList() async {
    final newProjects = await ProjectManager.getProjectsList();
    if (_projects.length != newProjects.length ||
        !_listEquals(_projects, newProjects)) {
      _projects = newProjects;
      notifyListeners();
    }
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  late String _version;
  List<RowsModel> _rows = [];
  List<RowsModel> _parsedRows = [];
  List<String> _projects = [];

  List<RowsModel> get parsedRows => _parsedRows;

  void initParsedRows(List<RowsModel> rows) {
    _parsedRows = rows;
    notifyListeners();
  }

  String get version => _version;
  List<String> get projects => _projects;

  SettingsModel _settings = SettingsModel(
    name: AppConstants.defaultProjectName,
    uploadedFile: null,
    isTotalsShown: false,
  );

  TextEditingController? _nameController;
  InputController inputController = InputController();

  TextEditingController get nameController {
    if (_nameController == null) {
      _nameController = TextEditingController(text: _settings.name);
    } else if (_nameController!.text != _settings.name) {
      // Обновляем текст только если он действительно изменился
      _nameController!.text = _settings.name;
    }
    return _nameController!;
  }

  bool _needToScroll = false;
  bool get needToScroll => _needToScroll;
  void switchNeedToScroll() => _needToScroll = !_needToScroll;

  List<RowsModel> get rows => _rows;
  SettingsModel get settings => _settings;

  String get totalPrice => _getTotalPrice(_rows);
  int get rowCount => _rows.length;

  void addRow(RowsModel row) {
    _rows = [..._rows, row];
    _needToScroll = true;
    notifyListeners();
  }

  void updateRow(int index, RowsModel row) {
    if (index >= 0 && index < _rows.length) {
      _rows = List.from(_rows)..[index] = row;
      notifyListeners();
    }
  }

  void deleteRow(int index) {
    if (index >= 0 && index < _rows.length) {
      _rows = List.from(_rows)..removeAt(index);
      notifyListeners();
    }
  }

  void reorderRows(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _rows.removeAt(oldIndex);
    _rows.insert(newIndex, item);
    notifyListeners();
  }

  void clearRows() {
    _rows = [];
    updateUploadedFile(null);
    _settings = _settings.copyWith(name: 'Смета');
    if (_nameController != null) {
      _nameController!.text = 'Смета';
    }
    notifyListeners();
  }

  void initRows(List<RowsModel> rows) {
    _rows = List.generate(rows.length, (index) => rows[index]);
    _needToScroll = true;

    notifyListeners();
  }

  void updateSettings(SettingsModel newSettings) {
    if (_settings != newSettings) {
      _settings = newSettings;
      notifyListeners();
    }
  }

  Timer? _debounce;
  void updateSettingsName(String? name) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _settings = _settings.copyWith(name: name ?? 'Смета');
      notifyListeners();
    });
  }

  void toggleTotalsShown() {
    if (_settings.isTotalsShown != !_settings.isTotalsShown) {
      _settings = _settings.copyWith(isTotalsShown: !_settings.isTotalsShown);
      notifyListeners();
    }
  }

  void updateUploadedFile(XFile? file) {
    print('updateUploadedFile called with: $file');
    if (_settings.uploadedFile != file) {
      _settings = _settings.copyWith(uploadedFile: file);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> checkupdates(BuildContext context) async {
    try {
      final result = await UpdateService.checkForUpdates();
      print(result);
      String title;
      List<FilledButton> buttons;
      String content = '';
      if (result != null && result[AppConstants.updateAvailableKey]) {
        final latest = result[AppConstants.latestVersionKey];
        final url = result[AppConstants.downloadUrlKey];
        title = 'Доступна версия $latest';
        void Function() onPressed = () {};

        if (Platform.isAndroid) {
          content =
              'При нажатии кнопки "обновить" приложение автоматически скачает новую версию и установит ее на устройство.';
          onPressed = () async {
            await UpdateService.downloadAndInstallApk(url);
          };
        }
        if (Platform.isWindows) {
          content =
              'При нажатии кнопки "обновить" у вас автоматически начнется скачивание новой версии и ее установка. Приложение перезапустится';
          onPressed = () async {
            await UpdateService.downloadAndRunInstaller(url);
          };
        }
        buttons = [FilledButton(onPressed: onPressed, child: Text('Обновить'))];
      } else {
        title = 'У вас последняя версия';
        content = 'Обновление не требуется';
        buttons = [
          FilledButton(onPressed: AppRouter.pop, child: Text('Закрыть')),
        ];
      }
      if (context.mounted) {
        AlertWidget(
          title: title,
          buttons: buttons,
          onTap: () {},
          content: content,
        ).show(context: context);
      }
      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }

  String _getTotalPrice(List<RowsModel> rows) {
    return rows.fold<double>(0, (sum, row) => sum + row.calcPrice).toPrice();
  }

  int getRowIndex(RowsModel row) => _rows.indexOf(row);

  @override
  void dispose() {
    _nameController?.dispose();
    super.dispose();
  }
}
