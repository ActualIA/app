import 'dart:developer';

import 'package:actualia/viewmodels/rss_feed.dart';
import 'package:actualia/models/article.dart';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/widgets/sources_view_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  Widget build(BuildContext context) {
    Widget loading =
        const LoadingView(text: "Please wait while we fetch the news for you.");
    final RSSFeedViewModel viewModel = Provider.of<RSSFeedViewModel>(context);

    final List<Article> articles = viewModel.articles;

    if (!viewModel.hasNews) {
      Future.microtask(() =>
          Provider.of<RSSFeedViewModel>(context, listen: false)
              .getRawNewsList());
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
                  origin: article.origin,
                  sourceUrl: article.url);
            },
          ));
    }
  }
}
