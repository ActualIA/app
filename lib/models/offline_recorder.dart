import 'dart:convert';
import 'dart:io';
import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:actualia/viewmodels/news.dart';

/**
 * Records news locally to retrieve them offline. Must be created through OfflineRecorder.create(newsProvider)
 */
class OfflineRecorder {
  static const ROOT_OFFLINE_FOLDER = "storage";

  late final _appOfflineNewsPath;
  var _maxStorageSize = 17e+6.toInt(); // One minute mp3 file ~ 1MB

  OfflineRecorder._create(String appOfflineNewsPath) {
    // Creating the root file to store the news
    _appOfflineNewsPath = appOfflineNewsPath;
  }

  static Future<OfflineRecorder> create() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    String appOfflineNewsPath = "${appDir.path}/$ROOT_OFFLINE_FOLDER/";
    Directory appOfflineNewsFolder = Directory(appOfflineNewsPath);

    if (!(await appOfflineNewsFolder.exists())) {
      appOfflineNewsPath =
          (await appOfflineNewsFolder.create(recursive: true)).path;
    }

    return OfflineRecorder._create(appOfflineNewsPath);
  }

  Future<int> setMaxStorageSize(int newStorageSize) async {
    Directory appOfflineNewsFolder = Directory(_appOfflineNewsPath);

    if (!(await appOfflineNewsFolder.exists())) {
      await appOfflineNewsFolder.create(recursive: true);
    }

    if (await _dirSize(appOfflineNewsFolder) >= newStorageSize) {
      _cleanStorage();
    }

    _maxStorageSize = newStorageSize;

    return newStorageSize;
  }

  int getCurrentMaxStorageSize() {
    return _maxStorageSize;
  }

  /**
   * TODO : Only delete some files
   */
  void _cleanStorage() async {
    Directory appOfflineNewsFolder = Directory(_appOfflineNewsPath);

    try {
      var transcriptList = List<String>.empty();
      appOfflineNewsFolder
          .list(recursive: false, followLinks: false)
          .listen((FileSystemEntity file) {
        if (file.path
            .substring(file.path.length - "XXXX-XX-XX_transcript.json".length)
            .startsWith(RegExp(r"[0-9]{4}-[0-9]{2}-[0-9]{2}"))) {
          transcriptList.add(file.path);
        }
      });
      transcriptList.sort();
      // Most recent at the end
      transcriptList = transcriptList.reversed.toList();

      while (await _dirSize(appOfflineNewsFolder) >= (0.75 * _maxStorageSize)) {
        if (File(transcriptList.last).existsSync()) {
          await File(transcriptList.last).delete();
        }
        transcriptList.removeLast();
      }
    } catch (e) {
      // If an error happen, recreate the whole folder
      if (await appOfflineNewsFolder.exists()) {
        appOfflineNewsFolder.delete(recursive: true);
      }

      await Directory(_appOfflineNewsPath).create(recursive: true);
    }

    if (await appOfflineNewsFolder.exists()) {
      appOfflineNewsFolder.delete(recursive: true);
    }

    await Directory(_appOfflineNewsPath).create(recursive: true);
  }

  /**
   * Provides the size, in bytes, of a directory
   */
  Future<int> _dirSize(Directory dir) async {
    var files = await dir.list(recursive: true).toList();
    var dirSize = files.fold(0, (int sum, file) => sum + file.statSync().size);
    return dirSize;
  }

  Future<void> downloadNews(News news) async {
    Directory appOfflineNewsFolder = Directory(_appOfflineNewsPath);

    // Missing folder -> creates it, even if it should be created the first time the offline recorder is created
    if (!(await appOfflineNewsFolder.exists())) {
      await appOfflineNewsFolder.create(recursive: true);
    }

    String filePath =
        _appOfflineNewsPath + "${news.date.substring(0, 10)}_transcript.json";
    String json = jsonEncode(news);

    // Creates the file
    final file = File(filePath);

    // Cannot have two transcripts for the same day
    if (await file.exists()) {
      await file.delete();
    }

    await file.writeAsString(json);

    // TODO : Only delete oldest files when overflowing
    if (await _dirSize(Directory(_appOfflineNewsPath)) >= _maxStorageSize) {
      _cleanStorage();
    }
  }

  /**
   * Load data from local storage. Date must be formated in the following way : <year>-<month>-<day>
   */
  Future<News> loadNews(String date) async {
    RegExp regex = RegExp(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$");
    if (regex.allMatches(date).isEmpty) {
      throw UnimplementedError("Date String not well formated");
    }

    String filePath = _appOfflineNewsPath + "${date}_transcript.json";
    if (!await File(filePath).exists()) {
      throw FileSystemException("$filePath doesn't exist");
    }

    String json = await File(filePath).readAsString();

    dynamic decodedJson = jsonDecode(json);

    List<Paragraph> paragraphs = (decodedJson["paragraphs"] as List).map((p) {
      return Paragraph(
          transcript: p["transcript"],
          source: p["source"],
          url: p["url"],
          title: p["title"],
          date: p["date"],
          content: p["content"]);
    }).toList();

    return News(
        title: decodedJson["title"],
        date: decodedJson["date"],
        transcriptId: decodedJson["transcriptID"],
        audio: decodedJson["audio"],
        paragraphs: paragraphs);
  }
}
