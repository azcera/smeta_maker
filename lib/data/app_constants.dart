import 'package:flutter/material.dart';

/// Все константы приложения
abstract class AppConstants {
  // GitHub -------------------------------------

  /// Имя репозитория GitHub — `smeta_maker`
  static const String repoName = 'smeta_maker';

  /// Владелец репозитория GitHub — `azcera`
  static const String repoOwner = 'azcera';

  /// URL для получения последнего релиза GitHub
  static const String latestReleaseUrl =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  // UI -------------------------------------

  /// Максимальная ширина контента — `600.0`
  static const double maxWidth = 600.0;

  /// Отступ по умолчанию — `16.0`
  static const double defaultPadding = 16.0;

  /// Радиус скругления углов — `14.0`
  static const double borderRadius = 14.0;

  /// Расстояние между элементами — `15.0`
  static const double spacing = 15.0;

  // FILE -------------------------------------

  /// Расширение файлов проекта — `.smeta`
  static const String projectExtension = '.smeta';

  /// Расширение файлов Excel — `.xlsx`
  static const String excelExtension = '.xlsx';

  // KEYS -------------------------------------

  static const String lastCategoryKey = 'lastCategory',
      totalsShownKey = 'isTotalsShown',
      updateAvailableKey = 'updateAvailable',
      latestVersionKey = 'latestVersion',
      downloadUrlKey = 'downloadUrl';

  // DEFAULT -------------------------------------

  /// Название проекта по умолчанию — `Смета`
  static const String defaultProjectName = 'Смета';

  /// Количество по умолчанию — `1.0`
  static const double defaultCount = 1.0;

  /// Цена по умолчанию — `0.0`
  static const double defaultPrice = 0.0;

  // EXCEL -------------------------------------

  /// Имя листа Excel — `Лист1`
  static const String excelSheetName = 'Лист1';

  /// Формат валюты — `#,##0 ₽`
  static const String currencyFormat = '#,##0 ₽';

  static const String darkBlueColor = '#4472c4',
      lightBlueColor = '#d9e1f2',
      whiteColor = '#ffffff',
      blackColor = '#000000';

  // TEXT -------------------------------------

  /// Текст заголовка итогов — `Итого по всем разделам работ:`
  static const String totalLabel = 'Итого по всем разделам работ:';

  /// Дополнительный текст — `Все дополнительные работы...`
  static const String additionalWorkText =
      'Все дополнительные работы оговариваются с заказчиком и вносятся в смету.';

  /// Текст согласия — `Ознакомлен и согласен...`
  static const String agreementText =
      'Ознакомлен и согласен_______________________________________________';

  // ERRORS -------------------------------------

  /// Ошибка: пустое имя проекта
  static const String emptyProjectNameError =
      'Название проекта не может быть пустым';

  /// Ошибка: попытка сохранить пустой проект
  static const String emptyProjectError = 'Нельзя сохранить пустой проект';

  /// Ошибка: файл проекта не найден
  static const String fileNotFoundError = 'Файл проекта не найден';

  /// Ошибка при сохранении
  static const String saveError = 'Ошибка при сохранении';

  /// Ошибка при загрузке
  static const String loadError = 'Ошибка при загрузке';
}

abstract class AppPadding {
  /// Все стороны — `16.0`
  static const EdgeInsets all = EdgeInsets.all(AppConstants.defaultPadding);

  /// Горизонтальные отступы — `16.0`
  static const EdgeInsets horizontal = EdgeInsets.symmetric(
    horizontal: AppConstants.defaultPadding,
  );

  /// Вертикальные отступы — `16.0`
  static const EdgeInsets vertical = EdgeInsets.symmetric(
    vertical: AppConstants.defaultPadding,
  );

  /// Нижний отступ — `16.0`
  static const EdgeInsets bottom = EdgeInsets.only(
    bottom: AppConstants.defaultPadding,
  );

  /// Верхний отступ — `16.0`
  static const EdgeInsets top = EdgeInsets.only(
    top: AppConstants.defaultPadding,
  );
}

abstract class AppBorderRadius {
  /// Все углы — `14.0`
  static const BorderRadius all = BorderRadius.all(
    Radius.circular(AppConstants.borderRadius),
  );

  /// Верхние углы — `14.0`
  static const BorderRadius top = BorderRadius.vertical(
    top: Radius.circular(AppConstants.borderRadius),
  );

  /// Нижние углы — `14.0`
  static const BorderRadius bottom = BorderRadius.vertical(
    bottom: Radius.circular(AppConstants.borderRadius),
  );
}
