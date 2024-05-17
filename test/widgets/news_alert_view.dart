import 'package:actualia/models/news.dart';
import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/views/news_alert_view.dart';
import 'package:actualia/widgets/play_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../unit/news_view_model.dart';
import 'play_button.dart' as pb;
import 'profile_view.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNewsViewModel extends NewsViewModel {
  MockNewsViewModel.create(super.supabase) : super.create();

  @override
  Future<void> fetchNews(DateTime date) async {
    return;
  }
}

class ExistingNewsNVM extends AlreadyExistingNewsVM {
  ExistingNewsNVM.create(super.supabase) : super.create();

  @override
  Future<void> getAudioFile(News news) async {
    debugPrint("[GETAUDIO]");
    return;
  }
}

class MockAlarmsViewModel extends AlarmsViewModel {
  MockAlarmsViewModel(super.supabaseClient);
}

class AlertWrapper extends StatelessWidget {
  final NewsViewModel nvm;
  final AlarmsViewModel avm;
  final NewsAlertView home;

  const AlertWrapper(
      {required this.home, required this.nvm, required this.avm, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<NewsViewModel>(create: (context) => nvm),
          ChangeNotifierProvider<AlarmsViewModel>(create: (context) => avm)
        ],
        child: MaterialApp(
          title: "ActualIA",
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: home,
        ));
  }
}

void main() {
  testWidgets('Show loading if no transcript', (WidgetTester tester) async {
    SupabaseClient supabase = FakeSupabaseClient();
    NewsViewModel nvm = MockNewsViewModel.create(supabase);
    AlarmsViewModel avm = MockAlarmsViewModel(supabase);

    await tester.pumpWidget(
        AlertWrapper(home: const NewsAlertView(), nvm: nvm, avm: avm));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets("Show play button if transcript found", (tester) async {
    SupabaseClient supabase = FakeSupabaseClient();
    NewsViewModel nvm = ExistingNewsNVM.create(supabase);
    AlarmsViewModel avm = MockAlarmsViewModel(supabase);

    await tester.pumpWidget(
        AlertWrapper(home: const NewsAlertView(), nvm: nvm, avm: avm));
    await tester.pumpAndSettle();

    expect(find.byType(PlayButton), findsOneWidget);
  });
}
