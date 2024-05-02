import 'package:actualia/widgets/signin_controls.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    double viewWidth = MediaQuery.of(context).size.width;

    // would want it to be an svg, but too bad
    Image monogram =
        Image.asset('assets/img/monogram.png', width: .4 * viewWidth);

    return Center(
        child: ListView(
      shrinkWrap: true,
      children: <Widget>[
        UnconstrainedBox(child: monogram),
        const SignInControls(),
      ],
    ));
  }
}
