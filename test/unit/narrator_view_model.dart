import "package:actualia/viewmodels/narrator.dart";
import "package:flutter/material.dart";
import 'package:flutter/foundation.dart';
import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  User? get currentUser => const User(
      id: "1234",
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{},
      aud: "aud",
      createdAt: "createdAt");
}

class FakeFailingQueryBuilder extends Fake implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder upsert(Object values,
      {String? onConflict,
      bool ignoreDuplicates = false,
      bool defaultToNull = true}) {
    final Map<String, dynamic> dict = values as Map<String, dynamic>;

    expect(dict["created_by"], equals("1234"));
    expect(dict["voice_wanted"], isTrue);

    throw UnimplementedError();
  }
}

class FakeFailingSupabaseClient extends Fake implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) {
    expect(table, equals("news_settings"));
    return FakeFailingQueryBuilder();
  }

  @override
  GoTrueClient get auth => FakeGoTrueClient();
}

void main() {
  test("pushVoiceWanted with failing SupabaseClient returns false", () async {
    final narrator = NarratorViewModel(FakeFailingSupabaseClient());
    expect(await narrator.pushVoiceWanted("echo"), isFalse);
  });

  test("setVoiceWanted sets voiceWanted", () {
    final narrator = NarratorViewModel(FakeFailingSupabaseClient());
    // ignore: invalid_use_of_protected_member
    narrator.setVoiceWanted("alloy");
    expect(narrator.voiceWanted, equals("alloy"));
  });

  test("capitalize returns capitalized string", () {
    expect(NarratorViewModel.capitalize("alloy"), equals("Alloy"));
  });

  test("fetchVoiceWanted with failing SupabaseClient sets voiceWanted to echo",
      () async {
    final narrator = NarratorViewModel(FakeFailingSupabaseClient());
    await narrator.fetchVoiceWanted();
    expect(narrator.voiceWanted, equals("echo"));
  });
}
