import 'dart:developer';

import 'package:actualia/models/news_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsSettingsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  late NewsSettings _settings;

  NewsSettings get settings => _settings;

  Future<void> fetchSettings() async {
    final res = await supabase
        .from("news_settings")
        .select()
        .eq('created_by', supabase.auth.currentUser!.id)
        .single();

    if (res['error'] != null) {
      log("Error fetching settings: ${res['error'].message}");
      return;
    }

    _settings = NewsSettings(
      cities: List<String>.from(res['cities']),
      countries: List<String>.from(res['countries']),
      interests: List<String>.from(res['interests']),
      wantsCities: res['wants_cities'],
      wantsCountries: res['wants_countries'],
      wantsInterests: res['wants_interests'],
    );
    notifyListeners();
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
      });
      return true;
    } catch (e) {
      log("Error pushing settings: $e");
      return false;
    }
  }
}
