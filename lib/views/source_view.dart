import 'package:actualia/models/article.dart';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/widgets/sources_view_widgets.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';

class SourceView extends StatefulWidget {
  final Article article;

  const SourceView({required this.article, super.key});

  @override
  State<SourceView> createState() => _SourceViewState();
}

class _SourceViewState extends State<SourceView> {
  late Article _article;

  @override
  void initState() {
    super.initState();
    // init _article, _title, _date and _newsPaper using widget.source
    _article = widget.article;
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
            physics: const AlwaysScrollableScrollPhysics(),
            article: _article,
          )),
    );
  }
}
