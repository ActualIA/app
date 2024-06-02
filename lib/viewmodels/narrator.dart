import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NarratorViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;
  String _voiceWanted = "echo";

  NarratorViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
  }

  @protected
  void setVoiceWanted(String value) => {_voiceWanted = value};

  String get voiceWanted => _voiceWanted;

  Future<void> fetchVoiceWanted() async {
    try {
      final res = await supabase
          .from("news_settings")
          .select()
          .eq('created_by', supabase.auth.currentUser!.id)
          .single();

      _voiceWanted = res['voice_wanted'] ?? "echo";
      notifyListeners();
    } catch (e) {
      log("Error fetching voice wanted: $e", level: Level.WARNING.value);
      _voiceWanted = "echo";
      notifyListeners();
      return;
    }
  }

  Future<bool> pushVoiceWanted(String voiceWanted) async {
    try {
      await supabase.from("news_settings").upsert({
        'created_by': supabase.auth.currentUser!.id,
        'voice_wanted': voiceWanted,
      }, onConflict: "created_by");
      setVoiceWanted(voiceWanted);
      notifyListeners();
      return true;
    } catch (e) {
      log("Error pushing voice wanted: $e", level: Level.SEVERE.value);
      return false;
    }
  }

  static String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }
}
