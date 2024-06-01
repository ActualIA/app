import 'dart:convert';

import 'package:actualia/models/article.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RSSFeedViewModel extends ChangeNotifier {
  List<Article>? _articles;
  late final SupabaseClient supabase;
  bool hasNews = false;

  void setArticles(List<Article> articles) {
    _articles = articles;
  }

  List<Article> get articles => _articles ?? [];

  RSSFeedViewModel(this.supabase);

  getRawNewsList() async {
    hasNews = false;
    final rawNewsList = await fetchRawNewsList();
    final articles = parseIntoArticles(rawNewsList);
    setArticles(articles);
    hasNews = true;
    notifyListeners();
  }

  Future<List<dynamic>> fetchRawNewsList() async {
    try {
      final res = await supabase.functions.invoke('generate-raw-feed');
      return jsonDecode(res.data);
    } catch (e) {
      hasNews = false;
      throw Exception("Failed to invoke generate-raw-feed function: $e");
    }
  }

  List<Article> parseIntoArticles(List<dynamic> items) {
    List<Article> art = items
        .where((item) => item != null)
        .map((item) => Article(
            description: item['description'],
            origin: item['source']['name'],
            url: item['url'],
            title: item['title'],
            date: item['publishedAt'],
            content: item['content']))
        .toList();
    return art;
  }
}
