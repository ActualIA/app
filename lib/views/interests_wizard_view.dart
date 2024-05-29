import 'dart:developer';
import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/views/providers_wizard_view.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import '../widgets/wizard_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InterestWizardView extends StatefulWidget {
  const InterestWizardView({super.key});

  @override
  State<InterestWizardView> createState() => _InterestWizardViewState();
}

// ignore: constant_identifier_names
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
    var loc = AppLocalizations.of(context)!;
    final NewsSettingsViewModel nsvm =
        Provider.of<NewsSettingsViewModel>(context);
    final AuthModel auth = Provider.of<AuthModel>(context);
    final NewsSettings predefined = NewsSettings.defaults();

    Widget countriesSelector = WizardSelector(
      items: predefined.predefinedCountries.map((e) => (e, e)).toList(),
      selectedItems: nsvm.settings!.countries.map((e) => (e, e)).toList(),
      onPressed: (selected) {
        setState(() {
          _selectedCountries = selected.map((e) => e.$2).toList();
          _step = WizardStep.CITIES;
        });
      },
      title: loc.wizardCountriesTitle,
      isInitialOnboarding: auth.isOnboardingRequired,
      onCancel: () {
        Navigator.pop(context);
      },
      key: const Key("countries-selector"),
    );

    Widget citiesSelector = WizardSelector(
      items: predefined.predefinedCities.map((e) => (e, e)).toList(),
      selectedItems: nsvm.settings!.cities.map((e) => (e, e)).toList(),
      onPressed: (selected) {
        setState(() {
          _selectedCities = selected.map((e) => e.$2).toList();
          _step = WizardStep.INTERESTS;
        });
      },
      title: loc.wizardCitiesTitle,
      isInitialOnboarding: auth.isOnboardingRequired,
      onCancel: () {
        setState(() {
          _step = WizardStep.COUNTRIES;
        });
      },
      key: const Key("cities-selector"),
    );

    Widget interestsSelector = WizardSelector(
      items: predefined.predefinedInterests.map((e) => (e, e)).toList(),
      selectedItems: nsvm.settings!.interests.map((e) => (e, e)).toList(),
      onPressed: (selected) async {
        setState(() {
          _selectedInterests = selected.map((e) => e.$2).toList();
        });
        NewsSettings toSend = NewsSettings(
            cities: _selectedCities,
            countries: _selectedCountries,
            interests: _selectedInterests,
            wantsCities: true,
            wantsCountries: true,
            wantsInterests: true,
            locale: loc.localeName);
        try {
          await nsvm.pushSettings(toSend);
          if (context.mounted) {
            if (auth.isOnboardingRequired) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProvidersWizardView()));
            } else {
              Navigator.pop(context);
            }
          }
        } catch (e) {
          log("Error in wizard: $e", name: "ERROR", level: Level.WARNING.value);
        }
      },
      title: loc.wizardInterestsTitle,
      buttonText: auth.isOnboardingRequired ? loc.next : loc.done,
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

    return WizardScaffold(body: body);
  }
}
