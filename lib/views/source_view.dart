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
  late String _origin;
  late String _url;

  @override
  void initState() {
    super.initState();
    // init _article, _title, _date and _newsPaper using widget.source
    _article = widget.article;
    _title = widget.title;
    _date = widget.date;
    _origin = widget.newsPaper;
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
          child: SourceArticle(
              title: _title,
              date: _date,
              origin: _origin,
              article: _article,
              sourceUrl: _url)),
    );
  }
}
