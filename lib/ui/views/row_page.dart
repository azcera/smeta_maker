import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/state/input_controller.dart';
import 'package:smeta_maker/ui/builders/options.dart';
import 'package:smeta_maker/ui/widgets/row_bottom_widget.dart';

class RowPage extends StatefulWidget {
  const RowPage({this.row, super.key});
  final RowsModel? row;

  @override
  State<RowPage> createState() => _RowPageState();
}

class _RowPageState extends State<RowPage> {
  late AppState appState;
  late int index;

  @override
  void initState() {
    super.initState();
    appState = context.read<AppState>();
    if (widget.row == null) return;
    RowsModel item = widget.row!;
    appState.inputController.text = item.name;
    appState.inputController.updateSelected(
      (e) => e.copyWith(
        category: item.category,
        price: item.price,
        count: item.count,
        name: item.name,
      ),
    );
    index = appState.getRowIndex(item);
  }

  @override
  void dispose() {
    appState.inputController.clear();
    appState.inputController.selected = RowsModel.start(
      appState.inputController.selected.category,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    List<RowsModel> rows = appState.rows;

    bool canPress = true;
    DateTime _closeSubTime = DateTime.now();
    void setCloseSubTime(DateTime value) => _closeSubTime = value;
    ValueNotifier<bool> focusLockEnabled = ValueNotifier(true);

    return ChangeNotifierProvider.value(
      value: appState.inputController,
      child: Consumer<InputController>(
        builder: (context, inputController, child) {
          void submitEdit() {
            if (formKey.currentState == null) return;
            formKey.currentState!.save();
            if (formKey.currentState!.validate()) {
              if (widget.row != null) {
                if (inputController.selected.name.isEmpty) {
                  appState.deleteRow(index);
                  inputController.selected = RowsModel.start(
                    inputController.selected.category,
                  );
                  AppRouter.pop();
                } else {
                  appState.updateRow(index, inputController.selected);
                  inputController.selected = RowsModel.start(
                    inputController.selected.category,
                  );
                  AppRouter.pop();
                }
              } else if (inputController.selected.name.isNotEmpty) {
                appState.addRow(inputController.selected);
                inputController.selected = RowsModel.start(
                  inputController.selected.category,
                );
                AppRouter.pop();
              }
            }
          }

          return KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (key) {
              if (focusLockEnabled.value &&
                  _closeSubTime.millisecond != DateTime.now().millisecond) {
                String? pressedKey = key.logicalKey.keyLabel;
                withDuration(void Function() function) {
                  canPress = false;
                  Timer(Duration(milliseconds: 400), () => canPress = true);
                  function();
                }

                if (canPress) {
                  if (pressedKey == 'Escape') {
                    withDuration(AppRouter.pop);
                  } else if (pressedKey == 'Enter') {
                    withDuration(submitEdit);
                  } else if (pressedKey == 'Tab') {
                    withDuration(inputController.switchCategory);
                  }
                }
              }
            },
            child: Scaffold(
              bottomNavigationBar: RowBottomWidget(
                submitEdit,
                row: widget.row,
                focusLockEnabled: focusLockEnabled,
                setCloseSubTime: setCloseSubTime,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: AppPadding.all,
                    child: Autocomplete<String>(
                      optionsViewBuilder: Options.optionsViewBuilder<String>,
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return Iterable<String>.empty();
                        }

                        final List list = rows.map((e) => e.name).toList()
                          ..addAll(appState.parsedRows.map((e) => e.name));
                        return list
                            .where(
                              (name) => name.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            )
                            .map((e) => e);
                      },
                      onSelected: (String selection) {
                        inputController.text = selection;
                        inputController.updateSelected(
                          (e) => e = appState.parsedRows.firstWhere(
                            (e) => e.name == selection,
                          ),
                        );
                      },
                      fieldViewBuilder:
                          (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              textEditingController.text =
                                  inputController.selected.name;
                            });
                            inputController.focusNode = focusNode;
                            focusNode.addListener(() {
                              if (focusLockEnabled.value &&
                                  !focusNode.hasFocus &&
                                  Platform.isWindows) {
                                Future.microtask(
                                  () => focusNode.requestFocus(),
                                );
                              }
                            });

                            return Form(
                              key: formKey,
                              child: TextFormField(
                                onTapOutside: (event) {
                                  if (Platform.isWindows) {
                                    focusNode.requestFocus();
                                  } else {
                                    focusNode.unfocus();
                                  }
                                },
                                focusNode: focusNode,
                                keyboardType: TextInputType.multiline,
                                onChanged: (value) =>
                                    inputController.updateSelected(
                                      (e) => e.copyWith(name: value),
                                    ),
                                maxLines: null,
                                autofocus: true,
                                style: TextStyle(fontSize: 30),
                                controller: textEditingController,
                                autocorrect: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r"\n"),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Введите наименование работы',
                                ),
                                onEditingComplete: submitEdit,
                              ),
                            );
                          },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
