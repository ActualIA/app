import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/widgets/play_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNewsViewModel extends NewsViewModel {
  MockNewsViewModel.create() : super.create(FakeSupabaseClient());

  @override
  Future<Source?> getAudioSource(int transcriptId) async {
    return AssetSource("audio/boom.mp3");
  }
}

class NewsWrapper extends StatelessWidget {
  late final Widget _child;
  late final NewsViewModel _model;

  NewsWrapper(this._child, this._model, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<NewsViewModel>(create: (context) => _model)
        ],
        child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            title: "ActualIA",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: _child));
  }
}

void main() {
  testWidgets('testPlayButton', (WidgetTester tester) async {
    const int dummyTranscriptID = 0;

    await tester.pumpWidget(NewsWrapper(
        const PlayButton(transcriptId: dummyTranscriptID),
        MockNewsViewModel.create()));

    expect(find.byType(PlayButton), findsOne);
    expect(find.byType(IconButton), findsOne);
  });

  testWidgets('PlayerStateAwakening', (WidgetTester tester) async {
    const int dummyTranscriptID = -1;

    await tester.pumpWidget(NewsWrapper(
        const PlayButton(transcriptId: dummyTranscriptID),
        MockNewsViewModel.create()));

    final button = find.byType(PlayButton);
    final PlayButtonState state = tester.state(button);

    expect(state.playerState, equals(PlayerState.stopped));
    await tester.tap(button);
    await tester.pump(Durations.long1);
    expect((tester.state(button) as PlayButtonState).playerState,
        equals(PlayerState.playing));
  });
}
