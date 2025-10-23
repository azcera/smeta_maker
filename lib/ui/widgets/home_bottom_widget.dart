import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/data/theme.dart';
import 'package:smeta_maker/service/excel_service.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/ui/views/row_page.dart';
import 'package:smeta_maker/ui/views/settings_page.dart';
import 'package:smeta_maker/ui/widgets/alert_widget.dart';
import 'package:smeta_maker/ui/widgets/pressable_icon_widget.dart';

class HomeBottomWidget extends StatelessWidget {
  const HomeBottomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();

    void save() async =>
        await ExcelService.saveAsFile(appState.rows, appState.settings.name);

    return Align(
      alignment: AlignmentGeometry.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppPadding.all.add(EdgeInsetsGeometry.only(bottom: 5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => appState.toggleTotalsShown(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  decoration: BoxDecoration(
                    color: appState.settings.isTotalsShown
                        ? AppColors.totalShow
                        : AppColors.secondButton,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Итого: ${appState.totalPrice} ₽'),
                ),
              ),
              SizedBox(height: 7),
              IntrinsicHeight(
                child: Row(
                  spacing: 15,
                  children: [
                    PressableIconWidget(
                      Icons.delete,
                      onTap: () => AlertWidget(
                        onTap: () {},
                        title: 'Вы уверены?',
                        content:
                            'Это действие удалит все несохраненные данные.',
                        buttons: [
                          FilledButton(
                            onPressed: AppRouter.pop,
                            child: Text('Оставить'),
                            style: FilledButton.styleFrom(
                              minimumSize: Size(0, 0),
                            ),
                          ),
                          FilledButton(
                            onPressed: () {
                              appState.clearRows();
                              AppRouter.pop();
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: Size(0, 0),
                              backgroundColor: AppColors.delete,
                            ),

                            child: Text('Удалить'),
                          ),
                        ],
                      ).show(),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => appState.rows.isNotEmpty
                            ? save()
                            : AppRouter.push(RowPage()),
                        child: Text(
                          appState.rows.isNotEmpty
                              ? 'Сохранить'
                              : 'Заполните поля',
                        ),
                      ),
                    ),
                    PressableIconWidget(
                      Icons.settings,
                      onTap: () => AppRouter.push(SettingsPage()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
