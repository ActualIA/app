import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoNewsView extends StatefulWidget {
  final String title;
  final String? text;
  const NoNewsView({super.key, required this.title, required this.text});

  @override
  State<NoNewsView> createState() => _NoNewsViewState();
}

class _NoNewsViewState extends State<NoNewsView> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final newsViewModel = Provider.of<NewsViewModel>(context);

    Widget text = widget.text == null
        ? const SizedBox.shrink()
        : Text(
            widget.text!,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          );

    Widget view = RefreshIndicator(
        onRefresh: newsViewModel.generateAndGetNews,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                    vertical: UNIT_PADDING * 3, horizontal: UNIT_PADDING),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: UNIT_PADDING * 2),
                    text,
                  ],
                )),
          ],
        ));

    return view;
  }
}
