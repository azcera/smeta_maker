import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/extensions.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/data/models/settings_model.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/service/update_service.dart';
import 'package:smeta_maker/state/input_controller.dart';
import 'package:smeta_maker/ui/widgets/alert_widget.dart';

class AppState extends ChangeNotifier {
  List<RowsModel> _rows = [];
  SettingsModel _settings = SettingsModel(
    name: 'Смета',
    uploadedFile: null,
    isTotalsShown: false,
  );

  // Settings controller for text input
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

  // Getters
  List<RowsModel> get rows => _rows;
  SettingsModel get settings => _settings;

  // Computed properties
  String get totalPrice => _getTotalPrice(_rows);
  int get rowCount => _rows.length;

  // Row operations
  void addRow(RowsModel row) {
    _rows = [..._rows, row];
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
    notifyListeners();
  }

  // Settings operations
  void updateSettings(SettingsModel newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void updateSettingsName(String? name) {
    _settings = _settings.copyWith(name: name ?? 'Смета');
    // НЕ обновляем контроллер здесь, чтобы не сбрасывать ввод пользователя
    notifyListeners();
  }

  void toggleTotalsShown() {
    _settings = _settings.copyWith(isTotalsShown: !_settings.isTotalsShown);
    notifyListeners();
  }

  void updateUploadedFile(XFile? file) {
    print('updateUploadedFile called with: $file');
    _settings = _settings.copyWith(uploadedFile: file);
    notifyListeners();
  }

  // Update check method
  Future<Map<String, dynamic>?> checkupdates() async {
    try {
      final result = await UpdateService.checkForUpdates();
      print(result);
      String title;
      List<FilledButton> buttons;
      String content;
      if (result != null && result[AppConstants.updateAvailableKey]) {
        final latest = result[AppConstants.latestVersionKey];
        final url = result[AppConstants.downloadUrlKey];
        title = latest;
        buttons = [FilledButton(onPressed: () {}, child: Text('Обновить'))];
        content = url;
      } else {
        title = 'У вас последняя версия';
        content = 'Обновление не требуется';
        buttons = [
          FilledButton(onPressed: AppRouter.pop, child: Text('Закрыть')),
        ];
      }
      AlertWidget(
        title: title,
        buttons: buttons,
        onTap: () {},
        content: content,
      ).show();
      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Helper methods
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
