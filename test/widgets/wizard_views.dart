import "dart:math";

import "package:actualia/models/auth_model.dart";
import "package:actualia/models/news.dart";
import "package:actualia/models/news_settings.dart";
import "package:actualia/models/providers.dart";
import "package:actualia/viewmodels/alarms.dart";
import "package:actualia/viewmodels/news_settings.dart";
import "package:actualia/viewmodels/providers.dart";
import "package:actualia/views/alarm_wizard.dart";
import "package:actualia/views/interests_wizard_view.dart";
import "package:actualia/views/providers_wizard_view.dart";
import "package:actualia/widgets/alarms_widget.dart";
import "package:actualia/widgets/top_app_bar.dart";
import "package:actualia/widgets/wizard_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:provider/provider.dart";
import "package:supabase_flutter/supabase_flutter.dart";

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
  MockProvidersViewModel({List<(NewsProvider, String)> init = const []})
      : super(FakeSupabaseClient()) {
    super.setNewsProviders(init);
  }

  @override
  Future<bool> fetchNewsProviders() async {
    return true;
  }

  @override
  Future<bool> pushNewsProviders() async {
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
    debugPrint("Alarm set do not worry");
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
    if (expected != null) {
      expect(settings.cities, equals(expected!.cities));
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

    await testSelector(Key("countries-selector"), "Chad", "Next");
    await tester.pumpAndSettle();
    await testSelector(Key("cities-selector"), "Basel", "Next");
    await tester.pumpAndSettle();
    await testSelector(Key("interests-selector"), "Gaming", "Next");
  });

  testWidgets(
      "Interests wizard: Can select countries, cities and interests and push them",
      (WidgetTester tester) async {
    final vm = ValidateVM(
        NewsSettings(
          interests: ["Biology"],
          cities: ["Basel"],
          countries: ["Antarctica"],
          wantsCities: false,
          wantsCountries: false,
          wantsInterests: false,
        ),
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

    await select(Key("countries-selector"), "Antarctica", "Next");
    await select(Key("cities-selector"), "Basel", "Next");
    await select(Key("interests-selector"), "Biology", "Finish");

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets("Interests wizard: Keep initial values",
      (WidgetTester tester) async {
    NewsSettings ns = NewsSettings(
      interests: ["Gaming"],
      cities: ["Basel"],
      countries: ["Antarctica"],
      wantsCities: false,
      wantsCountries: false,
      wantsInterests: false,
    );
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
    await nextScreen("Finish");

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
    await tester.tap(find.text("Basel"));
    expect(find.text("Cancel"), findsOne);
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
    expect(find.text("Select countries"), findsOne);
  });

  testWidgets(
      "Providers wizard: correctly display each selector whith no saved values",
      (WidgetTester tester) async {
    await tester.pumpWidget(WizardWrapper(
        wizard: const ProvidersWizardView(),
        nsvm: MockNewsSettingsViewModel(),
        auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin()),
        pvm: MockProvidersViewModel()));

    expect(find.byType(TopAppBar), findsOneWidget);
    expect(find.text("Select a predefined source"), findsOne);
    expect(find.byType(FilterChip), findsAtLeast(1));
    expect(find.byType(WizardNavigationBottomBar), findsOne);
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();

    expect(find.byType(TopAppBar), findsOneWidget);
    expect(find.text("Enter url for the RSS source of your choice"), findsOne);
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), "https://test.com");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text(RSSFeedProvider(url: "https://test.com").displayName()),
        findsOne);
    expect(find.byType(WizardNavigationBottomBar), findsOneWidget);
  });

  testWidgets(
      "Providers wizard: correctly display each selector with saved value",
      (WidgetTester tester) async {
    NewsProvider google = GNewsProvider();
    String dummyUrl = "http://dummy.com";
    String testUrl = "http://test.com";
    NewsProvider rssDummy = RSSFeedProvider(url: dummyUrl);
    NewsProvider rssTest = RSSFeedProvider(url: testUrl);

    ProvidersViewModel pvm = MockProvidersViewModel(init: [
      (google, google.displayName()),
      (rssTest, rssTest.displayName()),
      (rssDummy, rssDummy.displayName())
    ]);
    await tester.pumpWidget(WizardWrapper(
        wizard: const ProvidersWizardView(),
        nsvm: MockNewsSettingsViewModel(),
        auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin()),
        pvm: pvm));

    await tester.tap(find.text("Google News"));
    await tester.tap(find.text("Next"));
    await tester.pump();

    expect(find.text(rssTest.displayName()), findsOne);
    expect(find.text(rssDummy.displayName()), findsOne);

    await tester.tap(find.text("Finish"));
    expect(pvm.newsProviders?.contains(google), equals(false));
  });

  testWidgets(
      "Providers wizard: Can select predefined providers and rss providers and push them",
      (WidgetTester tester) async {
    ProvidersViewModel pvm = MockProvidersViewModel();
    await tester.pumpWidget(WizardWrapper(
        wizard: const ProvidersWizardView(),
        nsvm: MockNewsSettingsViewModel(),
        pvm: pvm,
        auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin())));

    await tester.tap(find.text("Google News"));
    await tester.tap(find.text("Next"));
    await tester.pump();

    String url = "https://dummy.com";
    await tester.enterText(find.byType(TextField), url);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(RSSFeedProvider(url: url).displayName()), findsOne);
    await tester.tap(find.text("Finish"));

    expect(
        pvm.newsProviders!.contains((GNewsProvider(), "Google News")), isTrue);
    NewsProvider rss = RSSFeedProvider(url: url);
    expect(pvm.newsProviders!.contains((rss, rss.displayName())), isTrue);
  });

  testWidgets(
      "Interests wizard: Cancel present and send to previous screen on tap",
      (tester) async {
    await tester.pumpWidget(WizardWrapper(
        wizard: const ProvidersWizardView(),
        nsvm: MockNewsSettingsViewModel(),
        pvm: MockProvidersViewModel(),
        auth: MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin(),
            isOnboardingRequired: false)));

    expect(find.text("Cancel"), findsOne);
    await tester.tap(find.text("Next"));
    await tester.pump();
    expect(find.byType(RSSSelector), findsOne);
    expect(find.text("Cancel"), findsOne);
    await tester.tap(find.text("Cancel"));
    await tester.pump();
    expect(find.byType(WizardSelector), findsOne);
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
    await tester.tap(find.text("Validate"));
    expect(avm.isAlarmSet, isTrue);
  });
}
