import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/providers.dart';

class ProvidersViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;
  List<NewsProvider>? _newsProviders;

  ProvidersViewModel(this.supabase) {
    fetchNewsProviders();
  }

  List<NewsProvider>? get newsProviders => _newsProviders;
  void setNewsProviders(List<NewsProvider> newsProviders) {
    _newsProviders = newsProviders;
  }

  List<String> providersToString(List<NewsProvider> providers) {
    return providers.map((e) => e.displayName()).toList();
  }

  List<String> rssToUrl(List<NewsProvider> providers) {
    return providers.map((e) => (e as RSSFeedProvider).url).toList();
  }

  List<NewsProvider> stringToProviders(List<String> names) {
    return names.map((e) {
      switch (e) {
        case "Google News":
          return GNewsProvider() as NewsProvider;
        default:
          log("Unknown provider name: $e", level: Level.WARNING.value);
          return GNewsProvider() as NewsProvider;
      }
    }).toList();
  }

  Future<bool> fetchNewsProviders() async {
    try {
      final res = await supabase
          .from('news_providers')
          .select()
          .eq("created_by", supabase.auth.currentUser!.id);

      _newsProviders =
          res.map((m) => NewsProvider.deserialize(m["type"])!).toList();
      log("fetch result: $_newsProviders",
          name: "DEBUG", level: Level.WARNING.value);
      return true;
    } catch (e) {
      log("Error when fetching news providers: $e",
          name: "ERROR", level: Level.WARNING.value);
      _newsProviders = [];
      return false;
    }
  }

  Future<bool> pushNewsProviders() async {
    try {
      final List<dynamic>? toPush =
          _newsProviders?.map((e) => e.serialize()).toList();
      for (var p in toPush!) {
        await supabase.from("news_providers").upsert({
          "created_by": supabase.auth.currentUser!.id,
          "type": p,
        });
      }
      return true;
    } catch (e) {
      log("Error when pushing news providers: $e",
          name: "ERROR", level: Level.WARNING.value);
      return false;
    }
  }
}
