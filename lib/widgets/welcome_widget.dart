import 'package:actualia/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Welcome ${authModel.user!.email}!",
            style: Theme.of(context).textTheme.headlineMedium,
          )
        ],
      ),
    );
  }
}
