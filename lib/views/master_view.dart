import 'dart:developer';

import 'package:actualia/views/rss_feed_view.dart';
import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:actualia/views/context_view.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import '../models/navigation_menu.dart';
import '../widgets/navigation_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          icon: Icons.camera_alt,
          onPressed: setCurrentViewState),
      Destination(
          view: Views.FEED, icon: Icons.feed, onPressed: setCurrentViewState)
    ];
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    Widget body;
    switch (_currentViews) {
      case Views.NEWS:
        body = const NewsView();
        break;
      case Views.FEED:
        body = const FeedView();
        break;
      case Views.CONTEXT:
        body = const ContextView();
        break;
      default:
        body = Center(child: Text(loc.notImplemented));
        break;
    }

    Widget screen = Scaffold(
      appBar: const TopAppBar(),
      bottomNavigationBar: ActualiaBottomNavigationBar(
        destinations: _destinations,
      ),
      body: body,
    );

    return screen;
  }
}
