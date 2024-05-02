import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/response.dart';
import 'package:http/src/streamed_response.dart';

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

void main() {
  testWidgets('User can login and logout', (tester) async {
    await tester.pumpWidget(AppWrapper(httpClient: MockHttp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("signin-guest")));
    await tester.pump(Durations.extralong2);

    await tester.tap(find.byKey(const Key("profile")));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("signin-guest")), findsOneWidget);
  });
}
