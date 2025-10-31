import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/extensions.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/data/router.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/ui/views/row_page.dart';
import 'package:smeta_maker/ui/widgets/tag_widget.dart';

/// Optimized element widget with selective rebuilds
/// Uses const constructor and memoization for better performance
class ElementWidget extends StatelessWidget {
  const ElementWidget({super.key, required this.row, required this.index});

  final RowsModel row;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Only rebuild when relevant settings change
        final settings = appState.settings;

        return _ElementContent(
          row: row,
          index: index,
          isTotalsShown: settings.isTotalsShown,
        );
      },
    );
  }
}

/// Separated content widget to minimize rebuilds
class _ElementContent extends StatelessWidget {
  const _ElementContent({
    required this.row,
    required this.index,
    required this.isTotalsShown,
  });

  final RowsModel row;
  final int index;
  final bool isTotalsShown;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Memoized values to prevent recalculation
    final values = _buildValues();
    final widgets = _buildTagWidgets(values);

    return GestureDetector(
      onTap: () => AppRouter.push(RowPage(row: row)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: row.category.color.withValues(alpha: .5),
              borderRadius: AppBorderRadius.all,
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                10,
              ).add(const EdgeInsets.only(bottom: 5)),
              child: Text(
                row.name,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -5),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing,
              ),
              child: Row(spacing: AppConstants.spacing, children: widgets),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildValues() {
    final countText = row.category == Category.sht
        ? 'x${row.count.cleanDouble()}'
        : row.count.cleanDouble();

    final priceText = isTotalsShown
        ? 'Итого: ${row.calcPrice.toPrice()}'
        : row.price.toPrice();

    return [countText, row.category.name, '$priceText ₽'];
  }

  List<Widget> _buildTagWidgets(List<String> values) {
    final filteredValues = values.asMap().entries.where((entry) {
      final index = entry.key;

      // Hide count for complex items or when totals are shown
      if ((row.category == Category.complex || isTotalsShown) && index == 0) {
        return false;
      }

      // Hide category when totals are shown
      if (isTotalsShown && index == 1) {
        return false;
      }

      return true;
    }).toList();

    return filteredValues.map((entry) {
      return Expanded(
        child: TagWidget(color: row.category.color, text: entry.value),
      );
    }).toList();
  }
}
