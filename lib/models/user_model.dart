import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  static const webClientId =
      '505202936017-bn8uc2veq2hv5h6ksbsvr9pr38g12gde.apps.googleusercontent.com';
  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId: webClientId,
  );

  User? get user => supabase.auth.currentUser;
  bool get isLoggedIn => supabase.auth.currentSession?.accessToken != null;

  Future<bool> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null || accessToken == null) {
        print('Missing ID Token or access token from Google OAuth.');
      }

      final res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
        accessToken: accessToken!,
      );

      notifyListeners();
      return res.user != null;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    final res = await supabase.auth.signUp(password: password, email: email);
    return res.user != null;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final res = await supabase.auth
        .signInWithPassword(password: password, email: email);
    return res.user != null;
  }
}
