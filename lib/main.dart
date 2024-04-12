import 'package:actualia/models/auth_model.dart';
import 'package:actualia/views/home_view.dart';
import 'package:actualia/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:actualia/views/news_view.dart';
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
      ChangeNotifierProvider(create: (context) => AuthModel(Supabase.instance.client)),
      ChangeNotifierProvider(create: (context) => NewsViewModel()),
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

    Widget body;
    if (authModel.isSignedIn) {
      body = const NewsView();
    } else {
      body = const LoginView();
    }

    return MaterialApp(
      title: 'ActualIA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(body: body),
    );
  }
}
