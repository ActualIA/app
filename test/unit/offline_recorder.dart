import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'package:actualia/models/news.dart';
import 'package:actualia/models/offline_recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'offline_recorder_mocks/mock_directory.dart';
import 'offline_recorder_mocks/mock_file.dart';
import 'offline_recorder_mocks/mock_filesystem.dart';

News testNews = News(
    title: "Test title",
    date: "2002-10-17",
    transcriptId: 0,
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
              "This news comes from \"The Daily Gazette,\" a renowned source for community updates and local achievements, highlighting the innovative cupcake flavors and celebratory atmosphere at a nearby bakery.",
          url: ''),
      Paragraph(
          transcript:
              "In a groundbreaking study published by \"The Mindful Worker,\" researchers unveil unexpected advantages of meditation in boosting workplace productivity. Findings suggest that regular meditation practices can significantly enhance focus and efficiency.",
          title:
              "Groundbreaking Study Reveals Surprising Benefits of Meditation on Workplace Productivity",
          date: "2002-04-08",
          content:
              "\"The Mindful Worker\" study breaks new ground, revealing meditation's unexpected role in workplace productivity. Researchers find regular meditation enhances focus and efficiency, offering a potent tool for navigating modern work demands. As the study gains traction, workplaces consider integrating mindfulness practices to foster a more conducive environment for optimal performance. This paradigm shift underscores the symbiotic relationship between mental well-being and professional success, heralding a new era in workplace dynamics.",
          source:
              "This news comes from \"The Mindful Worker,\" a leading publication dedicated to exploring the intersection of mindfulness and professional success.",
          url: ""),
    ]);

class MockPathProviderPlateform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    // debugPrint("[DEBUG] mock path provider platform called");
    return ROOT;
  }
}

class MockIOOverrides extends IOOverrides {
  MockFileSys files;

  MockIOOverrides(this.files);

  @override
  Directory createDirectory(String path) {
    // debugPrint("[CREATEDIR] path: $path");
    return MockDir(path, files);
  }

  @override
  File createFile(String path) {
    // debugPrint("[CREATEFILE] path: $path");
    return MockFile(path, files, size: path.length);
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

    expect(await Directory("${appDir.path}/storage/").exists(), isTrue);
  });

  test("Storing and retrieveing news", () async {
    PathProviderPlatform.instance = MockPathProviderPlateform();
    IOOverrides.global = MockIOOverrides(MockFileSys());

    Directory storage =
        Directory("${(await getApplicationDocumentsDirectory()).path}/storage");
    OfflineRecorder offRec = await OfflineRecorder.create();

    await offRec.downloadNews(testNews);

    bool exist = await File(
            "${storage.path}/${testNews.date.substring(0, 10)}_transcript.json")
        .exists();
    expect(exist, isTrue);
    expect(
        await offRec.loadNews(DateTime(
            int.parse(testNews.date.substring(0, 4)),
            int.parse(testNews.date.substring(5, 7)),
            int.parse(testNews.date.substring(8, 10)))),
        equals(testNews));
  });

  test("Loading non existing files throw errors", () async {
    PathProviderPlatform.instance = MockPathProviderPlateform();
    IOOverrides.global = MockIOOverrides(MockFileSys());
    OfflineRecorder offRec = await OfflineRecorder.create();
    expect(offRec.loadNews(DateTime(476, 9, 1)), throwsException);
  });

  test("Changing the maximum storage size works well in both directions",
      () async {
    PathProviderPlatform.instance = MockPathProviderPlateform();
    IOOverrides.global = MockIOOverrides(MockFileSys());
    Directory storage = Directory(
        "${(await getApplicationDocumentsDirectory()).path}/storage/");
    OfflineRecorder offRec = await OfflineRecorder.create();
    int storageSize = offRec.currentMaxStorageSize();
    await offRec.setMaxStorageSize(storageSize + (17e6.toInt()));
    expect(
        offRec.currentMaxStorageSize(), equals(storageSize + (17e6.toInt())));

    await offRec.setMaxStorageSize(storageSize);

    await offRec.downloadNews(testNews);
    expect(offRec.currentMaxStorageSize(), equals(storageSize));

    int fileSize = File(
            "${storage.path}/${testNews.date.substring(0, 10)}_transcript.json")
        .statSync()
        .size;
    await offRec.setMaxStorageSize(fileSize - 1);
    expect(offRec.currentMaxStorageSize(), equals(fileSize - 1));
    expect(
        await File(
                "${storage.path}/${testNews.date.substring(0, 10)}_transcript.json")
            .exists(),
        isFalse);
  });
}
