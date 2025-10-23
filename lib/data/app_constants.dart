import 'package:flutter/material.dart';

abstract class AppConstants {
  // Github
  static const String repoName = 'smeta_maker', repoOwner = 'azcera';

  // Url
  static const String latestReleaseUrl =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  // UI
  static const double maxWidth = 600.0,
      defaultPadding = 16.0,
      borderRadius = 14.0,
      spacing = 15.0;

  // File
  static const String projectExtension = '.smeta', excelExtension = 'xlsx';

  // Storage Keys
  static const String lastCategoryKey = 'last-category',
      totalsShownKey = 'is-totals-shown',
      updateAvailableKey = 'updateAvailable',
      latestVersionKey = 'latestVersion',
      downloadUrlKey = 'downloadUrl';

  // Default Values
  static const String defaultProjectName = 'Смета';
  static const double defaultCount = 1.0, defaultPrice = 0.0;

  // Excel
  static const String excelSheetName = 'Лист1',
      currencyFormat = '#,##0 ₽',
      darkBlueColor = '#4472c4',
      lightBlueColor = '#d9e1f2',
      whiteColor = '#ffffff',
      blackColor = '#000000';

  // Text
  static const String
  totalLabel = 'Итого по всем разделам работ:',
  additionalWorkText =
      'Все дополнительные работы оговариваются с заказчиком и вносятся в смету.',
  agreementText =
      'Ознакомлен и согласен_______________________________________________';

  // Error
  static const String emptyProjectNameError =
          'Название проекта не может быть пустым',
      emptyProjectError = 'Нельзя сохранить пустой проект',
      fileNotFoundError = 'Файл проекта не найден',
      saveError = 'Ошибка при сохранении',
      loadError = 'Ошибка при загрузке';
}

abstract class AppPadding {
  static const EdgeInsets all = EdgeInsets.all(AppConstants.defaultPadding),
      horizontal = EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      vertical = EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
      bottom = EdgeInsets.only(bottom: AppConstants.defaultPadding),
      top = EdgeInsets.only(top: AppConstants.defaultPadding);
}

abstract class AppBorderRadius {
  static const BorderRadius
  all = BorderRadius.all(Radius.circular(AppConstants.borderRadius)),
  top = BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadius)),
  bottom = BorderRadius.vertical(
    bottom: Radius.circular(AppConstants.borderRadius),
  );
}
