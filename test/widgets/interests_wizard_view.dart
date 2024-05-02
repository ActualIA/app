import "package:actualia/models/auth_model.dart";
import "package:actualia/models/news_settings.dart";
import "package:actualia/viewmodels/news_settings.dart";
import "package:actualia/views/interests_wizard_view.dart";
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
  late final Widget _child;
  late final NewsSettingsViewModel _model;
  late final AuthModel _auth;

  WizardWrapper(this._child, this._model, this._auth, {super.key});

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
                create: (context) => _model),
            ChangeNotifierProvider<AuthModel>(create: (context) => _auth)
          ],
          child: _child,
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
  testWidgets("Correctly display each selector", (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(WizardWrapper(
        const InterestWizardView(),
        MockNewsSettingsViewModel(),
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin(),
            isOnboardingRequired: true)));

    testSelector(Key selectorKey, String scrollUntil, String buttonText) async {
      expect(find.byKey(selectorKey), findsOneWidget);
      // await tester.dragUntilVisible(find.text("Chad"), find.byType(SingleChildScrollView), Offset(200, 50)); TODO find a way to test the scroll of a singleChildScrollView
      expect(find.text(buttonText), findsOne);
      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();
    }

    await testSelector(const Key("countries-selector"), "Chad", "Next");
    await testSelector(const Key("cities-selector"), "Basel", "Next");
    await testSelector(const Key("interests-selector"), "Gaming", "Finish");
  });

  testWidgets("Can select countries, cities and interests and push them",
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
    await tester.pumpWidget(WizardWrapper(const InterestWizardView(), vm,
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin())));

    select(Key selectorKey, String toSelect, String button) async {
      expect(find.byKey(selectorKey), findsOneWidget);
      expect(find.text(toSelect), findsOne);
      await tester.tap(find.text(toSelect));
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
    }

    await select(const Key("countries-selector"), "Antarctica", "Next");
    await select(const Key("cities-selector"), "Basel", "Next");
    await select(const Key("interests-selector"), "Biology", "Finish");

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets("Keep initial values", (WidgetTester tester) async {
    NewsSettings ns = NewsSettings(
      interests: ["Gaming"],
      cities: ["Basel"],
      countries: ["Antarctica"],
      wantsCities: false,
      wantsCountries: false,
      wantsInterests: false,
    );
    final vm = ValidateVM(ns, ns);

    await tester.pumpWidget(WizardWrapper(const InterestWizardView(), vm,
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin())));

    nextScreen(String button) async {
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
    }

    await nextScreen("Next");
    await nextScreen("Next");
    await nextScreen("Finish");

    expect(vm.wasTriggered, isTrue);
  });

  testWidgets("Cancel present and send to previous screen on tap",
      (WidgetTester tester) async {
    final vm = ValidateVM(null, null);
    await tester.pumpWidget(WizardWrapper(
        const InterestWizardView(),
        vm,
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin(),
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
}
