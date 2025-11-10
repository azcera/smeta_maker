import 'package:file_selector/file_selector.dart';

class SettingsModel {
  final String name;
  final XFile? uploadedFile;
  final bool isTotalsShown;

  const SettingsModel({
    required this.name,
    required this.uploadedFile,
    required this.isTotalsShown,
  });

  static const _sentinel = Object();

  SettingsModel copyWith({
    String? name,
    Object? uploadedFile = _sentinel,
    bool? isTotalsShown,
  }) {
    final XFile? newUploadedFile = identical(uploadedFile, _sentinel)
        ? this.uploadedFile
        : uploadedFile as XFile?;
    return SettingsModel(
      name: name ?? this.name,
      uploadedFile: newUploadedFile,
      isTotalsShown: isTotalsShown ?? this.isTotalsShown,
    );
  }
}
