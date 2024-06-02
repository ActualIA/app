import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthModel extends ChangeNotifier {
  late final GoogleSignIn _googleSignIn;
  late final SupabaseClient _supabase;

  User? user;
  StreamSubscription? authStateSub;

  bool get isSignedIn => user != null;
  late bool isOnboardingRequired;

  AuthModel(SupabaseClient supabaseClient, this._googleSignIn) {
    _supabase = supabaseClient;
    authStateSub = _supabase.auth.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedOut ||
          authState.event == AuthChangeEvent.userDeleted) {
        user = null;
      } else {
        user = _supabase.auth.currentSession?.user;
      }

      if (user != null) {
        final bool onboardingDone =
            user!.userMetadata?['onboardingDone'] ?? false;
        isOnboardingRequired = !onboardingDone;
      }

      notifyListeners();
    }, onError: (e) {
      log('Supabase onAuthStateChange error : $e', level: Level.WARNING.value);
    });
  }

  @override
  void dispose() {
    if (authStateSub != null) {
      authStateSub!.cancel();
      authStateSub = null;
    }
    super.dispose();
  }

  Future<bool> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null || accessToken == null) {
        log('Missing ID Token or access token from Google OAuth.',
            level: Level.WARNING.value);
      }

      final res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
        accessToken: accessToken!,
      );

      return res.user != null;
    } catch (e) {
      log("Google Sign-In failed: $e", level: Level.WARNING.value);
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      await _supabase.auth.signOut();
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
      return true;
    } catch (e) {
      log("Sign-Out failed: $e", level: Level.WARNING.value);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final res = await _supabase.auth
        .signInWithPassword(password: password, email: email);
    return res.user != null;
  }

  // use the anonymous sign in API from Supabase !
  // More info can be found at the documentation webpage.
  Future<bool> signInWithFakeAccount() async {
    final res = await _supabase.auth.signInAnonymously();

    log("signed in anonymously ! user : $res.user", level: Level.WARNING.value);

    return res.user != null;
  }

  /// Sets a flag in user metadata to remember that the onboarding is done
  Future<bool> setOnboardingIsDone() async {
    await _supabase.auth
        .updateUser(UserAttributes(data: {'onboardingDone': true}));
    return true;
  }
}
