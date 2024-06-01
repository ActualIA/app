import "package:actualia/models/auth_model.dart";
import "package:actualia/models/news_settings.dart";
import "package:actualia/models/providers.dart";
import "package:actualia/viewmodels/alarms.dart";
import "package:actualia/viewmodels/news_settings.dart";
import "package:actualia/viewmodels/providers.dart";
import "package:actualia/views/alarm_wizard.dart";
import "package:actualia/views/interests_wizard_view.dart";
import "package:actualia/widgets/alarms_widget.dart";
import "package:actualia/widgets/wizard_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:provider/provider.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final GoTrueClient client = FakeGoTrueClient();

  @override
  GoTrueClient get auth => client;
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
}

class MockProvidersViewModel extends ProvidersViewModel {
  MockProvidersViewModel({List<NewsProvider> init = const []})
      : super(FakeSupabaseClient()) {
    super.setNewsProviders(init);
  }

  @override
  Future<bool> fetchNewsProviders() async {
    return true;
  }

  @override
  Future<bool> pushNewsProviders(AppLocalizations loc) async {
    return true;
  }
}

class MockAlarmsViewModel extends AlarmsViewModel {
  bool _alarmSet = false;

  @override
  bool get isAlarmSet => _alarmSet;

  MockAlarmsViewModel(super.supabaseClient);

  @override
  Future<void> setAlarm(DateTime time, String assetAudio, bool loopAudio,
      bool vibrate, double volume, int? settingsId) async {
    _alarmSet = true;
  }
}

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
  Future<bool> pushSettings(NewsSettings? settings) {
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
  Future<bool> pushSettings(NewsSettings? settings) {
    if (expected != null) {
      expect(settings!.cities, equals(expected!.cities));
      expect(settings.countries, equals(expected!.countries));
      expect(settings.interests, equals(expected!.interests));
    }

    wasTriggered = true;
    return Future.value(true);
  }
}

class WizardWrapper extends StatelessWidget {
  final Widget wizard;
  final NewsSettingsViewModel nsvm;
  final ProvidersViewModel pvm;
  final AlarmsViewModel? avm;
  final AuthModel auth;

  const WizardWrapper(
      {required this.wizard,
      required this.nsvm,
      required this.auth,
      required this.pvm,
      this.avm,
      super.key});

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
            ChangeNotifierProvider<NewsSettingsViewModel>(
                create: (context) => nsvm),
            ChangeNotifierProvider<ProvidersViewModel>(
                create: (context) => pvm),
            ChangeNotifierProvider<AuthModel>(create: (context) => auth),
            ChangeNotifierProvider<AlarmsViewModel>(
                create: (context) =>
                    avm ?? MockAlarmsViewModel(FakeSupabaseClient()))
          ],
          child: wizard,
        ));
  }
}

class MockAuthModel extends AuthModel {
  final bool isOnboardingRequired;

  MockAuthModel(super.supabaseClient, super.googleSignIn,
      {this.isOnboardingRequired = false});

  @override
  Future<bool> setOnboardingIsDone() async {
    return true;
  }
}

class FakeGoogleSignin extends Fake implements GoogleSignIn {}

void main() {
  // The `BuildContext` does not include the provider
  // needed by Provider<AuthModel>, UI will test more specific parts
  testWidgets("Interests wizard: Correctly display each selector",
      (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(WizardWrapper(
      wizard: const InterestWizardView(),
      nsvm: MockNewsSettingsViewModel(),
      auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin(),
          isOnboardingRequired: true),
      pvm: MockProvidersViewModel(),
    ));

    testSelector(Key selectorKey, String scrollUntil, String buttonText) async {
      expect(find.byKey(selectorKey), findsOneWidget);
      // await tester.dragUntilVisible(find.text("Chad"), find.byType(SingleChildScrollView), Offset(200, 50)); TODO find a way to test the scroll of a singleChildScrollView
      expect(find.text(buttonText), findsOne);
      await tester.tap(find.text(buttonText));
    }

    await testSelector(const Key("countries-selector"), "Chad", "Next");
    await tester.pumpAndSettle();
    await testSelector(
        const Key("cities-selector"), "Abobo (Côte d'Ivoire)", "Next");
    await tester.pumpAndSettle();
    await testSelector(const Key("interests-selector"), "Gaming", "Next");
  });

  testWidgets(
      "Interests wizard: Can select countries, cities and interests and push them",
      (WidgetTester tester) async {
    final vm = ValidateVM(
        NewsSettings(
            interests: ["Aviation"],
            cities: ["Abobo (Côte d'Ivoire)"],
            countries: ["Antarctica"],
            wantsCities: false,
            wantsCountries: false,
            wantsInterests: false,
            locale: "en",
            userPrompt: ""),
        null);
    await tester.pumpWidget(WizardWrapper(
        wizard: const InterestWizardView(),
        nsvm: vm,
        pvm: MockProvidersViewModel(),
        auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin())));

    select(Key selectorKey, String toSelect, String button) async {
      expect(find.byKey(selectorKey), findsOneWidget);
      expect(find.text(toSelect), findsOne);
      await tester.tap(find.text(toSelect));
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
    }

    await select(const Key("countries-selector"), "Antarctica", "Next");
    await select(const Key("cities-selector"), "Abobo (Côte d'Ivoire)", "Next");
    await select(const Key("interests-selector"), "Aviation", "Done");

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets("Interests wizard: Keep initial values",
      (WidgetTester tester) async {
    NewsSettings ns = NewsSettings(
        interests: ["Gaming"],
        cities: ["Abobo (Côte d'Ivoire)"],
        countries: ["Antarctica"],
        wantsCities: false,
        wantsCountries: false,
        wantsInterests: false,
        locale: "en",
        userPrompt: "");
    final vm = ValidateVM(ns, ns);

    await tester.pumpWidget(WizardWrapper(
        wizard: const InterestWizardView(),
        nsvm: vm,
        pvm: MockProvidersViewModel(),
        auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin())));

    nextScreen(String button) async {
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
    }

    await nextScreen("Next");
    await nextScreen("Next");
    await nextScreen("Done");

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets(
      "Interests wizard: Cancel present and send to previous screen on tap",
      (WidgetTester tester) async {
    final vm = ValidateVM(null, null);
    await tester.pumpWidget(WizardWrapper(
        wizard: const InterestWizardView(),
        nsvm: vm,
        pvm: MockProvidersViewModel(),
        auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin(),
            isOnboardingRequired: false)));

    expect(find.text("Cancel"), findsOne);
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Abobo (Côte d'Ivoire)"));
    expect(find.text("Cancel"), findsOne);
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
    expect(find.text("Select countries"), findsOne);
  });

  testWidgets("Alarm wizard: display everything correctly", (tester) async {
    AlarmsViewModel avm = MockAlarmsViewModel(FakeSupabaseClient());
    await tester.pumpWidget(WizardWrapper(
      wizard: const AlarmWizardView(),
      nsvm: MockNewsSettingsViewModel(),
      auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin(),
          isOnboardingRequired: false),
      pvm: MockProvidersViewModel(),
      avm: avm,
    ));

    expect(find.byType(PickTimeButton), findsOneWidget);
    expect(find.byType(WizardNavigationBottomBar), findsOneWidget);
    await tester.tap(find.text("Done"));
    expect(avm.isAlarmSet, isTrue);
  });
}
