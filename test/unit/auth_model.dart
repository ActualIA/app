import 'package:actualia/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordSignin extends FakeGoTrueClient {
  @override
  Future<AuthResponse> signInWithPassword(
      {String? email,
      String? phone,
      required String password,
      String? captchaToken}) {
    expect(email, equals("test@actualia.org"));
    expect(password, equals("1234"));
    return Future.value(AuthResponse(
        session: Session(
            accessToken: "",
            tokenType: "",
            user: const User(
                id: "1234",
                appMetadata: {},
                userMetadata: {},
                aud: "",
                createdAt: "")),
        user: const User(
            id: "1234",
            appMetadata: {},
            userMetadata: {},
            aud: "",
            createdAt: "")));
  }
}

class FailingPasswordSignin extends FakeGoTrueClient {
  @override
  Future<AuthResponse> signInWithPassword(
      {String? email,
      String? phone,
      required String password,
      String? captchaToken}) {
    expect(email, equals("test@actualia.org"));
    expect(password, equals("1234"));
    return Future.value(AuthResponse(session: null, user: null));
  }
}

class FakeAccountSignin extends FakeGoTrueClient {
  @override
  Future<AuthResponse> signInWithPassword(
      {String? email,
      String? phone,
      required String password,
      String? captchaToken}) {
    expect(email, equals("actualia@example.com"));
    expect(password, equals("actualia"));
    return Future.value(AuthResponse(
        session: Session(
            accessToken: "",
            tokenType: "",
            user: const User(
                id: "1234",
                appMetadata: {},
                userMetadata: {},
                aud: "",
                createdAt: "")),
        user: const User(
            id: "1234",
            appMetadata: {},
            userMetadata: {},
            aud: "",
            createdAt: "")));
  }
}

class Signout extends FakeGoTrueClient {
  bool hasSignedOut = false;
  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) {
    hasSignedOut = true;
    return Future.value();
  }
}

class FailingSignout extends FakeGoTrueClient {
  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) {
    throw UnimplementedError();
  }
}

class StateChangeSignInEmitter extends FakeGoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => Stream.value(AuthState(
      AuthChangeEvent.signedIn,
      Session(
          accessToken: "",
          tokenType: "",
          user: const User(
              id: "1234",
              appMetadata: {},
              userMetadata: {},
              aud: "",
              createdAt: ""))));
}

class StateChangeSignOutEmitter extends FakeGoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => Stream.fromIterable([
        AuthState(
            AuthChangeEvent.signedIn,
            Session(
                accessToken: "",
                tokenType: "",
                user: const User(
                    id: "1234",
                    appMetadata: {},
                    userMetadata: {},
                    aud: "",
                    createdAt: ""))),
        AuthState(AuthChangeEvent.signedOut, null)
      ]);
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();

  @override
  Future<AuthResponse> signInWithIdToken(
      {required OAuthProvider provider,
      required String idToken,
      String? accessToken,
      String? nonce,
      String? captchaToken}) {
    expect(provider, equals(OAuthProvider.google));
    expect(idToken, equals("idToken"));
    expect(accessToken, equals("accessToken"));
    return Future.value(AuthResponse(
        session: Session(
            accessToken: "",
            tokenType: "",
            user: const User(
                id: "1234",
                appMetadata: {},
                userMetadata: {},
                aud: "",
                createdAt: "")),
        user: const User(
            id: "1234",
            appMetadata: {},
            userMetadata: {},
            aud: "",
            createdAt: "")));
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  GoTrueClient client;
  FakeSupabaseClient(this.client);

  @override
  GoTrueClient get auth => client;
}

class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  final String? displayName = "name";

  @override
  final String email = "test@actualia.org";

  @override
  final String id = "1234";

  @override
  final String? photoUrl = "https://example.com";

  @override
  final String? serverAuthCode = null;

  @override
  Future<GoogleSignInAuthentication> get authentication =>
      Future.value(FakeGoogleSignInAuthentication());
}

