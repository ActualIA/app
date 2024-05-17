import 'package:actualia/models/article.dart';
import 'package:actualia/models/news.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RSSFeedViewModel extends ChangeNotifier {
  late final List<Article> articles;

  // TODO: fill.

  RSSFeedViewModel(this.articles);
}
