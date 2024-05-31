import 'dart:convert';

import 'package:actualia/models/auth_model.dart';
import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/response.dart';
import 'package:http/src/streamed_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/news_view.dart';
import 'utils.dart';

class MockHttp extends BaseMockedHttpClient {
  @override
  get extraUserMetadata => {"onboardingDone": true};

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return Future(() {
      switch (url.toString()) {
        case "${BaseMockedHttpClient.baseUrl}/auth/v1/logout?scope=local":
          return Response("", 204);
      }

      return super.post(url, headers: headers, body: body, encoding: encoding);
    });
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return Future(() {
      switch (request.url.toString()) {
        case "${BaseMockedHttpClient.baseUrl}/rest/v1/news_settings?select=%2A&created_by=eq.${BaseMockedHttpClient.uuid}":
          return response([
            {
              "id": 345,
              "created_at": "2024-04-30T14:39:28.189469+00:00",
              "created_by": "0448dda0-d373-4b73-8a04-7507af0b2d6c",
              "interests": "[\"Gaming\"]",
              "wants_interests": true,
              "countries": "[\"Albania\"]",
              "wants_countries": true,
              "cities": "[\"Lausanne\"]",
              "wants_cities": true,
              "user_prompt": null,
              "providers_id": null,
              "voice_wanted": null
            }
          ], 200, request);
      }

      return super.send(request);
    });
  }
}

class MockNewsViewModel extends NewsViewModel {
  MockNewsViewModel.create(super.supabase) : super.create();

  static Future<MockNewsViewModel> init(SupabaseClient supabase) async {
    MockNewsViewModel nvm = MockNewsViewModel.create(supabase);
    // nvm.offlineRecorder = await OfflineRecorder.create();
    return nvm;
  }
}

void main() {
  testWidgets('User can login and logout', (tester) async {
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
    MockNewsViewModel nvm = await MockNewsViewModel.init(client);
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
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("signin-guest")));
    await tester.pump(Durations.extralong2);

    await tester.tap(find.byKey(const Key("profile")));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("signin-guest")), findsOneWidget);
  });
}
