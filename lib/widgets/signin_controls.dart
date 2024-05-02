import 'package:actualia/models/auth_model.dart';
import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SignInControls extends StatefulWidget {
  const SignInControls({super.key});

  @override
  State<SignInControls> createState() => _SignInControls();
}

class _SignInControls extends State<SignInControls> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of(context);
    SvgPicture googleLogo = SvgPicture.asset('assets/img/g_logo.svg');

    return Container(
        padding: const EdgeInsets.only(top: UNIT_PADDING * 2),
        child: Column(// lots of hardcoded values ! so fun
            children: <Widget>[
          ElevatedButton(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: UNIT_PADDING / 2, vertical: UNIT_PADDING),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          padding: const EdgeInsets.only(right: UNIT_PADDING),
                          child: googleLogo),
                      Text(
                          style: Theme.of(context).textTheme.titleSmall,
                          "Sign in with Google"),
                    ]),
              ),
              onPressed: () async {
                await authModel.signInWithGoogle();
              }),
          Container(
              padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING / 2),
              child: TextButton(
                onPressed: () async {
                  await authModel.signInWithFakeAccount();
                },
                key: const Key("signin-guest"),
                child: Text(
                    style: Theme.of(context).textTheme.titleSmall,
                    "Sign in as guest"),
              )),
          if (_error != null) ...<Widget>[
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ]));
  }
}
