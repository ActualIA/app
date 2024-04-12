import 'dart:developer';
import 'package:actualia/models/news_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsSettingsViewModel extends ChangeNotifier {
  late final supabase;

  NewsSettingsViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
  }

  NewsSettings? _settings;

  @protected
  void setSettings(NewsSettings value) => {_settings = value};

  NewsSettings? get settings => _settings;

  Future<void> fetchSettings() async {
    try {
      final res = await supabase
          .from("news_settings")
          .select()
          .eq('created_by', supabase.auth.currentUser!.id)
          .single();

      _settings = NewsSettings(
        cities: List<String>.from(res['cities']),
        countries: List<String>.from(res['countries']),
        interests: List<String>.from(res['interests']),
        wantsCities: res['wants_cities'],
        wantsCountries: res['wants_countries'],
        wantsInterests: res['wants_interests'],
      );
      notifyListeners();
    } catch (e) {
      log("Error fetching settings: $e");
      _settings = NewsSettings(
          cities: [],
          countries: [],
          interests: [],
          wantsCities: true,
          wantsCountries: true,
          wantsInterests: true);
      return;
    }
  }

  Future<bool> pushSettings(NewsSettings settings) async {
    try {
      final res = await supabase.from("news_settings").upsert({
        'created_by': supabase.auth.currentUser!.id,
        'cities': settings.cities,
        'countries': settings.countries,
        'interests': settings.interests,
        'wants_cities': settings.wantsCities,
        'wants_countries': settings.wantsCountries,
        'wants_interests': settings.wantsInterests,
      }, onConflict: "created_by");
      return true;
    } catch (e) {
      log("Error pushing settings: $e");
      return false;
    }
  }
}
