import 'dart:developer';

import 'package:actualia/models/article.dart';
import 'package:actualia/models/news.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RSSFeedViewModel extends ChangeNotifier {
  late final List<Article> articles;
  late final SupabaseClient supabase;

  Future<List<dynamic>> fetchRawNewsList() async {
    try {
      final res = await supabase.functions.invoke('generate-raw-feed');
      return res.data as List<News>;
    } catch (e) {
      throw Exception("Failed to invoke generate-raw-feed function");
    }
  }

  RSSFeedViewModel(this.articles);
}
