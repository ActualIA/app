//coverage:ignore-file

import 'package:actualia/models/auth_model.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/views/news_view.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/views/login_view.dart';
import 'package:actualia/views/wizard_view.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:actualia/viewmodels/news.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dpxddbjyjdscvuhwutwu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRweGRkYmp5amRzY3Z1aHd1dHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NTQzNDcsImV4cCI6MjAyNjUzMDM0N30.0vB8huUmdJIYp3M1nMeoixQBSAX_w2keY0JsYj2Gt8c',
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (context) => AuthModel(
              Supabase.instance.client,
              GoogleSignIn(
                serverClientId:
                    '505202936017-bn8uc2veq2hv5h6ksbsvr9pr38g12gde.apps.googleusercontent.com',
              ))),
      ChangeNotifierProvider(
          create: (context) => NewsViewModel(Supabase.instance.client)),
      ChangeNotifierProvider(
          create: (context) => NewsSettingsViewModel(Supabase.instance.client)),
    ],
    child: const App(),
  ));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of(context);
    late NewsSettingsViewModel newsSettings;

    Widget home;
    if (authModel.isSignedIn) {
      newsSettings = Provider.of(context);
      if (authModel.isOnboardingRequired) {
        if (newsSettings.settings == null) {
          home = const LoadingView(text: 'Fetching your settings...');
        } else {
          home = const WizardView(isInitialOnboarding: true);
        }
      } else {
        home = const NewsView();
      }
    } else {
      home = const Scaffold(
        body: LoginView(),
      );
    }

    return MaterialApp(
        title: 'ActualIA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5EDCE4)),
          useMaterial3: true,
        ),
        home: home);
  }
}
