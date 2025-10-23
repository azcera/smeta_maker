import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/models/settings_model.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/service/excel_service.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/ui/widgets/settings_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppState appState;
  @override
  void initState() {
    super.initState();
    appState = context.read<AppState>();
  }

  @override
  Widget build(BuildContext context) {
    void dragDone(details) async {
      appState.updateSettings(
        SettingsModel(
          name: appState.settings.name,
          uploadedFile: details.files.first,
          isTotalsShown: appState.settings.isTotalsShown,
        ),
      );
      ExcelService.import(appState, xfile: appState.settings.uploadedFile);
      setState(() {});
    }

    return Scaffold(
      body: SafeArea(
        child: DropTarget(
          enable: true,
          onDragDone: dragDone,
          child: Padding(
            padding: AppPadding.all,
            child: Stack(
              children: [
                SettingsWidget(),
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: FilledButton(
                    onPressed: AppRouter.pop,
                    child: Text('Назад'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
