import 'dart:developer';

import 'package:actualia/viewmodels/rss_feed.dart';
import 'package:actualia/models/article.dart';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/widgets/sources_view_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

// TODO: Implement ViewModel plugging into existing EF.

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<RSSFeedViewModel>(context, listen: false).geRawNewsList());
  }

  @override
  Widget build(BuildContext context) {
    Widget loading =
        const LoadingView(text: "Please wait while we fetch the news for you.");
    final RSSFeedViewModel viewModel = Provider.of<RSSFeedViewModel>(context);

    final List<Article> articles = viewModel.articles;

    if (!viewModel.hasNews) {
      return loading;
    } else {
      return Container(
          alignment: Alignment.center,
          child: ListView.builder(
            padding: const EdgeInsets.all(UNIT_PADDING * 3),
            shrinkWrap: true,
            itemCount: articles.length,
            itemBuilder: (context, i) {
              Article article = articles[i];
              return ArticleWidget(
                  content: article.content,
                  title: article.title,
                  date: article.date,
                  origin: article.origin);
            },
          ));
    }
  }
}
