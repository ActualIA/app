import 'dart:developer';

import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import '../widgets/wizard_widgets.dart';

class InterestWizardView extends StatefulWidget {
  const InterestWizardView({super.key});

  @override
  State<InterestWizardView> createState() => _InterestWizardViewState();
}

enum WizardStep { COUNTRIES, CITIES, INTERESTS }

class _InterestWizardViewState extends State<InterestWizardView> {
  late List<String> _selectedInterests;
  late List<String> _selectedCountries;
  late List<String> _selectedCities;
  late WizardStep _step;

  @override
  void initState() {
    super.initState();
    _step = WizardStep.COUNTRIES;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NewsSettingsViewModel nsvm =
        Provider.of<NewsSettingsViewModel>(context);
    final AuthModel auth = Provider.of<AuthModel>(context);
    final NewsSettings predefined = NewsSettings.defaults();

    Widget countriesSelector = WizardSelector(
      items: predefined.predefinedCountries,
      selectedItems: nsvm.settings!.countries,
      onPressed: (selected) {
        setState(() {
          _selectedCountries = selected;
          _step = WizardStep.CITIES;
        });
      },
      title: "Select countries",
      isInitialOnboarding: auth.isOnboardingRequired,
      onCancel: () {
        Navigator.pop(context);
      },
      key: const Key("countries-selector"),
    );

    Widget citiesSelector = WizardSelector(
      items: predefined.predefinedCities,
      selectedItems: nsvm.settings!.cities,
      onPressed: (selected) {
        setState(() {
          _selectedCities = selected;
          _step = WizardStep.INTERESTS;
        });
      },
      title: "Select cities",
      isInitialOnboarding: auth.isOnboardingRequired,
      onCancel: () {
        setState(() {
          _step = WizardStep.COUNTRIES;
        });
      },
      key: const Key("cities-selector"),
    );

    Widget interestsSelector = WizardSelector(
      items: predefined.predefinedInterests,
      selectedItems: nsvm.settings!.interests,
      onPressed: (selected) async {
        setState(() {
          _selectedInterests = selected;
        });
        NewsSettings toSend = NewsSettings(
            cities: _selectedCities,
            countries: _selectedCountries,
            interests: _selectedInterests,
            wantsCities: true,
            wantsCountries: true,
            wantsInterests: true);
        try {
          await nsvm.pushSettings(toSend);
          if (auth.isOnboardingRequired) {
            await auth.setOnboardingIsDone();
          } else {
            if (context.mounted) Navigator.pop(context);
          }
        } catch (e) {
          log("Error in wizard: $e", name: "ERROR", level: Level.WARNING.value);
        }
      },
      title: "Select interests",
      buttonText: "Finish",
      isInitialOnboarding: auth.isOnboardingRequired,
      onCancel: () {
        setState(() {
          _step = WizardStep.CITIES;
        });
      },
      key: const Key("interests-selector"),
    );

    Widget? body;
    switch (_step) {
      case WizardStep.COUNTRIES:
        body = countriesSelector;
        break;
      case WizardStep.CITIES:
        body = citiesSelector;
        break;
      case WizardStep.INTERESTS:
        body = interestsSelector;
        break;
    }

    return Scaffold(
        appBar: const TopAppBar(),
        body: Container(
          padding: const EdgeInsets.all(4 * UNIT_PADDING),
          alignment: Alignment.topCenter,
          child: body,
        ));
  }
}
