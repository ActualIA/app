import 'package:actualia/models/auth_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of(context);

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Welcome !',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          'You need to login before proceeding',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (_error != null) ...<Widget>[
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
        if (defaultTargetPlatform == TargetPlatform.android) ...<Widget>[
          OutlinedButton(
            child: const Text('Login with Google'),
            onPressed: () async {
              await authModel.signInWithGoogle();
            },
          )
        ],
        OutlinedButton(
          child: const Text('Login as actualia@example.com'),
          onPressed: () async {
            await authModel.signInWithFakeAccount();
          },
        )
      ],
    ));
  }
}
