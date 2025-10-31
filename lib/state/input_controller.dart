import 'package:flutter/material.dart';
import 'package:languagetool_textfield/languagetool_textfield.dart' as ltf;
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/models/rows_model.dart';

class InputController extends ltf.LanguageToolController {
  Category _getLastCategory(SharedPreferences prefs) {
    final saved = prefs.getString(AppConstants.lastCategoryKey);
    return Category.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => Category.complex,
    );
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    updateSelected((e) => e.copyWith(category: _getLastCategory(prefs)));
    notifyListeners();
  }

  InputController()
    : super(
        highlightStyle: ltf.HighlightStyle(
          backgroundOpacity: 0,
          decoration: TextDecoration.underline,
        ),
      ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  void onChange(String? value) {
    if (value == null || value.isNotEmpty) return;
    List<String> splitted = value.split('*');
    if (splitted.length < 2) return;
    print(splitted[1]);
  }

  String result = '';
  RowsModel selected = RowsModel(
    name: '',
    category: Category.complex,
    count: 1,
    price: 0,
  );

  final subController = TextEditingController();

  void calculate(String text) {
    if (text.isEmpty) {
      result = '';
      notifyListeners();
      return;
    }

    try {
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(text.replaceAll(',', '.'));
      ContextModel cm = ContextModel();
      num eval = RealEvaluator(cm).evaluate(exp);
      result = '= ${eval.toString()}';
      notifyListeners();
    } catch (e) {
      result = '';
      notifyListeners();
    }
  }

  int _switchIndex = 0;
  double _reserveCount = 1;

  void updateSelected(RowsModel Function(RowsModel e) update) {
    selected = update(selected);
    notifyListeners();
  }

  void switchCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCategory = _getLastCategory(prefs);
    final int currentIndex = Category.values.indexOf(lastCategory);
    _switchIndex = currentIndex;
    if (_switchIndex < Category.values.length - 1) {
      _switchIndex++;
    } else {
      _switchIndex = 0;
    }
    if (Category.values[_switchIndex] == Category.complex) {
      _reserveCount = selected.count;
      updateSelected((e) => e.copyWith(count: 1));
    }
    if (Category.values[currentIndex] == Category.complex) {
      updateSelected((e) => e.copyWith(count: _reserveCount));
    }
    prefs.setString(
      AppConstants.lastCategoryKey,
      Category.values[_switchIndex].name,
    );
    updateSelected((e) => e.copyWith(category: lastCategory));
    notifyListeners();
  }
}
