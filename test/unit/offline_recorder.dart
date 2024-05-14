import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'package:actualia/models/news.dart';
import 'package:actualia/models/offline_recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:path_provider_ios/path_provider_ios.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

News testNews = News(
    title: "Test title",
    date: "2002-10-17",
    transcriptID: 0,
    audio: null,
    paragraphs: [
      Paragraph(
          transcript: "0",
          title:
              "Local bakery wins national award for innovative cupcake flavors, residents celebrate with free tastings. Mayor commends efforts, hails bakery as symbol of community creativity and entrepreneurship.",
          date: "2003-12-11",
          content:
              "The local bakery's triumph in clinching a prestigious national award for its inventive cupcake flavors has set the town abuzz with excitement. In a jubilant display of community spirit, residents flock to the bakery for complimentary tastings, reveling in the delectable creations that have put their hometown on the culinary map. As the aroma of freshly baked treats fills the air, the mayor takes to the podium, praising the bakery's dedication to pushing culinary boundaries and showcasing the town's entrepreneurial spirit. With a heartfelt commendation, the mayor lauds the bakery as more than just a purveyor of sweets; it's a symbol of the community's ingenuity and innovation. Amidst cheers and applause, the bakery stands as a testament to the power of local businesses in fostering creativity and unity within the neighborhood.",
          source:
              "This news comes from \"The Daily Gazette,\" a renowned source for community updates and local achievements, highlighting the innovative cupcake flavors and celebratory atmosphere at a nearby bakery."),
      Paragraph(
          transcript:
              "In a groundbreaking study published by \"The Mindful Worker,\" researchers unveil unexpected advantages of meditation in boosting workplace productivity. Findings suggest that regular meditation practices can significantly enhance focus and efficiency.",
          title:
              "Groundbreaking Study Reveals Surprising Benefits of Meditation on Workplace Productivity",
          date: "2002-04-08",
          content:
              "\"The Mindful Worker\" study breaks new ground, revealing meditation's unexpected role in workplace productivity. Researchers find regular meditation enhances focus and efficiency, offering a potent tool for navigating modern work demands. As the study gains traction, workplaces consider integrating mindfulness practices to foster a more conducive environment for optimal performance. This paradigm shift underscores the symbiotic relationship between mental well-being and professional success, heralding a new era in workplace dynamics.",
          source:
              "This news comes from \"The Mindful Worker,\" a leading publication dedicated to exploring the intersection of mindfulness and professional success."),
    ]);

const file ROOT = "/mockRoot";
typedef Dir = Map<String, dynamic>;
typedef file = String;

class MockFileSys {
  Dir FILES = {ROOT: <String, dynamic>{}};

  void add(MockDir dir) {
    List<String> path = dir.path.split('/');
    path.removeAt(path.length - 1);
    path.removeAt(0);
    Dir temp =
        path.reversed.fold(<String, dynamic>{}, (previousValue, element) {
      Map<String, dynamic> res = {element: previousValue};
      return res;
    });
    debugPrint("[DEBUG] temp: $temp");
  }
}

class MockPathProviderPlateform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    debugPrint("[DEBUG] mock path provider platform called");
    return ROOT;
  }
}

class MockIOOverrides extends IOOverrides {
  MockFileSys files;

  MockIOOverrides(this.files);

  @override
  Directory createDirectory(String path) => MockDir(path, files);
}

class MockDir implements Directory {
  late final String _path;

  MockDir(String path, MockFileSys files) {
    _path = path;
    files.add(this);
  }

  @override
  // TODO: implement absolute
  Directory get absolute => throw UnimplementedError();

  @override
  Future<Directory> create({bool recursive = false}) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  void createSync({bool recursive = false}) {
    // TODO: implement createSync
  }

  @override
  Future<Directory> createTemp([String? prefix]) {
    // TODO: implement createTemp
    throw UnimplementedError();
  }

