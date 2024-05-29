import 'package:actualia/views/loading_view.dart';
import 'package:actualia/views/no_news_view.dart';
import 'package:flutter/material.dart';
import 'package:actualia/widgets/news_text.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:provider/provider.dart';

class PastNewsView extends StatefulWidget {
  const PastNewsView({super.key});

  @override
  State<PastNewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<PastNewsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<NewsViewModel>(context, listen: false).getNewsList());
  }

  @override
  Widget build(BuildContext context) {
    Widget loading =
        const LoadingView(text: "Please wait while we fetch the news for you.");

    final newsViewModel = Provider.of<NewsViewModel>(context);
    final _newsList = newsViewModel.newsList;
    final hasNews = newsViewModel.hasNews;
    Widget body;

    if (_newsList.isEmpty) {
      if (hasNews) {
        body = loading;
      } else {
        body = const NoNewsView(
            title: "You don't have any news yet.",
            text:
                "The first one will be generated the first time the alarm goes off.");
      }
    } else {
      body = ListView.builder(
          itemCount: _newsList.length,
          itemBuilder: (context, index) {
            return NewsText(news: _newsList[index]);
          });
    }

    return body;
  }
}
