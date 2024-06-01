import "package:actualia/models/news.dart";
import "package:actualia/viewmodels/news.dart";
import "package:actualia/views/news_view.dart";
import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:provider/provider.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNewsViewModel extends NewsViewModel {
  MockNewsViewModel.create() : super.create(FakeSupabaseClient());

  @override
  Content get content => Left([
        News(
            title: "Title1",
            date: "1970-01-01",
            transcriptId: -1,
            audio: null,
            paragraphs: [
              Paragraph(
                  transcript: "text1",
                  source: "source1",
                  title: "title1",
                  date: "1970-01-01",
                  content: "content1",
                  url: "url1"),
              Paragraph(
                  transcript: "text2",
                  source: "source2",
                  title: "title2",
                  date: "1970-01-01",
                  content: "content2",
                  url: "url2"),
              Paragraph(
                  transcript: "text3",
                  source: "source3",
                  title: "title3",
                  date: "1970-01-01",
                  content: "content3",
                  url: "url3"),
              Paragraph(
                  transcript: "text4",
                  source: "source4",
                  title: "title4",
                  date: "1970-01-01",
                  content: "content4",
                  url: "url4")
            ],
            fullTranscript: "full-transcript"),
        News(
            title: "Title2",
            date: "1970-01-01",
            transcriptId: -1,
            audio: null,
            paragraphs: [
              Paragraph(
                  transcript: "text1",
                  source: "source1",
                  title: "title1",
                  date: "1970-01-01",
                  content: "content1",
                  url: "url1"),
              Paragraph(
                  transcript: "text2",
                  source: "source2",
                  title: "title2",
                  date: "1970-01-01",
                  content: "content2",
                  url: "url2"),
              Paragraph(
                  transcript: "text3",
                  source: "source3",
                  title: "title3",
                  date: "1970-01-01",
                  content: "content3",
                  url: "url3"),
              Paragraph(
                  transcript: "text4",
                  source: "source4",
                  title: "title4",
                  date: "1970-01-01",
                  content: "content4",
                  url: "url4")
            ],
            fullTranscript: "full-transcript"),
        News(
            title: "Title3",
            date: "1970-01-01",
            transcriptId: -1,
            audio: null,
            paragraphs: [
              Paragraph(
                  transcript: "text1",
                  source: "source1",
                  title: "title1",
                  date: "1970-01-01",
                  content: "content1",
                  url: "url1"),
              Paragraph(
                  transcript: "text2",
                  source: "source2",
                  title: "title2",
                  date: "1970-01-01",
                  content: "content2",
                  url: "url2"),
            ],
            fullTranscript: "full-transcript"),
      ]);

  @override
  Future<void> getNews(DateTime date) {
    return Future.value();
  }

  @override
  Future<void> getNewsList() {
    return Future.value();
  }
}

class NewsWrapper extends StatelessWidget {
  final Widget _child;
  final NewsViewModel _model;

  const NewsWrapper(this._child, this._model, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        title: "ActualIA",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<NewsViewModel>(create: (context) => _model)
          ],
          child: _child,
        ));
  }
}

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets("Has all correct title", (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester
        .pumpWidget(NewsWrapper(const NewsView(), MockNewsViewModel.create()));
    await tester.pumpAndSettle();

    expect(find.text("Title1"), findsOne);
  });
}
