import 'package:actualia/views/loading_view.dart';
import 'package:actualia/views/no_news_view.dart';
import 'package:flutter/material.dart';
import 'package:actualia/widgets/news_text.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/share_button.dart';

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
    var loc = AppLocalizations.of(context)!;

    Widget loading = LoadingView(text: loc.newsLoading);

    final newsViewModel = Provider.of<NewsViewModel>(context);
    final newsList = newsViewModel.newsList;
    final hasNews = newsViewModel.hasNews;
    Widget body;

    if (newsList.isEmpty) {
      if (hasNews) {
        body = loading;
      } else {
        body = NoNewsView(
            title: loc.newsEmptyTitle, text: loc.newsEmptyDescription);
      }
    } else {
      var firstTranscript = newsList.first;
      body = Scaffold(
          body: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                return NewsText(news: newsList[index]);
              }),
          floatingActionButton: ExpandableFab(
            distance: 112,
            children: [
              ActionButton(
                onPressed: () => Share.share(firstTranscript.fullTranscript),
                icon: const Icon(Icons.text_fields),
              ),
              ActionButton(
                onPressed: () async => await Share.shareXFiles([
                  XFile(
                      // ignore: use_build_context_synchronously
                      '${(await getApplicationDocumentsDirectory()).path}/audios/${firstTranscript.transcriptId}.mp3')
                ], text: loc.newsShareAudio),
                icon: const Icon(Icons.audiotrack),
              ),
              ActionButton(
                onPressed: () => Share.share(
                    'https://actualia.app/shared/${firstTranscript.transcriptId}'),
                icon: const Icon(Icons.link),
              ),
            ],
          ));
    }
    return body;
  }
}
