import 'dart:io';
import 'package:actualia/models/news.dart';
import 'package:path_provider/path_provider.dart';

import 'package:actualia/viewmodels/news.dart';

/**
 * Records news locally to retrieve them offline. Must be created through OfflineRecorder.create(newsProvider)
 */
class OfflineRecorder {
  static const ROOT_OFFLINE_FOLDER = "offlineNews";

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

  static Map<String, dynamic> serializeNews(News news) {
    List<Map<String, String>> paragraphs = [];
    for (Paragraph p in news.paragraphs) {
      paragraphs.add({
        "title": p.title,
        "date": p.date,
        "content": p.content,
        "source": p.source
      });
    }

    Map<String, String> serializedNews = {
      "title": news.title.toString(),
      "date": news.date.toString(),
      "transcriptID": news.transcriptID.toString(),
      "paragraphs": paragraphs.toString(),
    };

    return serializedNews;
  }

  static News deserializeNews(Map<String, dynamic> storedNews) {
    List<Paragraph> paragraphs = List.empty();
    for (Map<String, String> p in storedNews["paragraphs"]) {
      paragraphs.add(Paragraph(
          transcript: storedNews["transcriptID"],
          source: p["source"]!,
          title: p["title"]!,
          date: p["date"]!,
          content: p["content"]!));
    }

    return News(
        audio: "",
        title: storedNews["title"],
        date: storedNews["date"],
        transcriptID: int.parse(storedNews["transcriptID"]),
        paragraphs: paragraphs);
  }
}
