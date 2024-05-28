import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:actualia/views/context_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  testWidgets('ContextView displays the correct text',
      (WidgetTester tester) async {
    // Build the ContextView widget.
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ContextView(text: "Hello, World!"),
        ),
      ),
    );

    // Verify that the initial text is displayed.
    expect(find.text('Hello, World!'), findsOne);

    expect(
        find.text(
            "Here is some context regarding the text you just photographed:"),
        findsOne);
  });
}
