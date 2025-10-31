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
  void didChangeDependencies() {
    super.didChangeDependencies();

    AppState appState = Provider.of<AppState>(context, listen: true);

    if (appState.needToScroll) {
      _pageScrollController.scrollToBottom();
      appState.switchNeedToScroll();
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<AppState>(
    builder: (context, appState, child) {
      double horizontalPadding =
          MediaQuery.of(context).size.width > AppConstants.maxWidth
          ? MediaQuery.of(context).size.width / 6
          : 10;
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
                        bottom: AppConstants.spacing*10,
                      ),

                      scrollController: _pageScrollController,
                      itemCount: appState.rows.length,
                      itemBuilder: (context, index) {
                        final item = appState.rows[index];
                        final ValueKey key = ValueKey('$index$item');
                        return ReorderableDelayedDragStartListener(
                          index: index,
                          key: key,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing),
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
