import 'dart:convert';

import 'package:actualia/models/auth_model.dart';
import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/news_view.dart';
import 'auth.dart' as mocknvm;
import 'utils.dart';

class MockHttp extends BaseMockedHttpClient {
  bool onboardingDone = false;

  @override
  get extraUserMetadata => {"onboardingDone": onboardingDone};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Future(() {
      var req = request as http.Request;
      if (request.url.toString().startsWith(
          "${BaseMockedHttpClient.baseUrl}/rest/v1/news?select=%2A")) {
        return response([], 200, request);
      }

      switch (req.url.toString()) {
        case "${BaseMockedHttpClient.baseUrl}/rest/v1/news_settings?on_conflict=created_by":
          var body = json.decode(req.body);

          expect(listEquals(List<String>.from(body['cities']), ['Lausanne']),
              isTrue);
          expect(listEquals(List<String>.from(body['countries']), ['Albania']),
              isTrue);
          expect(listEquals(List<String>.from(body['interests']), ['Gaming']),
              isTrue);
          return http.StreamedResponse(Stream.fromIterable(["".codeUnits]), 201,
              request: req);
        case "${BaseMockedHttpClient.baseUrl}/rest/v1/news_settings?select=%2A&created_by=eq.${BaseMockedHttpClient.uuid}":
          return response({
            "id": 345,
            "created_at": "2024-04-30T14:39:28.189469+00:00",
            "created_by": BaseMockedHttpClient.uuid,
            "interests": onboardingDone ? jsonEncode(["Gaming"]) : "[]",
            "wants_interests": true,
            "countries": onboardingDone ? jsonEncode(["Albania"]) : "[]",
            "wants_countries": true,
            "cities": onboardingDone ? jsonEncode(["Lausanne"]) : "[]",
            "wants_cities": true,
            "user_prompt": null,
            "providers_id": null,
            "voice_wanted": null
          }, 200, req);
        case "${BaseMockedHttpClient.baseUrl}/rest/v1/news_settings?select=providers&created_by=eq.${BaseMockedHttpClient.uuid}":
          return response([], 200, req);
        case "${BaseMockedHttpClient.baseUrl}/rest/v1/news_settings?created_by=eq.${BaseMockedHttpClient.uuid}":
          expect(
              jsonDecode(req.body),
              equals({
                "providers": ["/google/news/:category"]
              }));
          return response([], 200, req);
        default:
      }

      return super.send(request);
    });
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return Future(() {
      switch (url.toString()) {
        case "${BaseMockedHttpClient.baseUrl}/auth/v1/user?":
          expect(jsonDecode(body as dynamic)['data']['onboardingDone'], isTrue);
          onboardingDone = true;
          return http.Response(jsonEncode(userData), 200);
        default:
      }

      return super.put(url, headers: headers, body: body, encoding: encoding);
    });
  }
}

void main() async {
  testWidgets('User can go through onboarding then inspect profile',
      (tester) async {
    // Starts the app
    SharedPreferences.setMockInitialValues({});

    MockHttp mockHttp = MockHttp();
    Supabase.initialize(
        url: 'https://dpxddbjyjdscvuhwutwu.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRweGRkYmp5amRzY3Z1aHd1dHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NTQzNDcsImV4cCI6MjAyNjUzMDM0N30.0vB8huUmdJIYp3M1nMeoixQBSAX_w2keY0JsYj2Gt8c',
        httpClient: mockHttp,
        debug: false,
        authOptions: const FlutterAuthClientOptions(autoRefreshToken: false));

    SupabaseClient client = Supabase.instance.client;
    mocknvm.MockNewsViewModel nvm =
        await mocknvm.MockNewsViewModel.init(client);
    AuthModel auth = AuthModel(
        client,
        GoogleSignIn(
          serverClientId:
              '505202936017-bn8uc2veq2hv5h6ksbsvr9pr38g12gde.apps.googleusercontent.com',
        ));
    NewsSettingsViewModel nsvm = NewsSettingsViewModel(client);
    AlarmsViewModel avm = AlarmsViewModel(client);
    ProvidersViewModel pvm = ProvidersViewModel(client);
    await tester.pumpWidget(AppWrapper(
      nvm: nvm,
      auth: auth,
      avm: avm,
      nsvm: nsvm,
      pvm: pvm,
    ));

    // Login as guest
    final loginButton = find.byKey(const Key("signin-guest"));
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Util function to select an interest entry from a given list.
    Future<void> selectEntry(String entry, {bool last = false}) async {
      final entryButton = find.text(entry);
      await tester.tap(entryButton);
      await tester.pumpAndSettle();
      expect(find.textContaining(entry), findsOneWidget);

      await tester.tap(find.text(last ? "Finish" : "Next"));
      await tester.pumpAndSettle();
    }

    // Select a few interests.
    await selectEntry("Albania");
    await selectEntry("Lausanne");
    await selectEntry("Gaming");

    await tester.tap(find.textContaining("Add"));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining("RSS"));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining("Google News"));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining("Next"));
    await tester.pumpAndSettle();

    // Open the profile view.
    await tester.tap(find.byKey(const Key('profile')));
    await tester.pumpAndSettle();

    // Open the interests view.
    await tester.tap(find.text("Interests"));
    await tester.pumpAndSettle();

    // Checks that the interests are correctly displayed.
    expect(find.textContaining("Select countries"), findsOneWidget);
  });
}
