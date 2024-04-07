import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  static const _webClientId =
      '505202936017-bn8uc2veq2hv5h6ksbsvr9pr38g12gde.apps.googleusercontent.com';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
  );

  User? user;
  StreamSubscription? authStateSub;

  bool get isSignedIn => user != null;

  AuthModel() {
    authStateSub = _supabase.auth.onAuthStateChange.listen((authState) {
      print('Supabase onAuthStateChange new authState : ${authState.event}');

      if (authState.event == AuthChangeEvent.signedIn) {
        user = authState.session!.user;
      } else if (authState.event == AuthChangeEvent.signedOut) {
        user = null;
      }

      notifyListeners();
    }, onError: (e) {
      print('Supabase onAuthStateChange error : $e');
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
        print('Missing ID Token or access token from Google OAuth.');
      }

      final res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
        accessToken: accessToken!,
      );

      return res.user != null;
    } catch (error) {
      print(error);
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
      print(e);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final res = await _supabase.auth
        .signInWithPassword(password: password, email: email);
    return res.user != null;
  }

  Future<bool> signInWithFakeAccount() async {
    return signInWithEmail("actualia@example.com", "actualia");
  }
}
