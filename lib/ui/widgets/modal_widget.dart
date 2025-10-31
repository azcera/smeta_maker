import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smeta_maker/data/modal.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/state/input_controller.dart';

class ModalWidget extends StatefulWidget with Modal {
  const ModalWidget({required this.onTap, required this.title, super.key});

  final void Function() onTap;
  final String title;

  @override
  State<ModalWidget> createState() => _ModalWidgetState();
}

class _ModalWidgetState extends State<ModalWidget> {
  final FocusNode _dialogFocus = FocusNode();
  late final AppState appState;
  late final InputController inputController = appState.inputController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appState = context.watch<AppState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dialogFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: inputController,
      child: Consumer<InputController>(
        builder: (context, appState, state) {
          void tapFunction() {
            widget.onTap();
            AppRouter.pop();
            inputController.subController.clear();
            inputController.result = '';
          }

          return AlertDialog(
            title: Text(widget.title),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9+\-*/().,]'),
                    ),
                  ],
                  focusNode: _dialogFocus,
                  autofocus: true,
                  onChanged: inputController.calculate,
                  controller: inputController.subController,
                  keyboardType: TextInputType.number,
                  onEditingComplete: tapFunction,
                  decoration: InputDecoration(
                    suffixText: inputController.result,
                  ),
                ),
                SizedBox(height: 20),
                FilledButton(onPressed: tapFunction, child: Text('Изменить')),
              ],
            ),
          );
        },
      ),
    );
  }
}
