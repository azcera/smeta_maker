import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/extensions.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/data/theme.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/state/input_controller.dart';
import 'package:smeta_maker/ui/widgets/modal_widget.dart';
import 'package:smeta_maker/ui/widgets/tag_widget.dart';

class RowBottomWidget extends StatefulWidget {
  const RowBottomWidget(
    this.submitEdit, {
    required this.focusLockEnabled,
    required this.setCloseSubTime,
    this.row,
    super.key,
  });
  final void Function() submitEdit;
  final RowsModel? row;
  final ValueNotifier<bool> focusLockEnabled;
  final void Function(DateTime value) setCloseSubTime;

  @override
  State<RowBottomWidget> createState() => _RowBottomWidgetState();
}

class _RowBottomWidgetState extends State<RowBottomWidget> {
  bool isTap = true;
  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    return ChangeNotifierProvider.value(
      value: appState.inputController,
      child: Consumer<InputController>(
        builder: (context, inputController, _) {
          void onClose(_) {
            widget.focusLockEnabled.value = true;
            widget.setCloseSubTime(DateTime.now());
            inputController.subController.text = '';
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: AppPadding.horizontal.add(
                EdgeInsetsGeometry.only(bottom: 20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      inputController.selected.category != Category.complex
                          ? Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AbsorbPointer(
                                      absorbing:
                                          inputController.selected.category ==
                                          Category.complex,
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.focusLockEnabled.value = false;
                                          ModalWidget(
                                            title: 'Введите количество',
                                            onTap: () =>
                                                inputController.updateSelected(
                                                  (e) => e.copyWith(
                                                    count: double.parse(
                                                      inputController.result
                                                                  .split('= ')
                                                                  .length >
                                                              1
                                                          ? inputController
                                                                .result
                                                                .split('= ')[1]
                                                          : '1',
                                                    ),
                                                  ),
                                                ),
                                          ).show().then(onClose);
                                        },
                                        child: TagWidget(
                                          color: AppColors.secondButton,
                                          text: inputController.selected.count
                                              .cleanDouble(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppConstants.spacing),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                      Expanded(
                        child: GestureDetector(
                          onTap: inputController.switchCategory,
                          onLongPress: inputController.switchCategory,
                          child: TagWidget(
                            color: AppColors.secondButton,
                            text: inputController.selected.category.name,
                          ),
                        ),
                      ),
                      SizedBox(width: AppConstants.spacing),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.focusLockEnabled.value = false;
                            ModalWidget(
                              title: 'Введите цену',
                              onTap: () => inputController.updateSelected(
                                (e) => e.copyWith(
                                  price: double.parse(
                                    inputController.result.split('= ').length >
                                            1
                                        ? inputController.result.split('= ')[1]
                                        : '1',
                                  ),
                                ),
                              ),
                            ).show().then(onClose);
                          },
                          child: TagWidget(
                            color: AppColors.secondButton,
                            text: inputController.selected.price > 0
                                ? '${inputController.selected.price.toPrice()} ₽'
                                : 'Цена',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.spacing),
                  FilledButton(
                    onPressed:
                        widget.row == null &&
                            inputController.selected.name.isEmpty
                        ? AppRouter.pop
                        : widget.submitEdit,
                    child: Text(
                      widget.row == null &&
                              inputController.selected.name.isEmpty
                          ? 'Назад'
                          : 'Сохранить',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
