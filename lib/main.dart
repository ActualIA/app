import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/views/news_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://dpxddbjyjdscvuhwutwu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRweGRkYmp5amRzY3Z1aHd1dHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NTQzNDcsImV4cCI6MjAyNjUzMDM0N30.0vB8huUmdJIYp3M1nMeoixQBSAX_w2keY0JsYj2Gt8c',
  );
  runApp(ChangeNotifierProvider(
    create: (context) => NewsSettingsViewModel(),
    child: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OnboardingView(),
    );
  }
}
