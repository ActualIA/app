import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:actualia/viewmodels/news.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Records news locally to retrieve them offline. Must be created through OfflineRecorder.create(newsProvider)$
/// Creates a folder named as ROOT_OFFLINE_RECORDER in application's, and then every daily news is stored in a file named "year-month-day_transcript.json"
/// When no storage left, the Offline Recorder deletes the oldest news
class OfflineRecorder {
  static const ROOT_OFFLINE_FOLDER = "storage";

  late final _appOfflineNewsPath;

  /// This number is computed to store approximately 2 weeks of news
  var _maxStorageSize = 17e+6.toInt(); // One minute mp3 file ~ 1MB

  /// Private Constructor to handle asynchronous declaration
  OfflineRecorder._create(String appOfflineNewsPath) {
    // Creating the root file to store the news
    _appOfflineNewsPath = appOfflineNewsPath;
  }

  /// Factory that create the Offline Recorder, if the storage folder doesn't exist yet, it creates it at the same time
  static Future<OfflineRecorder> create() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    String appOfflineNewsPath = "${appDir.path}/$ROOT_OFFLINE_FOLDER/";
    Directory appOfflineNewsFolder = Directory(appOfflineNewsPath);

    // If storage folder doesn't exist, creates it
    if (!(await appOfflineNewsFolder.exists())) {
      appOfflineNewsPath =
          (await appOfflineNewsFolder.create(recursive: true)).path;
    }

    return OfflineRecorder._create(appOfflineNewsPath);
  }

  /// Changes the size allocated for the storage folder, removes files if needed
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

  int currentMaxStorageSize() => _maxStorageSize;

  /// Cleans storage folder. The policy is to removing files starting by the oldest one, end let 25% of max storage free after the operation
  void _cleanStorage() async {
    Directory appOfflineNewsFolder = Directory(_appOfflineNewsPath);

    try {
      // Gathers all files, ignoring the ones not well formated
      var transcriptList = List<String>.empty();
      appOfflineNewsFolder
          .list(recursive: false, followLinks: false)
          .listen((FileSystemEntity file) {
        debugPrint("[CLEARSTORAGE] path: ${file.path}");
        if (file.path
            .substring(file.path.length - "XXXX-XX-XX_transcript.json".length)
            .startsWith(RegExp(r"[0-9]{4}-[0-9]{2}-[0-9]{2}"))) {
          transcriptList.add(file.path);
        }
      });

      // Sorts the files, to delete files starting from the oldest one (due to name policy, the most recent transcript is at the end), throws StorageException if no space is left even after recreating the folder with no file
      transcriptList.sort();
      // Reveerse the list to remove the transcripts from the end of the list (thus putting the oldest transcript at the end)
      transcriptList = transcriptList.reversed.toList();

      // Removes files one by one, until 25% of the storage is left free
      while (await _dirSize(appOfflineNewsFolder) >= (0.75 * _maxStorageSize) ||
          transcriptList.isEmpty) {
        if (File(transcriptList.last).existsSync()) {
          await File(transcriptList.last).delete();
        }
        transcriptList.removeLast();
      }

      // Edge case : if every file that can be removed has been removed and there is still no place, then throw an error to reset the folder
      if (transcriptList.isEmpty &&
          await _dirSize(appOfflineNewsFolder) >= _maxStorageSize) {
        throw const StorageException("No storage left");
      }
    } catch (e) {
      // If an error happen, recreate the whole folder (and thus deletes all files)
      if (await appOfflineNewsFolder.exists()) {
        appOfflineNewsFolder.delete(recursive: true);
      }

      await Directory(_appOfflineNewsPath).create(recursive: true);
    }

    // Checks that the is space left
    if (await _dirSize(appOfflineNewsFolder) >= _maxStorageSize) {
      throw const StorageException("No storage left");
    }
  }

  /// Provides the size, in bytes, of a directory
  Future<int> _dirSize(Directory dir) async {
    var files = await dir.list(recursive: true).toList();
    var dirSize = files.fold(0, (int sum, file) => sum + file.statSync().size);
    return dirSize;
  }

  /// Stores in the application's storage folder the given news
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

    if (await _dirSize(Directory(_appOfflineNewsPath)) >= _maxStorageSize) {
      _cleanStorage();
    }
  }

  Future<News?> _readNewsFile(File file) async {
    if (!(file.path
        .substring(file.path.length - "XXXX-XX-XX_transcript.json".length)
        .startsWith(RegExp(r"[0-9]{4}-[0-9]{2}-[0-9]{2}")))) {
      return null;
    }

    String json = await file.readAsString();

    // Parsing the json + remapping to a News object

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
        transcriptId: decodedJson["transcriptId"],
        audio: decodedJson["audio"],
        fullTranscript: decodedJson["fullTranscript"],
        paragraphs: paragraphs);
  }

  /// Gets the news of the given date, throws FileSystemException if the file containing the date's news doesn't exist
  Future<News> loadNews(DateTime date) async {
    // Sanitize inputs
    String day = date.day < 10 ? "0${date.day}" : date.day.toString();
    String month =
        date.month < 10 ? "0${date.month.toString()}" : date.month.toString();
    if (date.year < 1000) {
      throw Exception("The date is too far in the past");
    }

    String filePath =
        _appOfflineNewsPath + "${date.year}-$month-${day}_transcript.json";
    if (!await File(filePath).exists()) {
      throw FileSystemException("$filePath doesn't exist");
    }

    return _readNewsFile(File(filePath)).then((value) =>
        value ??
        (throw Exception("News for date ${date.toString()} doesn't exist")));
  }

  Future<List<News>> loadAllNews() async {
    final dir = Directory(_appOfflineNewsPath);
    final Iterable<File> files = (await dir.list().toList()).whereType<File>();

    List<News> news = List.empty(growable: true);
    for (var f in files) {
      await _readNewsFile(f).then((n) => {
            if (n != null) {news.add(n)}
          });
    }

    return Future.value(news);
  }
}
