import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/views/profile_view.dart';
import 'package:actualia/views/wizard_view.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
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
  Stream<AuthState> get onAuthStateChange => Stream.empty();
}

class FakeGoogleSignin extends Fake implements GoogleSignIn {}

// END
class MockAuthModel extends AuthModel {
  MockAuthModel(super.key, super._googleSignIn) {
    print("instantiated mockauth");
  }

  @override
  User? get user => User(
        id: 'id',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        email: "test.test@epfl.ch",
        createdAt: DateTime.now().toIso8601String(),
      );

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

class ProfilePageWrapper extends StatelessWidget {
  late final Widget _child;
  late final NewsSettingsViewModel _newsSettingsModel;
  late final AuthModel _authModel;

  ProfilePageWrapper(this._child, this._newsSettingsModel, this._authModel,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<NewsSettingsViewModel>(
              create: (context) => _newsSettingsModel),
          ChangeNotifierProvider<AuthModel>(create: (context) => _authModel)
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
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin())));

    expect(find.text('Logout'), findsOne);

    testButton(String text) async {
      await tester.scrollUntilVisible(find.text(text), 1);
      await tester.tap(find.text(text));
      await tester.pump();
    }

    testInterestButton() async {
      expect(find.text("Interests"), findsOne);
    }

    await testInterestButton();
    await testButton('Sources');
    await testButton('Alarm');
    await testButton('Manage Storage');
    await testButton('Narrator Settings');
    await testButton('Accessibility');
    await testButton('Done');
  });

  testWidgets("Correct username", (WidgetTester tester) async {
    await tester.pumpWidget(ProfilePageWrapper(
        const ProfilePageView(),
        MockNewsSettingsViewModel(),
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin())));

    expect(find.text("Hey, test.test@epfl.ch !"), findsOne);
  });

  testWidgets("Interests button work as intended", (tester) async {
    await tester.pumpWidget(ProfilePageWrapper(
        const ProfilePageView(),
        MockNewsSettingsViewModel(),
        MockAuthModel(FakeSupabaseClient(), FakeGoogleSignin())));

    expect(find.text("Interests"), findsOne);
    await tester.tap(find.text("Interests"));
    await tester.pumpAndSettle();

    //check wizard is on screen
    expect(find.byType(WizardView), findsOneWidget);
    expect(find.byType(WizardNavigationButton), findsExactly(2));
    Finder finder = find.text("Cancel");
    expect(finder, findsOne);

    //click on cancel button
    await tester.tap(finder);
    await tester.pumpAndSettle();

    //check wizard not on screen anymore
    expect(find.byType(WizardView), findsNothing);
    expect(find.text("Interests"), findsOne);
  });
}
