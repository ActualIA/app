import 'package:actualia/views/rss_feed_view.dart';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:actualia/views/context_view.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/share_button.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/navigation_menu.dart';
import '../widgets/navigation_menu.dart';

class MasterView extends StatefulWidget {
  const MasterView({super.key});

  @override
  State<MasterView> createState() => _MasterView();
}

class _MasterView extends State<MasterView> {
  Views _currentViews = Views.NEWS;
  late List<Destination> _destinations;

  void setCurrentViewState(Views view) {
    setState(() {
      _currentViews = view;
    });
  }

  @override
  void initState() {
    super.initState();
    _destinations = [
      Destination(
          view: Views.NEWS,
          icon: Icons.newspaper,
          onPressed: setCurrentViewState),
      Destination(
          view: Views.CONTEXT,
          icon: Icons.camera,
          onPressed: setCurrentViewState),
      Destination(
          view: Views.FEED, icon: Icons.feed, onPressed: setCurrentViewState)
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    Widget? floatingButton;
    switch (_currentViews) {
      case Views.NEWS:
        body = const NewsView();
        final firstTranscript = Provider.of<NewsViewModel>(context).news;

        floatingButton = firstTranscript == null
            ? null
            : ExpandableFab(
                distance: 112,
                children: [
                  ActionButton(
                    onPressed: () =>
                        Share.share('${firstTranscript.fullTranscript}\n\n'
                            '${loc.newsShareText}'),
                    icon: const Icon(Icons.text_fields),
                  ),
                  ActionButton(
                    onPressed: () async => await Share.shareXFiles([
                      XFile(
                          // ignore: use_build_context_synchronously
                          '${(await getApplicationDocumentsDirectory()).path}/audios/${firstTranscript.transcriptId}.mp3')
                    ], text: loc.newsShareText),
                    icon: const Icon(Icons.audiotrack),
                  ),
                  ActionButton(
                    onPressed: () {
                      Provider.of<NewsViewModel>(context, listen: false)
                          .setNewsPublicInDatabase(firstTranscript);
                      Share.share(
                          'https://actualia.pages.dev/share?transcriptId=${firstTranscript.transcriptId}');
                    },
                    icon: const Icon(Icons.link),
                  ),
                ],
              );
        break;
      case Views.FEED:
        body = const FeedView();
        break;
      case Views.CONTEXT:
        body = const ContextView();
        floatingButton = FloatingActionButton(
          onPressed: () =>
              Provider.of<NewsRecognitionViewModel>(context, listen: false)
                  .takePictureAndProcess(),
          child: const Icon(Icons.camera_alt),

          /*
        IconButton(
          iconSize: 40,
          onPressed: () =>
              Provider.of<NewsRecognitionViewModel>(context, listen: false)
                  .takePictureAndProcess(),
          icon: Container(
              padding: const EdgeInsets.all(UNIT_PADDING / 4),
              child: const Icon(Icons.camera_alt)),
          color: THEME_BUTTON,
*/
        );
        break;
    }

    Widget screen = Scaffold(
      appBar: const TopAppBar(),
      floatingActionButton: floatingButton,
      bottomNavigationBar: ActualiaBottomNavigationBar(
        destinations: _destinations,
      ),
      body: body,
    );

    return screen;
  }
}
