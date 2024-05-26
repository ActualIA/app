import 'package:actualia/models/article.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RSSFeedViewModel extends ChangeNotifier {
  List<Article>? _articles;
  late final SupabaseClient supabase;
  bool hasNews = false;

  @protected
  void setArticles(List<Article> articles) {
    _articles = articles;
  }

  List<Article> get articles => _articles ?? [];

  RSSFeedViewModel(this.supabase);

  geRawNewsList() async {
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
      return res.data as List<dynamic>;
    } catch (e) {
      hasNews = false;
      throw Exception("Failed to invoke generate-raw-feed function");
    }
  }

  List<Article> parseIntoArticles(List<dynamic> items) {
    return items
        .map((item) => Article(
              title: item['title'],
              description: item['description'],
              content: item['content'],
              origin: item['source']['name'],
              url: item['source']['url'],
              date: item['publishedAt'],
            ))
        .toList();
  }
}
