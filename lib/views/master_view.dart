import 'dart:developer';

import 'package:actualia/views/rss_feed_view.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../models/navigation_menu.dart';
import '../widgets/navigation_menu.dart';

class MasterView extends StatefulWidget {
  const MasterView({super.key});

  @override
  State<MasterView> createState() => _MasterView();
}

class _MasterView extends State<MasterView> {
  Views _currentViews = Views.NEWS;
  late List<Destination> _destinations;

  void setCurrentViewState(Views view) {
    if (view == Views.CAMERA) {
      log("Camera button pressed on navigation bar",
          level: Level.WARNING.value);
    } else {
      setState(() {
        _currentViews = view;
      });
    }
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
          view: Views.CAMERA,
          icon: Icons.camera_alt,
          onPressed: setCurrentViewState),
      Destination(
          view: Views.FEED, icon: Icons.feed, onPressed: setCurrentViewState)
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentViews) {
      case Views.NEWS:
        body = const NewsView();
        break;
      case Views.CAMERA:
        body = const Center(child: Text("To be implemented"));
        break;
      case Views.FEED:
        body = const FeedView();
        break;
      default:
        body = const Center(child: Text("SHOULD NOT BE DISPLAYED"));
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
