import 'package:actualia/models/article.dart';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/widgets/sources_view_widgets.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';

class SourceView extends StatefulWidget {
  final Article article;

  const SourceView({this.article = const Article(), super.key});

  @override
  State<SourceView> createState() => _SourceViewState();
}

class _SourceViewState extends State<SourceView> {
  late Article _article;
  late String _content;
  late String _title;
  late String _date;
  late String _origin;
  late String _url;

  @override
  void initState() {
    super.initState();
    // init _article, _title, _date and _newsPaper using widget.source
    _article = widget.article;

    // ugly, yes
    _content = _article.content;
    _title = _article.title;
    _date = _article.date;
    _origin = _article.origin;
    _url = _article.url;
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
          child: ArticleWidget(
              title: _title,
              date: _date,
              origin: _origin,
              content: _content,
              sourceUrl: _url)),
    );
  }
}
