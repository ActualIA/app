import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/narrator.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/views/profile_view.dart';
import 'package:actualia/views/interests_wizard_view.dart';
import 'package:actualia/widgets/alarms_widget.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// START : Taken from Jacopo who copied it form internet
class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  get auth => FakeGotrue();
}

class FakeGotrue extends Fake implements GoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
}

class FakeGoogleSignin extends Fake implements GoogleSignIn {}

// END
class MockAuthModel extends AuthModel {
  @override
  final bool isOnboardingRequired;

  MockAuthModel(super.key, super._googleSignIn,
      {this.isOnboardingRequired = false});

  @override
  User? get user => User(
        id: 'id',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        email: "test.test@epfl.ch",
        createdAt: DateTime.now().toIso8601String(),
      );

  @override
  Future<bool> signInWithGoogle() async {
    return Future.value(true);
  }
}

// START : Taken from Ludovic

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

// End

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
  Future<bool> pushNewsProviders() async {
    return true;
  }
}

class MockAlarmsViewModel extends AlarmsViewModel {
  MockAlarmsViewModel(super.supabaseClient);

  AlarmSettings? _alarm;
  void internalSetAlarm(AlarmSettings? a) {
    _alarm = a;
    notifyListeners();
  }

  @override
  AlarmSettings? get alarm => _alarm;

  @override
  bool get isAlarmSet => false;
}

class MockNarratorViewModel extends NarratorViewModel {
  MockNarratorViewModel() : super(FakeSupabaseClient());
}

class ProfilePageWrapper extends StatelessWidget {
  late final Widget _child;
  late final NewsSettingsViewModel _newsSettingsModel;
  final ProvidersViewModel pvm;
  late final AuthModel _authModel;
  late final AlarmsViewModel _alarmsModel;
  late final NarratorViewModel _narratorModel;

  ProfilePageWrapper(this._child, this._newsSettingsModel, this.pvm,
      this._authModel, this._alarmsModel, this._narratorModel,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<NewsSettingsViewModel>(
              create: (context) => _newsSettingsModel),
          ChangeNotifierProvider<AuthModel>(create: (context) => _authModel),
          ChangeNotifierProvider<ProvidersViewModel>(create: (context) => pvm),
          ChangeNotifierProvider<AlarmsViewModel>(
              create: (context) => _alarmsModel),
          ChangeNotifierProvider<NarratorViewModel>(
              create: (context) => _narratorModel),
        ],
        child: MaterialApp(
          title: "ActualIA",
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: _child,
        ));
  }
}

void main() {
  testWidgets("Has all correct buttons", (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(ProfilePageWrapper(
        const ProfilePageView(),
        MockNewsSettingsViewModel(),
        MockProvidersViewModel(),
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin()),
        MockAlarmsViewModel(FakeSupabaseClient()),
        MockNarratorViewModel()));

    expect(find.text('Logout'), findsOne);

    testButton(String text) async {
      debugPrint("[DEBUG] testing $text");
      await tester.dragUntilVisible(
          find.text(text), find.byType(ListView), Offset.fromDirection(90.0));
      await tester.tap(find.text(findRichText: true, text));
      await tester.pump();
    }

    expect(find.text("Interests"), findsOne);
    expect(find.text("Sources"), findsOne);
    expect(find.text("Alarm"), findsOne);
    await testButton('Storage');
    expect(find.text("Narrator"), findsOne);
    await testButton('Accessibility');
    // await testButton('Done');
  });

  testWidgets("Correct username", (WidgetTester tester) async {
    await tester.pumpWidget(ProfilePageWrapper(
        const ProfilePageView(),
        MockNewsSettingsViewModel(),
        MockProvidersViewModel(),
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin()),
        MockAlarmsViewModel(FakeSupabaseClient()),
        MockNarratorViewModel()));

    expect(find.text("test.test@epfl.ch"), findsOne);
  });

  testWidgets("Interests button work as intended", (tester) async {
    await tester.pumpWidget(ProfilePageWrapper(
        const ProfilePageView(),
        MockNewsSettingsViewModel(),
        MockProvidersViewModel(),
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin()),
        MockAlarmsViewModel(FakeSupabaseClient()),
        MockNarratorViewModel()));

    expect(find.text("Interests"), findsOne);
    await tester.tap(find.text("Interests"));
    await tester.pumpAndSettle();

    //check wizard is on screen
    expect(find.byType(InterestWizardView), findsOneWidget);
    expect(find.byType(FilledButton), findsExactly(2));
    Finder finder = find.text("Cancel");
    expect(finder, findsOne);

    //click on cancel button
    await tester.tap(finder);
    await tester.pumpAndSettle();

    //check wizard not on screen anymore
    expect(find.byType(InterestWizardView), findsNothing);
    expect(find.text("Interests"), findsOne);
  });

  testWidgets("Alarm button work as intended", (tester) async {
    await tester.pumpWidget(ProfilePageWrapper(
        const ProfilePageView(),
        MockNewsSettingsViewModel(),
        MockProvidersViewModel(),
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin()),
        MockAlarmsViewModel(FakeSupabaseClient()),
        MockNarratorViewModel()));

    await tester.tap(find.text("Alarm"));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PickTimeButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text("OK"));

    await tester.tap(find.byKey(const Key("switch-on-off")));
    await tester.drag(find.byType(Slider), Offset.fromDirection(30));
    await tester.tap(find.byKey(const Key("switch-loop")));
    await tester.tap(find.byKey(const Key("switch-vibrate")));

    await tester.pumpAndSettle();
    await tester.tap(find.text("Done"));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePageView), findsOneWidget);
  });

  testWidgets("Narrator button work as intended", (tester) async {
    await tester.pumpWidget(ProfilePageWrapper(
        const ProfilePageView(),
        MockNewsSettingsViewModel(),
        MockProvidersViewModel(),
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin()),
        MockAlarmsViewModel(FakeSupabaseClient()),
        MockNarratorViewModel()));

    /*
    await tester.tap(find.text("Narrator"));
    await tester.pumpAndSettle();
    expect(find.text("Choose a voice for your audio"), findsOne);
    
    await tester.tap(find.byKey(const Key("switch-on-off")));
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePageView), findsOneWidget);
    */
  });
}
