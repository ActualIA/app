import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/views/wizard_test_view.dart';
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
    NewsSettingsViewModel newsSettingsModel =
        Provider.of<NewsSettingsViewModel>(context);

    if (newsSettingsModel.settings != null &&
        newsSettingsModel.settings!.onboardingNeeded) {
      Future.microtask(() => Navigator.push(
          context, MaterialPageRoute(builder: (context) => WizardTestView())));
    }

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
          ),
          Text(
            "Is onboarding needed ? ${newsSettingsModel.settings?.onboardingNeeded}",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          OutlinedButton(
            onPressed: () async {
              print("Resetting onboarding...");
              newsSettingsModel.pushSettings(NewsSettings.defaults());
            },
            child: const Text('Reset onboarding'),
          ),
        ]);
  }
}
