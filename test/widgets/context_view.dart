import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:actualia/views/context_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class FakeNewsRecognitionVM extends NewsRecognitionViewModel {
  FakeNewsRecognitionVM(super.supabaseClient);

  @override
  String? get result =>
      "This is a context that is displayed when the text is recognized.";
  @override
  bool get isProcessing => false;
  @override
  bool get hasError => false;
  @override
  List<String> get contexts => [
        "This is a context that is displayed when the text is recognized.",
        "This is an old context that should also be displayed."
      ];
}

void main() {
  testWidgets('ContextView displays the correct text',
      (WidgetTester tester) async {
    // Build the ContextView widget.
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<NewsRecognitionViewModel>(
                create: (context) =>
                    FakeNewsRecognitionVM(FakeSupabaseClient()))
          ],
          child: const Scaffold(
            body: ContextView(),
          ),
        ),
      ),
    );

    expect(
        find.text(
            "This is a context that is displayed when the text is recognized."),
        findsWidgets);

    expect(find.text("This is an old context that should also be displayed."),
        findsWidgets);
  });
}
