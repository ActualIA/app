import 'package:actualia/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:actualia/widgets/news_text.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:provider/provider.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
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
    Widget body = _newsList.isEmpty
        ? loading
        : ListView.builder(
            itemCount: _newsList.length,
            itemBuilder: (context, index) {
              return NewsText(news: _newsList[index]);
            });
    return Scaffold(
      appBar: const TopAppBar(),
      body: body,
    );
  }
}
