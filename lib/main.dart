import 'package:actualia/models/user_model.dart';
import 'package:actualia/views/home_view.dart';
import 'package:actualia/views/login_view.dart';
import 'package:actualia/views/wizard_test_view.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userModel = UserModel();

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://dpxddbjyjdscvuhwutwu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRweGRkYmp5amRzY3Z1aHd1dHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NTQzNDcsImV4cCI6MjAyNjUzMDM0N30.0vB8huUmdJIYp3M1nMeoixQBSAX_w2keY0JsYj2Gt8c',
  );
  runApp(ChangeNotifierProvider(
    create: (context) => userModel,
    child: const App(),
  ));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = userModel.isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ActualIA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WizardTestView()
      // Scaffold(
      //   appBar: AppBar(
      //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //     title: const Text('ActualIA'),
      //   ),
      //   body: Column(
      //     children: <Widget>[
      //       if (_isLoggedIn)
      //         const HomeView(title: 'ActualIA - Welcome page')
      //       else
      //         const LoginView(title: 'ActualIA - Login page'),
      //     ],
      //   )
      // )

    );
  }
}
