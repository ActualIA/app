import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:actualia/models/news.dart';
import 'package:actualia/models/offline_recorder.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_recorder.dart';
import 'offline_recorder_and_supabse_mocks/mock_file.dart';
import 'offline_recorder_and_supabse_mocks/mock_filesystem.dart';
import 'offline_recorder_and_supabse_mocks/supabase_mock.dart';

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  User? get currentUser => const User(
      id: "1234",
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{},
      aud: "aud",
      createdAt: "createdAt");
}

class FakeFailingQueryBuilder extends Fake implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder upsert(Object values,
      {String? onConflict,
      bool ignoreDuplicates = false,
      bool defaultToNull = true}) {
    final Map<String, dynamic> dict = values as Map<String, dynamic>;

    expect(dict["created_by"], equals("1234"));
    expect(listEquals(dict["cities"], []), isTrue);
    expect(listEquals(dict["countries"], []), isTrue);
    expect(listEquals(dict["interests"], ["Biology"]), isTrue);
    expect(dict["wantsCities"], isFalse);
    expect(dict["wantsCountries"], isFalse);
    expect(dict["wantsInterests"], isTrue);

    throw UnimplementedError();
  }
}

class FakeFailingFunctionsClient extends Fake implements FunctionsClient {
  @override
  Future<FunctionResponse> invoke(String functionName,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      HttpMethod method = HttpMethod.post,
      Map<String, dynamic>? queryParameters}) {
    throw UnimplementedError();
  }
}

class FakeFailingSupabaseClient extends Fake implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) {
    expect(table, equals("news_settings"));
    return FakeFailingQueryBuilder();
  }

  @override
  GoTrueClient get auth => FakeGoTrueClient();

  @override
  FunctionsClient get functions => FakeFailingFunctionsClient();
}

class FakeFunctionsClient extends Fake implements FunctionsClient {
  @override
  Future<FunctionResponse> invoke(String functionName,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      HttpMethod method = HttpMethod.post,
      Map<String, dynamic>? queryParameters}) {
    expect(functionName, equals('generate-transcript'));
    expect(body, equals({}));
    expect(method, equals(HttpMethod.post));

    return Future.value(FunctionResponse(status: 200));
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  FunctionsClient get functions => FakeFunctionsClient();
}

class MockFailingOfflineRecorder extends Fake implements OfflineRecorder {
  @override
  Future<void> downloadNews(News news) async {}
}

class MockOfflineRecorder extends Fake implements OfflineRecorder {
  @override
  Future<void> downloadNews(News news) {
    return Future(() => null);
  }

  @override
  Future<List<News>> loadAllNews() {
    return Future(() => List.empty());
  }

  @override
  Future<News> loadNews(DateTime date) {
    return Future(() => News(
        title: "test",
        date: "test",
        transcriptId: 17,
        audio: "test",
        paragraphs: List.empty(),
        fullTranscript: ""));
  }
}

class AlreadyExistingNewsVM extends NewsViewModel {
  AlreadyExistingNewsVM.create(super.supabase) : super.create();

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(News(
        date: DateTime.now().toIso8601String(),
        title: "News",
        transcriptId: -1,
        audio: null,
        paragraphs: [
          Paragraph(
              transcript: "text",
              source: "source",
              title: "title",
              date: "12-04-2024",
              content: "content",
              url: "url")
        ],
        fullTranscript: "fullTranscript"));
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() {
    fail("invokeTranscriptFunction should not be called");
  }
}

class NonExistingNewsVM extends NewsViewModel {
  bool invokedTranscriptFunction = false;

  NonExistingNewsVM.create() : super.create(FakeSupabaseClient());

  static Future<NonExistingNewsVM> init() async {
    NonExistingNewsVM nvm = NonExistingNewsVM.create();
    nvm.offlineRecorder = MockOfflineRecorder();
    return nvm;
  }

  @override
  Future<void> fetchNews(DateTime date) {
    if (invokedTranscriptFunction) {
      setNews(
        News(
            date: DateTime.now().toIso8601String(),
            title: "News",
            transcriptId: -1,
            audio: null,
            paragraphs: [
              Paragraph(
                  transcript: "text",
                  source: "source",
                  title: "title",
                  date: "12-04-2024",
                  content: "content",
                  url: "url")
            ],
            fullTranscript: "fullTranscript"),
      );
    } else {
      setNews(null);
    }
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() async {
    invokedTranscriptFunction = true;
  }
}

class NeverExistingNewsVM extends NewsViewModel {
  NeverExistingNewsVM.create() : super.create(FakeSupabaseClient());

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(null);
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() async {}
}

class NewsListVM extends NewsViewModel {
  NewsListVM.create(super.supabase) : super.create();

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(News(
        date: DateTime.now().toIso8601String(),
        title: "News",
        transcriptId: -1,
        audio: null,
        paragraphs: [
          Paragraph(
              transcript: "text",
              source: "source",
              title: "title",
              date: "12-04-2024",
              content: "content",
              url: "url")
        ],
        fullTranscript: "fullTranscript"));
    return Future.value();
  }

