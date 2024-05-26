import 'dart:convert';
import 'dart:developer';
import 'package:actualia/models/news_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsSettingsViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;

  NewsSettingsViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
    fetchSettings();
  }

  NewsSettings? _settings;
  int? _settingsId;

  @protected
  void setSettings(NewsSettings value) => {_settings = value};

  NewsSettings? get settings => _settings;
  int? get settingsId => _settingsId;

  String get locale => settings?.locale ?? "en";

  void setLocale(String? loc) {
    if (_settings != null) _settings!.locale = loc ?? "en";
    notifyListeners();
  }

  Future<void> fetchSettings() async {
    try {
      final res = await supabase
          .from("news_settings")
          .select()
          .eq('created_by', supabase.auth.currentUser!.id)
          .single();

      _settings = NewsSettings(
          cities: List<String>.from(jsonDecode(res['cities'])),
          countries: List<String>.from(jsonDecode(res['countries'])),
          interests: List<String>.from(jsonDecode(res['interests'])),
          wantsCities: res['wants_cities'],
          wantsCountries: res['wants_countries'],
          wantsInterests: res['wants_interests'],
          locale: res['locale']);
      _settingsId = res['id'];
      notifyListeners();
    } catch (e) {
      log("Error fetching settings: $e", level: Level.WARNING.value);
      _settings = NewsSettings.defaults();
      notifyListeners();
      return;
    }
  }

  Future<bool> pushSettings(NewsSettings? settings) async {
    NewsSettings set = settings ?? _settings ?? NewsSettings.defaults();

    try {
      await supabase.from("news_settings").upsert({
        'created_by': supabase.auth.currentUser!.id,
        'cities': set.cities,
        'countries': set.countries,
        'interests': set.interests,
        'wants_cities': set.wantsCities,
        'wants_countries': set.wantsCountries,
        'wants_interests': set.wantsInterests,
        'locale': set.locale
      }, onConflict: "created_by");
      fetchSettings();
      return true;
    } catch (e) {
      log("Error pushing settings: $e", level: Level.WARNING.value);
      return false;
    }
  }
}
