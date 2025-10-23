import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/state/page_scroll_controller.dart';
import 'package:smeta_maker/ui/widgets/add_button_widget.dart';
import 'package:smeta_maker/ui/widgets/element_widget.dart';
import 'package:smeta_maker/ui/widgets/home_bottom_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageScrollController _pageScrollController = PageScrollController();

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<AppState>(
    builder: (context, appState, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageScrollController.scrollToBottom();
      });
      double horizontalPadding =
          MediaQuery.of(context).size.width > AppConstants.maxWidth
          ? MediaQuery.of(context).size.width / 6
          : 16;
      return Scaffold(
        body: Center(
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: AppPadding.all,
                  child: Center(
                    child: ReorderableListView.builder(
                      proxyDecorator: (child, _, _) => child,
                      padding: EdgeInsets.only(
                        right: horizontalPadding,
                        left: horizontalPadding,
                        bottom: 150,
                      ),
                      scrollController: _pageScrollController,
                      itemCount: appState.rows.length,
                      itemBuilder: (context, index) {
                        final item = appState.rows[index];
                        final ValueKey key = ValueKey('$index$item');
                        return ReorderableDragStartListener(
                          index: index,
                          key: key,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: ElementWidget(row: item, index: index),
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        appState.reorderRows(oldIndex, newIndex);
                      },
                      footer: AddButtonWidget(),
                    ),
                  ),
                ),
              ),
              HomeBottomWidget(),
            ],
          ),
        ),
      );
    },
  );
}
