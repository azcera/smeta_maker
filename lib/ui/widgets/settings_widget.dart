import 'package:basic_dropdown_button/basic_dropdown_button.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
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
  late PackageInfo packageInfo;
  String version = '';

  init() async {
    packageInfo = await PackageInfo.fromPlatform();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {
        version = packageInfo.version;
        version = packageInfo.buildNumber.isNotEmpty
            ? '$version (${packageInfo.buildNumber})'
            : version;
      }),
    );
  }

  Key dropDownKey = Key('DropDownMenu');

  @override
  void initState() {
    init();
    super.initState();
  }

  List<String> projects = [];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();

    Future<void> loadRowsFromProject(String name) async {
      appState.initRows(await ProjectManager.loadProject(name));
      appState.updateSettingsName(name);
    }

    List projects = ProjectManager.getProjectsList();
    return Center(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 6,
        ).add(EdgeInsetsGeometry.only(bottom: 100)),
        children: [
          SettingsElement(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: BoxBorder.all(color: AppColors.mainButton),
                borderRadius: BorderRadius.circular(14),
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
          ),
          SettingsElement(
            child: FilledButton(
              onPressed: () => appState.clearRows(),
              child: Text('Очистить строки'),
            ),
            title: 'Количество строк: ${appState.rows.length}',
          ),
          SettingsElement(
            child: FilledButton(
              onPressed: () async {
                XFile? file = await ExcelService.import(appState);
                if (file != null) {
                  appState.updateUploadedFile(file);
                }
                //AppRouter.pop();
              },
              child: Text('Загрузить таблицу'),
            ),
            title:
                'Загруженная таблица: ${appState.settings.uploadedFile?.name ?? 'нет'}',
          ),
          SettingsElement(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Итоговые значения'),
                Switch(
                  value: appState.settings.isTotalsShown,
                  onChanged: (value) => setState(() {
                    appState.toggleTotalsShown();
                  }),
                ),
                Text('Цена за единицу'),
              ],
            ),
            title: 'Режим отображения:',
          ),
          SettingsElement(
            child: FilledButton(
              onPressed: () => appState.checkupdates(),
              child: Text('Проверить обновления'),
            ),
            title: 'Текущая версия: ${version}',
          ),

          SettingsElement(
            title: 'Список проектов:',
            child: AbsorbPointer(
              absorbing: projects.isEmpty ? true : false,
              child: BasicDropDownButton(
                menuItems: (hideMenu) => projects
                    .map(
                      (item) => Material(
                        color: AppColors.secondButton,
                        child: InkWell(
                          onLongPress: () {
                            setState(() {
                              selectedValue = null;
                              hideMenu();
                            });
                            ProjectManager.deleteProject(item);
                          },
                          onTap: () {
                            loadRowsFromProject(item);
                            setState(() {
                              selectedValue = item;
                              hideMenu();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              item,
                              style: TextStyle(color: Colors.white),
                            ),
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
                    ? projects.isEmpty
                          ? 'Нет проектов'
                          : 'Выберите проект'
                    : selectedValue,

                buttonIcon: ({required showedMenu}) => projects.isEmpty
                    ? SizedBox.shrink()
                    : !showedMenu
                    ? Icon(Icons.arrow_drop_down)
                    : Icon(Icons.arrow_drop_up),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
