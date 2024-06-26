import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/views/news_alert_setup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'play_button.dart' as pb;
import 'profile_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  testWidgets('simple construction test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        title: 'ActualIA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: MultiProvider(providers: [
          ChangeNotifierProvider<AlarmsViewModel>(
              create: (context) => MockAlarmsViewModel(FakeSupabaseClient())),
          ChangeNotifierProvider<NewsViewModel>(
              create: (context) => pb.MockNewsViewModel.create()),
        ], child: const NewsAlertSetupView())));
    // expect(find.text('Loading something'), findsOne);
  });
}