class FakeGoogleSignInAuthentication extends Fake
    implements GoogleSignInAuthentication {
  /// An OpenID Connect ID token that identifies the user.
  String? get idToken => "idToken";

  /// The OAuth2 access token to access Google services.
  String? get accessToken => "accessToken";
}

class FakeGoogleSignin extends Fake implements GoogleSignIn {
  bool hasSignedIn = false;
  bool hasSignedOut = false;

  @override
  Future<GoogleSignInAccount?> signIn() {
    hasSignedIn = true;
    return Future.value(FakeGoogleSignInAccount());
  }

  @override
  Future<GoogleSignInAccount?> signOut() {
    hasSignedOut = true;
    return Future.value(null);
  }

  @override
  GoogleSignInAccount? get currentUser =>
      hasSignedIn && !hasSignedOut ? FakeGoogleSignInAccount() : null;
}

class FakeFailingGoogleSignin extends Fake implements GoogleSignIn {}

void main() {
  test("Correctly sign in from auth event", () async {
    AuthModel vm = AuthModel(
        FakeSupabaseClient(StateChangeSignInEmitter()), FakeGoogleSignin());
    await Future.delayed(Durations.long2);
    expect(vm.isSignedIn, isTrue);
    expect(vm.user?.id, equals("1234"));
  });

  test("Correctly sign out from auth event", () async {
    AuthModel vm = AuthModel(
        FakeSupabaseClient(StateChangeSignOutEmitter()), FakeGoogleSignin());
    await Future.delayed(Durations.long2);
    expect(vm.isSignedIn, isFalse);
    expect(vm.user, isNull);
  });

  test("Correctly signs in with password", () async {
    AuthModel vm =
        AuthModel(FakeSupabaseClient(PasswordSignin()), FakeGoogleSignin());
    expect(await vm.signInWithEmail("test@actualia.org", "1234"), isTrue);
  });

  test("Handle password sign in failure", () async {
    AuthModel vm = AuthModel(
        FakeSupabaseClient(FailingPasswordSignin()), FakeGoogleSignin());
    expect(await vm.signInWithEmail("test@actualia.org", "1234"), isFalse);
  });

  test("Correctly signs in with fake account", () async {
    AuthModel vm =
        AuthModel(FakeSupabaseClient(FakeAccountSignin()), FakeGoogleSignin());
    expect(await vm.signInWithFakeAccount(), isTrue);
  });

  test("Correctly signs out", () async {
    final c = Signout();
    AuthModel vm = AuthModel(FakeSupabaseClient(c), FakeGoogleSignin());

    expect(await vm.signOut(), isTrue);
    expect(c.hasSignedOut, isTrue);
  });

  test("Handle signs out failure", () async {
    AuthModel vm =
        AuthModel(FakeSupabaseClient(FailingSignout()), FakeGoogleSignin());
    expect(await vm.signOut(), isFalse);
  });

  test("Google signin works", () async {
    var gsi = FakeGoogleSignin();
    AuthModel vm = AuthModel(FakeSupabaseClient(FakeGoTrueClient()), gsi);
    expect(await vm.signInWithGoogle(), isTrue);
    expect(gsi.hasSignedIn, isTrue);
  });

  test("Google signout works", () async {
    var gsi = FakeGoogleSignin();
    AuthModel vm = AuthModel(FakeSupabaseClient(Signout()), gsi);

    expect(await vm.signInWithGoogle(), isTrue);
    expect(gsi.hasSignedIn, isTrue);

    expect(await vm.signOut(), isTrue);
    expect(gsi.hasSignedOut, isTrue);
  });

  test("Google signin failure is handled", () async {
    AuthModel vm = AuthModel(
        FakeSupabaseClient(FakeGoTrueClient()), FakeFailingGoogleSignin());
    expect(await vm.signInWithGoogle(), isFalse);
  });

  test("Google signout failure is handled", () async {
    AuthModel vm =
        AuthModel(FakeSupabaseClient(Signout()), FakeFailingGoogleSignin());
    expect(await vm.signOut(), isFalse);
  });
}
