import 'dart:developer';

import 'package:actualia/utils/common.dart';
import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScrollableText extends StatelessWidget {
  final String text;

  const ScrollableText({this.text = "", super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(style: Theme.of(context).textTheme.displaySmall, text),
    );
  }
}

class SourceOrigin extends StatelessWidget {
  final String origin;
  final String date;

  const SourceOrigin({this.origin = "", this.date = "", super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = parseDateTimeShort(this.date);
    return Text(
        style: Theme.of(context)
            .textTheme
            .displaySmall
            ?.copyWith(color: THEME_GREY),
        "$origin, $formattedDate");
  }
}

class SourceTitle extends StatelessWidget {
  final String title;

  const SourceTitle({this.title = "", super.key});

  @override
  Widget build(BuildContext context) {
    return Text(style: Theme.of(context).textTheme.titleMedium, title);
  }
}

class ArticleWidget extends StatelessWidget {
  final String title;
  final String date;
  final String origin;
  final String content;
  final String sourceUrl;

  const ArticleWidget(
      {this.title = "",
      this.origin = "",
      this.date = "",
      this.content = "",
      this.sourceUrl = "",
      super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: UNIT_PADDING, vertical: UNIT_PADDING * 2),
            children: <Widget>[
              SourceOrigin(origin: origin, date: date),
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: UNIT_PADDING / 2),
                  child: SourceTitle(title: title)),
            ]),
        ScrollableText(text: content),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.only(top: UNIT_PADDING * 2),
                child: FilledButton.tonal(
                  onPressed: () {
                    _launchInBrowser(Uri.parse(sourceUrl));
                  },
                  child: Text(
                      style: Theme.of(context).textTheme.displaySmall,
                      loc.sourceViewShort),
                ))
          ],
        )
      ],
    );
  }
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}
