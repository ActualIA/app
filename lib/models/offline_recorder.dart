import 'dart:io';
import 'package:actualia/models/news.dart';
import 'package:path_provider/path_provider.dart';

import 'package:actualia/viewmodels/news.dart';

/**
 * Records news locally to retrieve them offline. Must be created through OfflineRecorder.create(newsProvider)
 */
class OfflineRecorder {
  static const ROOT_OFFLINE_FOLDER = "storage";

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
