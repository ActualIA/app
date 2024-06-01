import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:actualia/views/context_view.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    Widget? floatingButton;
    switch (_currentViews) {
      case Views.NEWS:
        body = const NewsView();
        break;
      case Views.FEED:
        body = Center(child: Text(loc.notImplemented));
        break;
      case Views.CONTEXT:
        body = const ContextView();
        floatingButton = IconButton.filledTonal(
          iconSize: 40,
          onPressed: () => Provider.of<NewsRecognitionViewModel>(context),
          icon: Container(
              padding: const EdgeInsets.all(UNIT_PADDING / 4),
              child: const Icon(Icons
                  .sync_outlined)), // Chosen because it represents the act of doing an action again, which here is the case because they have to take a new picture
          color: THEME_BUTTON,
        );
        break;
      default:
        body = Center(child: Text(loc.notImplemented));
        break;
    }

    Widget screen = Scaffold(
      appBar: const TopAppBar(),
      floatingActionButton: floatingButton,
      bottomNavigationBar: ActualiaBottomNavigationBar(
        destinations: _destinations,
      ),
      body: body,
    );

    return screen;
  }
}
