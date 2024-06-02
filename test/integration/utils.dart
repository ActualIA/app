// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:actualia/main.dart';
import 'package:actualia/models/auth_model.dart';
import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppWrapper extends StatelessWidget {
  final AuthModel? auth;
  final NewsViewModel? nvm;
  final NewsSettingsViewModel? nsvm;
  final ProvidersViewModel? pvm;
  final AlarmsViewModel? avm;

  const AppWrapper({
    required this.auth,
    required this.nvm,
    required this.nsvm,
    required this.pvm,
    required this.avm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => auth),
        ChangeNotifierProvider(create: (context) => nvm),
        ChangeNotifierProvider(create: (context) => nsvm),
        ChangeNotifierProvider(create: (context) => pvm),
        ChangeNotifierProvider(create: (context) => avm),
      ],
      child: const App(),
    );
  }
}

// Mocked HttpClient implementing only the guest authentication requests.
class BaseMockedHttpClient extends Fake implements Client {
  http.StreamedResponse response(
      dynamic body, int statusCode, http.BaseRequest request) {
    var res = jsonEncode(body).codeUnits;
    return http.StreamedResponse(Stream.fromIterable([res]), statusCode,
        request: request, contentLength: res.length);
  }

  static const String baseUrl = "https://dpxddbjyjdscvuhwutwu.supabase.co";
  static const String uuid = "00000000-0000-0000-0000-000000000000";
  static const String accessToken =
      "eyJhbGciOiJIUzI1NiIsImtpZCI6InhUbGZqNjBHZHFzVmlmUEEiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoyMDAwMDAwMDAwLCJpYXQiOjIwMDAwMDA1MDAsImlzcyI6Imh0dHBzOi8vZHB4ZGRianlqZHNjdnVod3V0d3Uuc3VwYWJhc2UuY28vYXV0aC92MSIsInN1YiI6IjA0NDhkZGEwLWQzNzMtNGI3My04YTA0LTc1MDdhZjBiMmQ2YyIsImVtYWlsIjoiYWN0dWFsaWFAZXhhbXBsZS5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7ImVtYWlsIjoiYWN0dWFsaWFAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInBob25lX3ZlcmlmaWVkIjpmYWxzZSwic3ViIjoiMDQ0OGRkYTAtZDM3My00YjczLThhMDQtNzUwN2FmMGIyZDZjIn0sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3MTQ0Nzk1NDV9XSwic2Vzc2lvbl9pZCI6IjdlNzVhMmE1LTQ0YjYtNDU3MS1iNTFkLThkYmExY2JkMWI5MyIsImlzX2Fub255bW91cyI6ZmFsc2V9.QiuomIIA0cuGcdIXlTeOm4N95qzjTvUM0UkI1gvCxP0";

  dynamic get extraUserMetadata => {};
  dynamic get userData => {
        "id": uuid,
        "aud": "authenticated",
        "role": "authenticated",
        "email": "actualia@example.com",
        "email_confirmed_at": "2024-04-30T12:19:05.934212069Z",
        "phone": "",
        "last_sign_in_at": "2024-04-30T12:19:05.937201913Z",
        "app_metadata": {
          "provider": "email",
          "providers": ["email"]
        },
        "user_metadata": {
          "email": "actualia@example.com",
          "email_verified": false,
          "phone_verified": false,
          "sub": uuid,
          ...extraUserMetadata
        },
        "identities": [
          {
            "identity_id": "cc18cb14-f02d-4fd2-ac84-40846764cfeb",
            "id": uuid,
            "user_id": uuid,
            "identity_data": {
              "email": "actualia@example.com",
              "email_verified": false,
              "phone_verified": false,
              "sub": uuid
            },
            "provider": "email",
            "last_sign_in_at": "2024-04-30T12:19:05.92670308Z",
            "created_at": "2024-04-30T12:19:05.926754Z",
            "updated_at": "2024-04-30T12:19:05.926754Z",
            "email": "actualia@example.com"
          }
        ],
        "created_at": "2024-04-30T12:19:05.922289Z",
        "updated_at": "2024-04-30T12:19:05.941017Z",
        "is_anonymous": false
      };

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    print("Unmocked url fetched with `get`: ${url.toString()}");
    throw UnimplementedError();
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return Future(() {
      var b = json.decode(body as String);

      switch (url.toString()) {
        case "$baseUrl/auth/v1/token?grant_type=password":
          expect(b['email'], equals("actualia@example.com"));
          expect(b['password'], equals("actualia"));
          return Response(
              jsonEncode({
                "access_token": accessToken,
                "token_type": "bearer",
                "expires_in": 3600,
                "expires_at": 2000000000,
                "refresh_token": "2IgxVlIyikNSCD_V20IMVQ",
                "user": userData
              }),
              200);
        case "$baseUrl/auth/v1/token?grant_type=refresh_token":
          return Response(
              jsonEncode({
                "access_token": accessToken,
                "token_type": "bearer",
                "expires_in": 3600,
                "expires_at": 2000000000,
                "refresh_token": "yLZQCjM_LguWSKyo-ONyoA",
                "user": userData
              }),
              200);
        default:
          print(
              "Unmocked url fetched with `post`: ${url.toString()} - ${body.toString()}");
      }
      throw UnimplementedError(url.toString());
    });
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    print(
        "Unmocked url fetched with `patch`: ${url.toString()} - ${body.toString()}");
    throw UnimplementedError();
  }

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    print(
        "Unmocked url fetched with `delete`: ${url.toString()} - ${body.toString()}");
    throw UnimplementedError();
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    print(
        "Unmocked url fetched with `put`: ${url.toString()} - ${body.toString()}");
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    print("Unmocked url fetched with `read`: ${url.toString()}");
    throw UnimplementedError();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.url.toString().startsWith(
        "${BaseMockedHttpClient.baseUrl}/rest/v1/news?select=%2A")) {
      return Future.value(response([], 200, request));
    }
    if (request.url.toString() ==
        "${BaseMockedHttpClient.baseUrl}/functions/v1/generate-transcript") {
      return Future.value(response("", 200, request));
    }

    print(
        "Unmocked url fetched with `send`: ${request.url.toString()} - ${request is http.Request ? request.body : ""}");
    throw UnimplementedError();
  }
}

// Each test file must have a name.
void main() {}
