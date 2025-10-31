import 'package:basic_dropdown_button/basic_dropdown_button.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/theme.dart';
import 'package:smeta_maker/service/excel_service.dart';
import 'package:smeta_maker/service/project_manager.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/ui/widgets/settings_element.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});
  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  //late PackageInfo packageInfo;
  //List<String> projects = [];
  String? selectedValue;

  // init() async {
  //   packageInfo = await PackageInfo.fromPlatform();
  //   projects = await ProjectManager.getProjectsList();
  // }

  Key dropDownKey = Key('DropDownMenu');

  @override
  void initState() {
    // init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        Future<void> loadRowsFromProject(String name) async {
          appState.initRows(await ProjectManager.loadProject(name));
          appState.updateSettingsName(name);
        }

        return Center(
          child: ListView.builder(
            // Используем ListView.builder для лучшей производительности
            itemCount: 6, // Количество элементов настроек
            padding: EdgeInsets.symmetric(
              horizontal:
                  MediaQuery.of(context).size.width > AppConstants.maxWidth
                  ? MediaQuery.of(context).size.width / 6
                  : 10,
            ).add(EdgeInsetsGeometry.only(bottom: AppConstants.spacing * 10)),
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildProjectNameField(appState);
                case 1:
                  return _buildClearRowsButton(appState);
                case 2:
                  return _buildUploadTableButton(appState);
                case 3:
                  return _buildDisplayModeSwitch(appState);
                case 4:
                  return _buildCheckUpdatesButton(appState);
                case 5:
                  return _buildProjectsDropdown(appState, loadRowsFromProject);
                default:
                  return SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildProjectNameField(AppState appState) {
    return SettingsElement(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BoxBorder.all(color: AppColors.mainButton),
          borderRadius: AppBorderRadius.all,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: appState.nameController,
            style: TextStyle(decorationStyle: TextDecorationStyle.wavy),
            onChanged: (text) => appState.updateSettingsName(text),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Введите название объекта',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      title: 'Название объекта',
    );
  }

  Widget _buildClearRowsButton(AppState appState) {
    return SettingsElement(
      child: FilledButton(
        onPressed: () => appState.clearRows(),
        child: Text('Очистить строки'),
      ),
      title: 'Количество строк: ${appState.rows.length}',
    );
  }

  Widget _buildUploadTableButton(AppState appState) {
    return SettingsElement(
      child: FilledButton(
        onPressed: () async {
          XFile? file = await ExcelService.import(appState);
          if (file != null) {
            appState.updateUploadedFile(file);
          }
        },
        child: Text('Загрузить таблицу'),
      ),
      title:
          'Загруженная таблица: ${appState.settings.uploadedFile?.name ?? 'нет'}',
    );
  }

  Widget _buildDisplayModeSwitch(AppState appState) {
    return SettingsElement(
      child: Row(
        spacing: AppConstants.spacing,
        children: [
          Expanded(child: Text('Цена за единицу', textAlign: TextAlign.center)),
          Switch(
            value: appState.settings.isTotalsShown,
            onChanged: (value) {
              // Убираем setState для лучшей производительности
              appState.toggleTotalsShown();
            },
          ),
          Expanded(
            child: Text('Итоговые значения', textAlign: TextAlign.center),
          ),
        ],
      ),
      title: 'Режим отображения:',
    );
  }

  Widget _buildCheckUpdatesButton(AppState appState) {
    return SettingsElement(
      child: FilledButton(
        onPressed: () => appState.checkupdates(),
        child: Text('Проверить обновления'),
      ),
      title: 'Текущая версия: ${appState.version}',
    );
  }

  Widget _buildProjectsDropdown(
    AppState appState,
    Future<void> Function(String) loadRowsFromProject,
  ) {
    return SettingsElement(
      title: 'Список проектов:',
      child: AbsorbPointer(
        absorbing: appState.projects.isEmpty ? true : false,
        child: BasicDropDownButton(
          menuItems: (hideMenu) => appState.projects
              .map(
                (item) => Material(
                  color: AppColors.secondButton,
                  child: InkWell(
                    onLongPress: () {
                      selectedValue = null;
                      hideMenu();
                      ProjectManager.deleteProject(item);
                    },
                    onTap: () {
                      loadRowsFromProject(item);
                      selectedValue = item;
                      hideMenu();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.all,
                      ),
                      child: Text(item, style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              )
              .toList(),
          menuVerticalSpacing: 0,
          position: DropDownButtonPosition.bottomCenter,
          buttonStyle: AppTheme.dropdownStyle,
          menuBorderRadius: BorderRadius.circular(10),
          menuBackgroundColor: AppColors.secondButton,
          buttonIconFirst: false,
          buttonIconSpace: 10,
          buttonTextStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Colors.white,
          ),
          buttonText: selectedValue == null
              ? appState.projects.isEmpty
                    ? 'Нет проектов'
                    : 'Выберите проект'
              : selectedValue,
          buttonIcon: ({required showedMenu}) => appState.projects.isEmpty
              ? SizedBox.shrink()
              : !showedMenu
              ? Icon(Icons.arrow_drop_down)
              : Icon(Icons.arrow_drop_up),
        ),
      ),
    );
  }
}
