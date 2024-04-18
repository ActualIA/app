import 'dart:io';
import 'dart:path_provider';

import 'package:actualia/viewmodels/news.dart';

/**
 * Records news locally to retrieve them offline. Must be created through OfflineRecorder.create(newsProvider)
 */
class OfflineRecorder {
  static final ROOT_OFFLINE_FOLDER = "offlineNews";

  late final _newsProvider;
  late final _appOfflineNewsPath;

  OfflineRecorder._create(
      NewsViewModel newsProvider, Directory appOfflineNewsPath) {
    // Getting the news provider
    late final _newsProvider = newsProvider;

    // Creating the root file to store the news
    _appOfflineNewsPath = appOfflineNewsPath;
  }

  static Future<OfflineRecorder> create(NewsViewModel newsProvider) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    Directory appOfflineNewsPath =
        Directory("${appDir.path}/${ROOT_OFFLINE_FOLDER}/");

    if (!(await appOfflineNewsPath.exists())) {
      appOfflineNewsPath = await appOfflineNewsPath.create(recursive: true);
    }

    return OfflineRecorder._create(newsProvider, appOfflineNewsPath);
  }
}
