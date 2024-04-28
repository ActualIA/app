import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wizard_widgets.dart';

class WizardView extends StatefulWidget {
  final bool isInitialOnboarding;

  const WizardView({this.isInitialOnboarding = false, super.key});

  @override
  State<StatefulWidget> createState() => _WizardViewState();
}

class _WizardViewState extends State<WizardView> {
  List<String> _cities = [];
  List<String> _countries = [];
  List<String> _interests = [];

  @override
  Widget build(BuildContext context) {
    NewsSettingsViewModel? newsSettingsModel;
    NewsSettings newsSettingsDefault = NewsSettings.defaults();
    NewsSettings? fromDB;

    newsSettingsModel = Provider.of<NewsSettingsViewModel>(context);
    fromDB = newsSettingsModel.settings;

    if (fromDB!.countries.isNotEmpty) {
      _countries = fromDB.countries;
    }
    if (fromDB.cities.isNotEmpty) {
      _cities = fromDB.cities;
    }
    if (fromDB.interests.isNotEmpty) {
      _interests = fromDB.interests;
    }

    PreferredSizeWidget appBar = PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 50, 16, 8.0),
          child: const Text(
            "Tell us more about your interests",
            textScaler: TextScaler.linear(2.0),
            style: TextStyle(
                fontFamily: 'EB Garamond',
                fontWeight: FontWeight.w700,
                color: Colors.black),
            maxLines: 2,
          ),
        ));

    Widget body = Container(
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: ListView(
        /// temp mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          //each formField is an entry in the wizard
          SelectorWithInstruction(
            (value) {
              setState(() {
                _countries = value;
              });
            },
            "Select some countries",
            newsSettingsDefault.predefinedCountries,
            "Country",
            selectedItems: _countries,
            key: const Key("country-selector"),
          ),
          SelectorWithInstruction(
            (value) {
              setState(() {
                _cities = value;
              });
            },
            "Select some cities",
            newsSettingsDefault.predefinedCities,
            "City",
            selectedItems: _cities,
            key: const Key("city-selector"),
          ),
          SelectorWithInstruction(
            (value) {
              setState(() {
                _interests = value;
              });
            },
            "Select some interests",
            newsSettingsDefault.predefinedInterests,
            "Interests",
            selectedItems: _interests,
            key: const Key("interest-selector"),
          )
        ],
      ),
    );

    Widget bottomBar = WizardNavigationBottomBar(
        showLeft: !widget.isInitialOnboarding,
        lText: 'Cancel',
        lOnPressed: () {
          Navigator.pop(context);
        },
        showRight: true,
        rText: 'Validate',
        rOnPressed: () {
          NewsSettings toSend = NewsSettings(
            cities: _cities,
            countries: _countries,
            interests: _interests,
            wantsCities: true,
            wantsCountries: true,
            wantsInterests: true,
            onboardingNeeded: false,
          );
          newsSettingsModel?.pushSettings(toSend);
          //todo nav to main screen
          if (!widget.isInitialOnboarding) {
            Navigator.pop(context);
          }
        });

    return Scaffold(appBar: appBar, body: body, bottomNavigationBar: bottomBar);
  }
}
