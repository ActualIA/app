import 'package:actualia/widgets/sources_view_widgets.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';

class SourceView extends StatefulWidget {
  final String article;
  final String title;
  final String newsPaper;
  final String date;

  const SourceView(
      {this.article = "",
      this.title = "",
      this.date = "",
      this.newsPaper = "",
      super.key});

  @override
  State<SourceView> createState() => _SourceViewState();
}

class _SourceViewState extends State<SourceView> {
  late String _article;
  late String _title;
  late String _date;
  late String _newsPaper;

  @override
  void initState() {
    super.initState();
    //init _article, _title, _date and _newsPaper using widget.source
    _article = widget.article;
    _title = widget.title;
    _date = widget.date;
    _newsPaper = widget.newsPaper;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TopAppBar(
          enableReturnButton: true,
          onPressed: () => {Navigator.pop(context)},
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
              child: Column(
            children: [
              DisplayOrigin(origin: _newsPaper, date: _date),
              const SizedBox(height: 20),
              DisplayTitle(title: _title),
              const SizedBox(height: 20),
              ScrollableText(text: _article)
            ],
          )),
        ));
  }
}
