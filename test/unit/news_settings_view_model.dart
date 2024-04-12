import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    expect(listEquals(dict["cities"], []), isTrue);
    expect(listEquals(dict["countries"], []), isTrue);
    expect(listEquals(dict["interests"], ["Biology"]), isTrue);
    expect(dict["wantsCities"], isFalse);
    expect(dict["wantsCountries"], isFalse);
    expect(dict["wantsInterests"], isTrue);

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
  test("Push failure is reported", () async {
    NewsSettingsViewModel vm =
        NewsSettingsViewModel(FakeFailingSupabaseClient());

    expect(
        await vm.pushSettings(NewsSettings(
            interests: ["Biology"],
            cities: [],
            countries: [],
            wantsCities: false,
            wantsCountries: false,
            wantsInterests: true)),
        isFalse);
  });
}
