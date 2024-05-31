import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef EditedProviderData = (
  ProviderType type,
  List<String> values,
  List<String?>? errors
);

class ProvidersViewModel extends ChangeNotifier {
  late final SupabaseClient supabase;

  List<NewsProvider>? _newsProviders;

  List<NewsProvider>? get newsProviders => _newsProviders;

  List<EditedProviderData> get editedProviders => _editedProviders;
  late List<EditedProviderData> _editedProviders;

  bool isPushing = false;

  ProvidersViewModel(this.supabase) {
    fetchNewsProviders();
  }

  void setNewsProviders(List<NewsProvider> newsProviders) {
    _newsProviders = newsProviders;
    notifyListeners();
  }

  Future<bool> fetchNewsProviders() async {
    try {
      final res = await supabase
          .from('news_settings')
          .select("providers")
          .eq("created_by", supabase.auth.currentUser!.id)
          .single();

      _newsProviders = (res["providers"] as List<dynamic>)
          .map((e) => NewsProvider(url: e))
          .toList();
      _editedProviders = _newsProviders!
          .map((e) => (e.type, e.parameters.toList(), null as List<String?>?))
          .toList(growable: true);
      notifyListeners();

      log("fetch result: $_newsProviders", level: Level.FINEST.value);
      return true;
    } catch (e) {
      log("Could not fetch news providers: $e", level: Level.WARNING.value);
      _newsProviders = [];
      _editedProviders = [];
      notifyListeners();
      return false;
    }
  }

  void updateProvidersFromEdited() {
    _newsProviders = _editedProviders
        .map((e) => NewsProvider(
            url: [e.$1.basePath, ...e.$2].where((e) => e.isNotEmpty).join("/")))
        .toList();
    notifyListeners();
  }

  void addEditedProvider() {
    _editedProviders.add((ProviderType.rss, [""], null));
    notifyListeners();
  }

  void removeEditedProvider(int index) {
    _editedProviders.removeAt(index);
    notifyListeners();
  }

  void updateEditedProvider(int index, ProviderType type, List<String> values) {
    _editedProviders[index] = (type, values, null);
    // Does not call notifyListeners() to avoid redrawing the edition widgets.
  }

  Future<bool> pushNewsProviders(AppLocalizations loc) async {
    try {
      isPushing = true;
      notifyListeners();

      var providers =
          await Future.wait(editedProviders.map((e) => e.$1.build(e.$2, loc)));

      // If an error occurred, reports it and do not push.
      if (providers.any((e) => e.isRight())) {
        for (var (i, provider) in providers.indexed) {
          _editedProviders[i] = (
            _editedProviders[i].$1,
            _editedProviders[i].$2,
            provider.fold((l) => null, (r) => r)
          );
        }

        isPushing = false;
        notifyListeners();

        return false;
      }

      await supabase.from("news_settings").update({
        "providers": providers
            .map((e) => e.fold((l) => l.url, (r) => throw AssertionError()))
            .toList()
      }).eq("created_by", supabase.auth.currentUser!.id);

      isPushing = false;
      notifyListeners();

      return true;
    } catch (e) {
      log("Could not push news providers: $e", level: Level.WARNING.value);

      isPushing = false;
      notifyListeners();

      return false;
    }
  }
}