  @override
  Future<List<dynamic>> fetchNewsList() async {
    return Future.value([
      {
        "date": DateTime.now().toIso8601String(),
        "title": "News",
        "id": -1,
        "audio": null,
        "transcript": {
          "fullTranscript": "fullTranscript",
          "news": [
            {
              "transcript": "text",
              "url": "url",
              "source": {"name": "source", "url": "url"},
              "title": "title",
              "publishedAt": "12-04-2024",
              "content": "content"
            }
          ]
        }
      }
    ]);
  }

  @override
  Future<void> invokeTranscriptFunction() {
    fail("invokeTranscriptFunction should not be called");
  }

  @override
  Future<void> generateAndGetNews() {
    return Future.value();
  }

  @override
  Future<void> getAudioFile(News news) {
    return Future.value();
  }
}

class NewsList2VM extends NewsViewModel {
  NewsList2VM.create(super.supabase) : super.create();
  bool invokedTranscriptFunction = false;
  bool fetchNewsCalled = false;

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(null);
    fetchNewsCalled = true;
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() {
    invokedTranscriptFunction = true;
    return Future.value();
  }
}

class EmptyNewsListVM extends NewsViewModel {
  EmptyNewsListVM.create(super.supabase) : super.create();
  bool generateNewsCalled = false;

  @override
  Future<List<dynamic>> fetchNewsList() async {
    return Future.value([]);
  }
}

class ExceptionNewsListVM extends NewsViewModel {
  ExceptionNewsListVM.create(super.supabase) : super.create();

  @override
  Future<List<dynamic>> fetchNewsList() async {
    throw Exception();
  }
}

class NotTodayNewsListVM extends NewsViewModel {
  NotTodayNewsListVM.create(super.supabase) : super.create();
  bool generateNewsCalled = false;

  @override
  Future<void> generateAndGetNews() {
    generateNewsCalled = true;
    return Future.value();
  }

  @override
  Future<List<dynamic>> fetchNewsList() async {
    return Future.value([
      {
        "date": "2022-04-12T00:00:00.000Z",
        "title": "News",
        "id": -1,
        "audio": null,
        "transcript": {"fullTranscript": "", "news": []}
      }
    ]);
  }
}

//Tests for audio functions

class AudioNewsVM extends NewsViewModel {
  AudioNewsVM.create(super.supabase) : super.create();
  bool generateAudioCalled = false;

  @override
  Future<String> generateAudio(int transcriptId) {
    generateAudioCalled = true;
    return Future.value("audio");
  }
}

class MockAppLoc extends Fake implements AppLocalizations {
  final String errorNewsFetch = "Unable to fetch news.";
  final String errorNoNews = "There are no news for you on this date.";
  final String errorNewsGeneration =
      "Something went wrong while generating news. Please try again later.";
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test("generate-transcript failure is reported", () async {
    NewsViewModel vm = NewsViewModel.create(FakeFailingSupabaseClient());
    bool hasThrown = false;

    try {
      await vm.invokeTranscriptFunction();
    } catch (e) {
      hasThrown = true;
    }

    expect(hasThrown, isTrue);
  });

  test("correctly invokes cloud function", () async {
    NewsViewModel vm = NewsViewModel.create(FakeSupabaseClient());
    await vm.invokeTranscriptFunction();
  });

  test('database failure is handled', () async {
    NewsViewModel vm = NewsViewModel.create(FakeFailingSupabaseClient());
    await vm.fetchNews(DateTime.now());
    expect(vm.news, isNull);
  });

  test('already existing news are correctly fetched', () async {
    NewsViewModel vm = AlreadyExistingNewsVM.create(FakeSupabaseClient());
    vm.offlineRecorder = MockOfflineRecorder();
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News"));
  });

  test('non existing news are correctly generated', () async {
    NonExistingNewsVM vm = await NonExistingNewsVM.init();
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News"));
    expect(vm.invokedTranscriptFunction, isTrue);
  });

  test('getNews with invalid date reports error', () async {
    NewsViewModel vm = NewsViewModel.create(FakeSupabaseClient());
    vm.offlineRecorder = MockOfflineRecorder();
    await vm.getNews(DateTime.fromMicrosecondsSinceEpoch(0));
    expect(vm.hasError, isTrue);
  });

  test('getNews with non working EF reports error', () async {
    NewsViewModel vm = NeverExistingNewsVM.create();
    vm.offlineRecorder = MockOfflineRecorder();
    await vm.getNews(DateTime.now());
    expect(vm.hasError, isTrue);
  });

  test('getNewsList with non working EF reports error', () async {
    NewsViewModel vm = NeverExistingNewsVM.create();
    vm.offlineRecorder = MockFailingOfflineRecorder();
    await vm.getNewsList();
    expect(vm.hasError, isTrue);
  });

  test('getNewsList with working EF returns correct list', () async {
    NewsListVM vm = NewsListVM.create(FakeSupabaseClient());
    vm.offlineRecorder = MockFailingOfflineRecorder();
    await vm.getNewsList();
    expect(vm.newsList, isNotNull);
    expect(vm.newsList!.length, equals(1));
    expect(vm.newsList![0].title, equals("News"));
    expect(vm.newsList![0].paragraphs[0].source, equals("source"));
    expect(vm.newsList![0].paragraphs[0].title, equals("title"));
    expect(vm.newsList![0].paragraphs[0].content, equals("content"));
  });

