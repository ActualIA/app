import 'dart:developer';

import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
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
  late String? _ocrText;

  void setCurrentViewState(Views view) {
    if (view != Views.CAMERA) {
      setState(() {
        _currentViews = view;
      });
    }
  }

  Future<void> cameraButtonPressed(Views view) async {
    log("Camera button pressed on navigation bar", level: Level.INFO.value);
    NewsRecognitionViewModel newsRecognitionVM =
        Provider.of<NewsRecognitionViewModel>(context, listen: false);
    XFile? image = await newsRecognitionVM.takePicture();

    if (image != null) {
      _ocrText = await newsRecognitionVM.ocr(image.path);
      setState(() {
        _currentViews = Views.CONTEXT;
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
          onPressed: cameraButtonPressed),
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
        body = const Center(child: Text("To be implemented"));
        break;
      case Views.CONTEXT:
        body = Center(child: Text(_ocrText ?? "No text found"));
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
