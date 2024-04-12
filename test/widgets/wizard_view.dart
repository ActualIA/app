import "package:actualia/models/news_settings.dart";
import "package:actualia/viewmodels/news_settings.dart";
import "package:actualia/views/wizard_view.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:provider/provider.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockNewsSettingsViewModel extends NewsSettingsViewModel {
  MockNewsSettingsViewModel() : super(FakeSupabaseClient()) {
    super.setSettings(NewsSettings.defaults());
  }

  @override
  Future<void> fetchSettings() {
    notifyListeners();
    return Future.value();
  }

  @override
  Future<bool> pushSettings(NewsSettings settings) {
    return Future.value(true);
  }
}

class ValidateVM extends MockNewsSettingsViewModel {
  bool wasTriggered = false;
  NewsSettings? expected;

  ValidateVM(this.expected, NewsSettings? initial) : super() {
    if (initial != null) {
      super.setSettings(initial);
    }
  }

  @override
  Future<bool> pushSettings(NewsSettings settings) {
    final expected = this.expected;
    if (expected != null) {
      expect(settings.cities, equals(expected.cities));
      expect(settings.countries, equals(expected.countries));
      expect(settings.interests, equals(expected.interests));
    }

    wasTriggered = true;
    return Future.value(true);
  }
}

class WizardWrapper extends StatelessWidget {
  late final Widget _child;
  late final NewsSettingsViewModel _model;

  WizardWrapper(this._child, this._model, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "ActualIA",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<NewsSettingsViewModel>(
                create: (context) => _model)
          ],
          child: _child,
        ));
  }
}

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets("Has all correct inputs", (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(
        WizardWrapper(const WizardView(), MockNewsSettingsViewModel()));

    expect(find.text("Select some interests"), findsOne);
    expect(find.text("Interests"), findsOne);
    expect(find.text("Select some countries"), findsOne);
    expect(find.text("Country"), findsOne);
    expect(find.text("Select some cities"), findsOne);
    expect(find.text("City"), findsOne);
    expect(find.text("Validate"), findsOne);
  });

  testWidgets("Can select interest", (WidgetTester tester) async {
    final vm = ValidateVM(
        NewsSettings(
            interests: ["Biology"],
            cities: [],
            countries: [],
            wantsCities: false,
            wantsCountries: false,
            wantsInterests: false),
        null);
    await tester.pumpWidget(WizardWrapper(const WizardView(), vm));

    await tester.tap(find.byKey(const Key("interest-selector")));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Biology"));
    await tester.pump();

    await tester.tap(find.text("Validate"));
    await tester.pump();

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets("Can select city", (WidgetTester tester) async {
    final vm = ValidateVM(
        NewsSettings(
            interests: [],
            cities: ["Basel"],
            countries: [],
            wantsCities: false,
            wantsCountries: false,
            wantsInterests: false),
        null);
    await tester.pumpWidget(WizardWrapper(const WizardView(), vm));

    await tester.tap(find.byKey(const Key("city-selector")));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Basel"));
    await tester.pump();

    await tester.tap(find.text("Validate"));
    await tester.pump();

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets("Can select country", (WidgetTester tester) async {
    final vm = ValidateVM(
        NewsSettings(
            interests: [],
            cities: [],
            countries: ["Albania"],
            wantsCities: false,
            wantsCountries: false,
            wantsInterests: false),
        null);
    await tester.pumpWidget(WizardWrapper(const WizardView(), vm));

    await tester.tap(find.byKey(const Key("country-selector")));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Albania"));
    await tester.pump();

    await tester.tap(find.text("Validate"));
    await tester.pump();

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets("Keep initial values", (WidgetTester tester) async {
    NewsSettings ns = NewsSettings(
        interests: ["Gaming"],
        cities: ["Basel"],
        countries: ["Switzerland"],
        wantsCities: false,
        wantsCountries: false,
        wantsInterests: false);
    final vm = ValidateVM(ns, ns);

    await tester.pumpWidget(WizardWrapper(const WizardView(), vm));

    final validateFinder = find.text("Validate");
    expect(validateFinder, findsOne);

    await tester.tap(validateFinder);
    await tester.pump();

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets("Can validate", (WidgetTester tester) async {
    final vm = ValidateVM(null, null);

    await tester.pumpWidget(WizardWrapper(const WizardView(), vm));

    final validateFinder = find.text("Validate");
    expect(validateFinder, findsOne);

    await tester.tap(validateFinder);
    await tester.pump();

    expect(vm.wasTriggered, isTrue);
  });
}