  @override
  Directory createTempSync([String? prefix]) {
    // TODO: implement createTempSync
    throw UnimplementedError();
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  void deleteSync({bool recursive = false}) {
    // TODO: implement deleteSync
  }

  @override
  Future<bool> exists() {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  bool existsSync() {
    // TODO: implement existsSync
    throw UnimplementedError();
  }

  @override
  // TODO: implement isAbsolute
  bool get isAbsolute => throw UnimplementedError();

  @override
  Stream<FileSystemEntity> list(
      {bool recursive = false, bool followLinks = true}) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  List<FileSystemEntity> listSync(
      {bool recursive = false, bool followLinks = true}) {
    // TODO: implement listSync
    throw UnimplementedError();
  }

  @override
  // TODO: implement parent
  Directory get parent => throw UnimplementedError();

  @override
  // TODO: implement path
  String get path => _path;

  @override
  Future<Directory> rename(String newPath) {
    // TODO: implement rename
    throw UnimplementedError();
  }

  @override
  Directory renameSync(String newPath) {
    // TODO: implement renameSync
    throw UnimplementedError();
  }

  @override
  Future<String> resolveSymbolicLinks() {
    // TODO: implement resolveSymbolicLinks
    throw UnimplementedError();
  }

  @override
  String resolveSymbolicLinksSync() {
    // TODO: implement resolveSymbolicLinksSync
    throw UnimplementedError();
  }

  @override
  Future<FileStat> stat() {
    // TODO: implement stat
    throw UnimplementedError();
  }

  @override
  FileStat statSync() {
    // TODO: implement statSync
    throw UnimplementedError();
  }

  @override
  // TODO: implement uri
  Uri get uri => throw UnimplementedError();

  @override
  Stream<FileSystemEvent> watch(
      {int events = FileSystemEvent.all, bool recursive = false}) {
    // TODO: implement watch
    throw UnimplementedError();
  }
}

void main() {
  // Allows async functions in main
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid) PathProviderAndroid.registerWith();
  // if (Platform.isIOS) PathProviderIOS.registerWith();

  test("Correct Serialisation and Deserialization", () {
    expect(News.fromJson(testNews.toJson()), equals(testNews));
  });

  test(
      "Creating an offline recorder creates the folder where transcripts will be stored",
      () async {
    PathProviderPlatform.instance = MockPathProviderPlateform();
    IOOverrides.global = MockIOOverrides(MockFileSys());
    await OfflineRecorder.create();
    Directory appDir = await getApplicationDocumentsDirectory();

    expect(Directory("${appDir.path}/storage/").exists(), isTrue);
  });

  test("Storing and retrieveing news", () async {
    Directory storage = Directory(
        "${(await getApplicationDocumentsDirectory()).path}/storage/");
    OfflineRecorder offRec = await OfflineRecorder.create();

    offRec.downloadNews(testNews);

    expect(
        File("${storage.path}/${testNews.date.substring(0, 10)}_transcript.json")
            .exists(),
        isTrue);
    expect(offRec.loadNews(testNews.date.substring(0, 10)), equals(testNews));

    File("${storage.path}/${testNews.date.substring(0, 10)}_transcript.json")
        .delete();
  });

  test("Loading non existing files throw errors", () async {
    OfflineRecorder offRec = await OfflineRecorder.create();
    expect(offRec.loadNews("UNE MINE !"), throwsUnimplementedError);
    expect(offRec.loadNews("0476-09-04"), throwsException);
  });

  test("Changing the maximum storage size works well in both directions",
      () async {
    Directory storage = Directory(
        "${(await getApplicationDocumentsDirectory()).path}/storage/");
    OfflineRecorder offRec = await OfflineRecorder.create();
    int storageSize = offRec.getCurrentMaxStorageSize();
    offRec.setMaxStorageSize(storageSize + (17e6 as int));
    expect(
        offRec.getCurrentMaxStorageSize(), equals(storageSize + (17e6 as int)));

    offRec.setMaxStorageSize(storageSize);

    offRec.downloadNews(testNews);
    expect(offRec.getCurrentMaxStorageSize(), equals(storageSize));

    int fileSize = File(
            "${storage.path}/${testNews.date.substring(0, 10)}_transcript.json")
        .statSync()
        .size;
    offRec.setMaxStorageSize(fileSize - 100);
    expect(offRec.getCurrentMaxStorageSize(), equals(fileSize - 100));
    expect(
        File("${storage.path}/${testNews.date.substring(0, 10)}_transcript.json")
            .exists(),
        isFalse);

    offRec.setMaxStorageSize(storageSize);
  });
}
