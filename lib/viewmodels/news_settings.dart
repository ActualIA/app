import 'dart:developer';

import 'package:actualia/models/news_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsSettingsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  NewsSettings? _settings;

  NewsSettings? get settings => _settings;

  NewsSettingsViewModel() {
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    print("fetching settings...");
    try {
      final res = await supabase
          .from("news_settings")
          .select()
          .eq('created_by', supabase.auth.currentUser!.id)
          .maybeSingle();

      if (res == null) {
        _settings = NewsSettings.defaults();
        _settings!.onboardingNeeded = true;
        return;
      }
      _settings = NewsSettings(
          cities: List<String>.from(res['cities']),
          countries: List<String>.from(res['countries']),
          interests: List<String>.from(res['interests']),
          wantsCities: res['wants_cities'],
          wantsCountries: res['wants_countries'],
          wantsInterests: res['wants_interests'],
          onboardingNeeded: false);
      print("news settings up to date");
      notifyListeners();
    } catch (e) {
      print("Error fetching settings: $e");
      return;
    }
  }

  Future<bool> pushSettings(NewsSettings settings) async {
    print("Pushing new settings...");
    try {
      await supabase.from("news_settings").upsert({
        'created_by': supabase.auth.currentUser!.id,
        'cities': settings.cities,
        'countries': settings.countries,
        'interests': settings.interests,
        'wants_cities': settings.wantsCities,
        'wants_countries': settings.wantsCountries,
        'wants_interests': settings.wantsInterests,
      }, onConflict: 'created_by');
      print("Push new settings");
      fetchSettings();
      return true;
    } catch (e) {
      print("Error pushing settings: $e");
      return false;
    }
  }
}
