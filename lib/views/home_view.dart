import 'package:actualia/models/auth_model.dart';
import 'package:actualia/widgets/welcome_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of(context);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const WelcomeWidget(),
          OutlinedButton(
            onPressed: () async {
              print("Logout button pressed");
              if (await authModel.signOut()) {
                print("Logout successful !");
              }
            },
            child: const Text('Logout'),
          )
        ]);
  }
}
