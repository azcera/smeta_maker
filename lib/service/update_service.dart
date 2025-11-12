import 'dart:convert';
import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smeta_maker/data/app_constants.dart';

abstract class UpdateService {
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    final url = Uri.parse(AppConstants.latestReleaseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final latestTag = data['tag_name'];

      final package = await PackageInfo.fromPlatform();

      final isUpdateAvailable = _isVersionNewer(latestTag, package.version);
      return {
        AppConstants.updateAvailableKey: isUpdateAvailable,
        AppConstants.latestVersionKey: latestTag,
        AppConstants.downloadUrlKey: _getApkUpdateLink(data),
      };
    } else {
      throw Exception('Ошибка при получении данных с GitHub');
    }
  }

  static String _getApkUpdateLink(Map data) {
    final List<dynamic> assets = data['assets'];
    String link = '';
    for (int i = 0; i < assets.length; i++) {
      String item = assets[i]!['browser_download_url'];
      if (item.contains('.apk')) {
        link = item;
        break;
      }
    }
    return link;
  }

  static bool _isVersionNewer(String latest, String current) {
    List<int> parseVersion(String v) => v
        .replaceAll('v', '')
        .replaceAll(RegExp(r'-.*$'), '')
        .split('.')
        .map(int.parse)
        .toList();

    final latestParts = parseVersion(latest);
    final currentParts = parseVersion(current);

    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static Future<void> downloadAndInstallApk(String url) async {
    final status = await Permission.storage.request();
    final statusInstall = await Permission.requestInstallPackages.request();
    if (!status.isGranted || !statusInstall.isGranted) {
      print('Нет разрешения');
      return;
    }

    final dir = await getExternalStorageDirectory();
    final savePath = '${dir!.path}/update.apk';

    // Регистрируем callback
    FlutterDownloader.registerCallback((id, status, progress) async {
      if (status == DownloadTaskStatus.complete) {
        print('Загрузка завершена');
        await InstallPlugin.installApk(savePath);
      } else if (status == DownloadTaskStatus.failed) {
        print('Загрузка не удалась');
      }
    });

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: dir.path,
      fileName: 'update.apk',
      showNotification: true,
      openFileFromNotification: false,
    );

    print('Задача загрузки поставлена: $taskId');
  }

  static Future<void> downloadAndRunInstaller(String url) async {
    final tempDir = await getTemporaryDirectory();
    final installerPath = '${tempDir.path}\\update_installer.exe';

    final response = await http.get(Uri.parse(url));
    final file = File(installerPath);
    await file.writeAsBytes(response.bodyBytes);

    if (!file.existsSync()) {
      print('Ошибка: файл установщика не найден!');
      return;
    }
    await Process.start(installerPath, [
      '/VERYSILENT',
      '/NORESTART',
    ], mode: ProcessStartMode.detached);
    exit(0);
  }
}
