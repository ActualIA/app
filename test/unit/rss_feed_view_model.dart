import 'package:actualia/models/article.dart';
import 'package:actualia/viewmodels/rss_feed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeFunctionsClient extends Fake implements FunctionsClient {
  @override
  Future<FunctionResponse> invoke(String functionName,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      Map<String, dynamic>? queryParameters,
      HttpMethod method = HttpMethod.post}) async {
    expect(functionName, equals("generate-raw-feed"));
    return FunctionResponse(
        status: 200,
        data:
            '[{"description":"my description","source":{"name":"my source"},"url":"my url","title":"my title","publishedAt":"my date","content":"my content"}]');
  }
}

class FailingFunctionsClient extends Fake implements FunctionsClient {}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  FunctionsClient fc;

  FakeSupabaseClient(this.fc);

  @override
  FunctionsClient get functions => fc;
}

void main() {
  test("Correctly fetches feed", () async {
    final vm = RSSFeedViewModel(FakeSupabaseClient(FakeFunctionsClient()));
    await vm.getRawNewsList();

    expect(
        listEquals(vm.articles, [
          const Article(
              content: "my content",
              date: "my date",
              description: "my description",
              origin: "my source",
              title: "my title",
              url: "my url")
        ]),
        isTrue);
  });

  test("Errors are reported", () async {
    final vm = RSSFeedViewModel(FakeSupabaseClient(FailingFunctionsClient()));
    expect(() async => await vm.getRawNewsList(), throwsException);
    expect(vm.hasNews, isFalse);
  });
}
