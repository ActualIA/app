import 'package:actualia/utils/themes.dart';
import 'package:actualia/widgets/sources_view_widgets.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SourceView extends StatefulWidget {
  final String article;
  final String title;
  final String newsPaper;
  final String date;
  final String url;

  const SourceView(
      {this.article = "",
      this.title = "",
      this.date = "",
      this.newsPaper = "",
      this.url = "",
      super.key});

  @override
  State<SourceView> createState() => _SourceViewState();
}

class _SourceViewState extends State<SourceView> {
  late String _article;
  late String _title;
  late String _date;
  late String _newsPaper;
  late String _url;

  @override
  void initState() {
    super.initState();
    // init _article, _title, _date and _newsPaper using widget.source
    _article = widget.article;
    _title = widget.title;
    _date = widget.date;
    _newsPaper = widget.newsPaper;
    _url = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        enableReturnButton: true,
        onPressed: () => {Navigator.pop(context)},
      ),
      body: Container(
          padding: const EdgeInsets.all(UNIT_PADDING * 3),
          child: ListView(
            children: <Widget>[
              ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: UNIT_PADDING, vertical: UNIT_PADDING * 2),
                  children: <Widget>[
                    SourceOrigin(origin: _newsPaper, date: _date),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: UNIT_PADDING / 2),
                        child: SourceTitle(title: _title)),
                  ]),
              ScrollableText(text: _article),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.only(top: UNIT_PADDING * 2),
                      child: FilledButton.tonal(
                        onPressed: () {
                          _launchInBrowser(Uri.parse(_url));
                        },
                        child: Text(
                            style: Theme.of(context).textTheme.displaySmall,
                            "View site"),
                      ))
                ],
              )
            ],
          )),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
