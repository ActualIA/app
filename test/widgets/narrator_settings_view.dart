import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:provider/provider.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:actualia/viewmodels/narrator.dart';
import 'package:actualia/views/narrator_settings_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNarratorViewModel extends NarratorViewModel {
  MockNarratorViewModel() : super(FakeSupabaseClient());

  @override
  Future<bool> pushVoiceWanted(String voiceWanted) async {
    setVoiceWanted(voiceWanted);
    return true;
  }
}

class NarratorWrapper extends StatelessWidget {
  final Widget narrator;
  final NarratorViewModel narratorVM;

  const NarratorWrapper(this.narrator, this.narratorVM, {super.key});

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
            ChangeNotifierProvider<NarratorViewModel>(
                create: (context) => narratorVM)
          ],
          child: narrator,
        ));
  }
}

void main() {
  testWidgets("NarratorSettingsView has a title", (WidgetTester tester) async {
    await tester.pumpWidget(
        NarratorWrapper(const NarratorSettingsView(), MockNarratorViewModel()));

    expect(find.text("Choose a voice for your audio"), findsOne);
  });

  testWidgets("NarratorSettingsView has a done button",
      (WidgetTester tester) async {
    await tester.pumpWidget(NarratorWrapper(
      const NarratorSettingsView(),
      MockNarratorViewModel(),
    ));

    expect(find.text("Done"), findsOne);
  });

/*
  testWidgets("NarratorSettingsView saves voice wanted",
      (WidgetTester tester) async {
    final narratorVM = MockNarratorViewModel();
    await tester
        .pumpWidget(NarratorWrapper(const NarratorSettingsView(), narratorVM));

    expect(narratorVM.voiceWanted, "");
  });*/
}
