import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smeta_maker/data/app_constants.dart';

class UpdateService {
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    final url = Uri.parse(AppConstants.latestReleaseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final latestTag = data['tag_name'];

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = 'v${packageInfo.version}';

      final isUpdateAvailable = _isVersionNewer(latestTag, currentVersion);
      return {
        AppConstants.updateAvailableKey: isUpdateAvailable,
        AppConstants.latestVersionKey: latestTag,
        AppConstants.downloadUrlKey: data['assets'][0]['browser_download_url'],
      };
    } else {
      throw Exception('Ошибка при получении данных с GitHub');
    }
  }

  static bool _isVersionNewer(String latest, String current) {
    List<int> parseVersion(String v) =>
        v.replaceAll('v', '').split('.').map(int.parse).toList();

    final latestParts = parseVersion(latest);
    final currentParts = parseVersion(current);

    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}
