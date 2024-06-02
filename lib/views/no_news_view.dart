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

    Widget button = loading
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()])
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FilledButton.tonal(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(UNIT_PADDING))),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                await newsViewModel.generateAndGetNews();
              },
              child: Text(
                  style: Theme.of(context).textTheme.displayLarge,
                  loc.newsEmptyGenerateButton),
            )
          ]);

    Widget text = widget.text == null
        ? const SizedBox.shrink()
        : Text(
            widget.text!,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          );

    Widget view = ListView(
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
        button,
      ],
    );

    return view;
  }
}
