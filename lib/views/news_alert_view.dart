import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:actualia/widgets/play_button.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewsAlertView extends StatefulWidget {
  const NewsAlertView({super.key});

  @override
  State<NewsAlertView> createState() => _NewsAlertViewState();
}

class _NewsAlertViewState extends State<NewsAlertView> {
  int? transcriptId;

  Future<void> fetchTranscriptId(context) async {
    NewsViewModel news = Provider.of(context, listen: false);
    await news.fetchNews(DateTime.now());
    if (news.news?.audio != null) {
      setState(() {
        transcriptId = news.news!.transcriptId;
      });
    } else if (news.news != null) {
      await news.getAudioFile(news.news!);
      setState(() {
        transcriptId = news.news!.transcriptId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    AlarmsViewModel alarms = Provider.of(context);
    if (transcriptId == null) {
      Future.microtask(
          () async => {if (context.mounted) fetchTranscriptId(context)});
    }

    Widget maybePlayer = transcriptId != null
        ? PlayButton(
            transcriptId: transcriptId!,
            onPressed: alarms.stopAlarms,
            size: 200.0)
        : const CircularProgressIndicator();

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔔', style: TextStyle(fontSize: 70)),
            Text('📰', style: TextStyle(fontSize: 150)),
            Text('🔔', style: TextStyle(fontSize: 70)),
          ],
        ),
        maybePlayer,
        FilledButton.tonal(
            onPressed: () {
              alarms.stopAlarms();
              alarms.dismissAlarm();
            },
            child: Text(loc.alarmDismiss)),
      ],
    );

    return Scaffold(
      body: column,
      appBar: const TopAppBar(enableProfileButton: false),
    );
  }
}