  test('getNewsList with Empty list sets hasNews to false', () async {
    EmptyNewsListVM vm = EmptyNewsListVM.create(FakeSupabaseClient());
    vm.offlineRecorder = MockOfflineRecorder();
    await vm.getNewsList();
    expect(vm.newsList, isEmpty);
    expect(vm.isEmpty, isTrue);
  });

  test('getNewsList with Exception reports error', () async {
    ExceptionNewsListVM vm = ExceptionNewsListVM.create(FakeSupabaseClient());
    vm.offlineRecorder = MockFailingOfflineRecorder();
    await vm.getNewsList();
    expect(vm.hasError, isTrue);
  });

  test('getNewsList with non-today news generates news', () async {
    NotTodayNewsListVM vm = NotTodayNewsListVM.create(FakeSupabaseClient());
    vm.offlineRecorder = MockFailingOfflineRecorder();
    await vm.getNewsList();
    expect(vm.generateNewsCalled, isTrue);
  });

  test('generateAndGetNews calls invoke and fetchNews', () async {
    NewsList2VM vm = NewsList2VM.create(FakeSupabaseClient());
    // ignore: invalid_use_of_protected_member
    await vm.generateAndGetNews();
    expect(vm.invokedTranscriptFunction, isTrue);
    expect(vm.fetchNewsCalled, isTrue);
  });

  test('setNewsError is called when news is null', () async {
    NewsList2VM vm = NewsList2VM.create(FakeSupabaseClient());
    // ignore: invalid_use_of_protected_member
    await vm.generateAndGetNews();
    expect(vm.hasError, isTrue);
  });

  // Test generateAudio is called
  test('generateAudio is called when audio is null', () async {
    AudioNewsVM vm = AudioNewsVM.create(FakeSupabaseClient());
    await vm.getAudioFile(News(
        date: DateTime.now().toIso8601String(),
        title: "News",
        transcriptId: 1,
        audio: null,
        paragraphs: [
          Paragraph(
              transcript: "text",
              source: "source",
              title: "title",
              date: "12-04-2024",
              content: "content",
              url: "url")
        ],
        fullTranscript: "fullTranscript"));
    expect(vm.generateAudioCalled, isTrue);
  });

  test("getAudioSource work as intended", () async {
    PathProviderPlatform.instance = MockPathProviderPlateform();
    MockFileSys files = MockFileSys();
    IOOverrides.global = MockIOOverrides(files);

    //dummy transcript
    News news = News(
        title: "dummy",
        date: DateTime.now().toIso8601String(),
        transcriptId: 1,
        audio: "dummy",
        paragraphs: [
          Paragraph(
              transcript: "text",
              source: "source",
              url: "url",
              title: "title",
              date: "12-04-2024",
              content: "content")
        ],
        fullTranscript: "fullTranscript");

    //store dummy transcript
    MockFile audio = MockFile(
        "${(await getApplicationDocumentsDirectory()).path}/audios/1.mp3",
        files);
    files.addFile(audio, news.toString());

    NewsViewModel vm = NewsViewModel(FakeSupabaseClient());

    expect((await vm.getAudioSource(1)).toString(),
        equals(DeviceFileSource(audio.path).toString()));
  });

  test("getErrorMessage works as intended", () async {
    NewsViewModel vm = NewsViewModel(FakeSupabaseClient());
    vm.setError(ErrorType.fetch);
    expect(vm.getErrorMessage(MockAppLoc()), "Unable to fetch news.");
    vm.setError(ErrorType.noNews);
    expect(vm.getErrorMessage(MockAppLoc()),
        "There are no news for you on this date.");
    vm.setError(ErrorType.generation);
    expect(vm.getErrorMessage(MockAppLoc()),
        "Something went wrong while generating news. Please try again later.");
  });

  test("fetchNews work as intended with existing news", () async {
    PathProviderPlatform.instance = MockPathProviderPlateform();
    MockFileSys files = MockFileSys();
    IOOverrides.global = MockIOOverrides(files);
    FakeDB db = FakeDB([], [
      {
        "id": 1,
        "user": "1234",
        "title": "title",
        "transcript": {
          "totalNews": 1,
          "totalNewsByLLM": "10",
          "intro": "intro",
          "outro": "outro",
          "fullTranscript": "blablabla",
          "news": [
            {
              "transcript": "blablabla",
              "title": "title",
              "description": "description",
              "content": "content",
              "url": "url",
              "image": "image.jpg",
              "publishedAt": "2023-05-02T21:29:00.000Z",
              "source": {"name": "name", "url": "url"}
            }
          ]
        },
        "date": DateTime.now().toIso8601String(),
        "audio": "audio",
        "is_public": false
      },
    ]);
    NewsViewModel vm = await NewsViewModel.init(db); //NewsViewModel(db);
    vm.fetchNews(DateTime.now());
  });
}
