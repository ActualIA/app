import 'package:actualia/models/news.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      HttpMethod method = HttpMethod.post}) {
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
      HttpMethod method = HttpMethod.post}) {
    expect(functionName, equals('generate-transcript'));
    expect(body, isNull);
    expect(method, equals(HttpMethod.post));

    return Future.value(FunctionResponse(status: 200));
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  FunctionsClient get functions => FakeFunctionsClient();
}

class AlreadyExistingNewsVM extends NewsViewModel {
  AlreadyExistingNewsVM(super.supabase);

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(News(
        date: DateTime.now().toIso8601String(),
        title: "News",
        transcriptID: -1,
        audio: null,
        paragraphs: [
          Paragraph(
              transcript: "text",
              source: "source",
              title: "title",
              date: "12-04-2024",
              content: "content")
        ]));
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() {
    fail("invokeTranscriptFunction should not be called");
  }
}

class NonExistingNewsVM extends NewsViewModel {
  bool invokedTranscriptFunction = false;

  NonExistingNewsVM() : super(FakeSupabaseClient());

  @override
  Future<void> fetchNews(DateTime date) {
    if (invokedTranscriptFunction) {
      setNews(News(
          date: DateTime.now().toIso8601String(),
          title: "News",
          transcriptID: -1,
          audio: null,
          paragraphs: [
            Paragraph(
                transcript: "text",
                source: "source",
                title: "title",
                date: "12-04-2024",
                content: "content")
          ]));
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
  NeverExistingNewsVM() : super(FakeSupabaseClient());

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(null);
    return Future.value();
  }

  @override
  Future<void> invokeTranscriptFunction() async {}
}

class NewsListVM extends NewsViewModel {
  NewsListVM(SupabaseClient super.supabase);

  @override
  Future<void> fetchNews(DateTime date) {
    setNews(News(
        date: DateTime.now().toIso8601String(),
        title: "News",
        transcriptID: -1,
        audio: null,
        paragraphs: [
          Paragraph(
              transcript: "text",
              source: "source",
              title: "title",
              date: "12-04-2024",
              content: "content")
        ]));
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
          "news": [
            {
              "transcript": "text",
              "source": {"name": "source"},
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
}

class NewsList2VM extends NewsViewModel {
  NewsList2VM(SupabaseClient super.supabase);
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
  EmptyNewsListVM(SupabaseClient super.supabase);
  bool generateNewsCalled = false;

  @override
  Future<List<dynamic>> fetchNewsList() async {
    return Future.value([]);
  }

  @override
  Future<void> generateAndGetNews() {
    generateNewsCalled = true;
    return Future.value();
  }
}

class ExceptionNewsListVM extends NewsViewModel {
  ExceptionNewsListVM(SupabaseClient super.supabase);

  @override
  Future<List<dynamic>> fetchNewsList() async {
    throw Exception();
  }
}

class NotTodayNewsListVM extends NewsViewModel {
  NotTodayNewsListVM(SupabaseClient super.supabase);
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
        "transcript": {"news": []}
      }
    ]);
  }
}

void main() {
  test("generate-transcript failure is reported", () async {
    NewsViewModel vm = NewsViewModel(FakeFailingSupabaseClient());
    bool hasThrown = false;

    try {
      await vm.invokeTranscriptFunction();
    } catch (e) {
      hasThrown = true;
    }

    expect(hasThrown, isTrue);
  });

  test("correctly invokes cloud function", () async {
    NewsViewModel vm = NewsViewModel(FakeSupabaseClient());
    await vm.invokeTranscriptFunction();
  });

  test('database failure is handled', () async {
    NewsViewModel vm = NewsViewModel(FakeFailingSupabaseClient());
    await vm.fetchNews(DateTime.now());
    expect(vm.news, isNull);
  });

  test('already existing news are correctly fetched', () async {
    NewsViewModel vm = AlreadyExistingNewsVM(FakeSupabaseClient());
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News"));
  });

  test('non existing news are correctly generated', () async {
    NonExistingNewsVM vm = NonExistingNewsVM();
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News"));
    expect(vm.invokedTranscriptFunction, isTrue);
  });

  test('getNews with invalid date reports error', () async {
    NewsViewModel vm = NewsViewModel(FakeSupabaseClient());
    await vm.getNews(DateTime.fromMicrosecondsSinceEpoch(0));
    expect(vm.news?.title, equals("No news found for this date."));
  });

  test('getNews with non working EF reports error', () async {
    NewsViewModel vm = NeverExistingNewsVM();
    await vm.getNews(DateTime.now());
    expect(vm.news?.title, equals("News generation failed and no news found."));
  });

  test('getNewsList with non working EF reports error', () async {
    NewsViewModel vm = NeverExistingNewsVM();
    await vm.getNewsList();
    expect(vm.newsList, isEmpty);
  });

  test('getNewsList with working EF returns correct list', () async {
    NewsListVM vm = NewsListVM(FakeSupabaseClient());
    await vm.getNewsList();
    expect(vm.newsList.length, equals(1));
    expect(vm.newsList[0].title, equals("News"));
    expect(vm.newsList[0].paragraphs[0].source, equals("source"));
    expect(vm.newsList[0].paragraphs[0].title, equals("title"));
    expect(vm.newsList[0].paragraphs[0].content, equals("content"));
  });

  test('getNewsList with Empty list generates news', () async {
    EmptyNewsListVM vm = EmptyNewsListVM(FakeSupabaseClient());
    await vm.getNewsList();
    expect(vm.generateNewsCalled, isTrue);
  });

  test('getNewsList with Exception reports error', () async {
    ExceptionNewsListVM vm = ExceptionNewsListVM(FakeSupabaseClient());
    await vm.getNewsList();
    expect(vm.newsList, isEmpty);
  });

  test('getNewsList with non-today news generates news', () async {
    NotTodayNewsListVM vm = NotTodayNewsListVM(FakeSupabaseClient());
    await vm.getNewsList();
    expect(vm.generateNewsCalled, isTrue);
  });

  test('generateAndGetNews calls invoke and fetchNews', () async {
    NewsList2VM vm = NewsList2VM(FakeSupabaseClient());
    // ignore: invalid_use_of_protected_member
    await vm.generateAndGetNews();
    expect(vm.invokedTranscriptFunction, isTrue);
    expect(vm.fetchNewsCalled, isTrue);
  });

  test('setNewsError is called when news is null', () async {
    NewsList2VM vm = NewsList2VM(FakeSupabaseClient());
    // ignore: invalid_use_of_protected_member
    await vm.generateAndGetNews();
    expect(vm.news?.title, equals("News generation failed and no news found."));
  });
}
