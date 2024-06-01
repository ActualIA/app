import 'dart:developer';
import 'package:actualia/models/auth_model.dart';
import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/views/providers_wizard_view.dart';
import 'package:actualia/widgets/error.dart';
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
enum WizardStep { COUNTRIES, CITIES, INTERESTS, LOADING, ERROR }

class _InterestWizardViewState extends State<InterestWizardView> {
  late List<String> _selectedInterests;
  late List<String> _selectedCountries;
  late List<String> _selectedCities;
  late WizardStep _step;

  @override
  void initState() {
    super.initState();
    NewsSettingsViewModel nsvm =
        Provider.of<NewsSettingsViewModel>(context, listen: false);
    _selectedCountries = List<String>.from(nsvm.settings!.countries);
    _selectedCities = List<String>.from(nsvm.settings!.cities);
    _selectedInterests = List<String>.from(nsvm.settings!.interests);
    _step = WizardStep.COUNTRIES;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateListStateOnSelection<T>(T item, List<T> list) {
    setState(() {
      list.contains(item) ? list.remove(item) : list.add(item);
    });
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
      selectedItems: _selectedCountries.map((e) => (e, e)).toList(),
      onSelected: (item) {
        updateListStateOnSelection(item.$2, _selectedCountries);
      },
      title: loc.wizardCountriesTitle,
      key: const Key("countries-selector"),
    );

    Widget countriesBottomBar = WizardNavigationBottomBar(
        showCancel: !auth.isOnboardingRequired,
        onCancel: () {
          Navigator.pop(context);
        },
        rText: loc.next,
        rOnPressed: () {
          setState(() {
            _step = WizardStep.CITIES;
          });
        });

    Widget citiesSelector = WizardSelector(
      items: predefined.predefinedCities.map((e) => (e, e)).toList(),
      selectedItems: _selectedCities.map((e) => (e, e)).toList(),
      onSelected: (item) {
        updateListStateOnSelection(item.$2, _selectedCities);
      },
      title: loc.wizardCitiesTitle,
      key: const Key("cities-selector"),
    );

    Widget citiesBottomBar = WizardNavigationBottomBar(
        showCancel: !auth.isOnboardingRequired,
        onCancel: () {
          setState(() {
            _step = WizardStep.COUNTRIES;
            _selectedCities = List<String>.from(nsvm.settings!.cities);
          });
        },
        rText: loc.next,
        rOnPressed: () {
          setState(() {
            _step = WizardStep.INTERESTS;
          });
        });

    Widget interestsSelector = WizardSelector(
      items: predefined.predefinedInterests.map((e) => (e, e)).toList(),
      selectedItems: _selectedInterests.map((e) => (e, e)).toList(),
      onSelected: (item) {
        updateListStateOnSelection(item.$2, _selectedInterests);
      },
      title: loc.wizardInterestsTitle,
      key: const Key("interests-selector"),
    );

    Widget interestsBottomBar = WizardNavigationBottomBar(
        showCancel: !auth.isOnboardingRequired,
        onCancel: () {
          setState(() {
            _step = WizardStep.CITIES;
            _selectedInterests = List<String>.from(nsvm.settings!.interests);
          });
        },
        rText: auth.isOnboardingRequired ? loc.next : loc.done,
        rOnPressed: () async {
          NewsSettings toSend = NewsSettings(
              cities: _selectedCities,
              countries: _selectedCountries,
              interests: _selectedInterests,
              wantsCities: true,
              wantsCountries: true,
              wantsInterests: true,
              locale: loc.localeName,
              userPrompt: "");
          try {
            await nsvm.pushSettings(toSend);
            if (auth.isOnboardingRequired) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProvidersWizardView()));
            } else {
              if (context.mounted) Navigator.pop(context);
            }
          } catch (e) {
            log("Error in wizard: $e",
                name: "ERROR", level: Level.WARNING.value);
          }
        });

    Widget? body;
    Widget? bottomBar;
    switch (_step) {
      case WizardStep.COUNTRIES:
        body = countriesSelector;
        bottomBar = countriesBottomBar;
        break;
      case WizardStep.CITIES:
        body = citiesSelector;
        bottomBar = citiesBottomBar;
        break;
      case WizardStep.INTERESTS:
        body = interestsSelector;
        bottomBar = interestsBottomBar;
        break;
      case WizardStep.LOADING:
        body = LoadingView(text: loc.interestsWizardUpdating);
        bottomBar = const SizedBox();
        break;
      case WizardStep.ERROR:
        body = ErrorDisplayWidget(description: loc.interestsUpdateError);
        bottomBar = const SizedBox();
        break;
    }

    return WizardScaffold(
      body: body,
      bottomBar: bottomBar,
    );
  }
}
