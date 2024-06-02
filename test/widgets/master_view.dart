import 'package:actualia/models/news.dart';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:actualia/views/context_view.dart';
import 'package:actualia/views/master_view.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/navigation_menu.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import "package:flutter_test/flutter_test.dart";
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNewsViewModel extends NewsViewModel {
  MockNewsViewModel() : super(FakeSupabaseClient());
  @override
  News? get news => News(
      title: "test",
      date: "17-10-2002",
      transcriptId: 17,
      audio: "test",
      paragraphs: List.empty(),
      fullTranscript: "test");
}

class MockNewsRecognitionViewModel extends NewsRecognitionViewModel {
  MockNewsRecognitionViewModel() : super(FakeSupabaseClient());
}

class MasterWrapper extends StatelessWidget {
  final Widget master;
  final NewsViewModel newsVM;
  final NewsRecognitionViewModel newsRecognitionVM;

  const MasterWrapper(this.master, this.newsVM, this.newsRecognitionVM,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<NewsViewModel>(create: (context) => newsVM),
          ChangeNotifierProvider<NewsRecognitionViewModel>(
              create: (context) => newsRecognitionVM)
        ],
        child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            title: "ActualIA",
            theme: ACTUALIA_THEME,
            home: master));
  }
}

void main() {
  testWidgets('MasterView contains bottom bar', (WidgetTester tester) async {
    await tester.pumpWidget(MasterWrapper(const MasterView(),
        MockNewsViewModel(), MockNewsRecognitionViewModel()));
    //find the app bar
    expect(find.byType(ActualiaBottomNavigationBar), findsOneWidget);
    expect(find.byType(TopAppBar), findsOneWidget);

    await tester.tap(find.byIcon(Icons.camera));
    await tester.pumpAndSettle();
    expect(find.byType(ContextView), findsOneWidget);
    await tester.tap(find.byIcon(Icons.feed));
    await tester.pumpAndSettle();
    expect(find.byType(NewsView), findsNothing);
  });

  testWidgets("Can take a picture", (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await tester.pumpWidget(MasterWrapper(const MasterView(),
        MockNewsViewModel(), NewsRecognitionViewModel(FakeSupabaseClient())));
  });
}
