import 'dart:ui';

import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import '../widgets/wizard_widgets.dart';

class WizardTestView extends StatefulWidget {
  final List<String> countries = ["bob1", "bob2", "bob3"];  //TODO get a list of country
  final List<String> cities = ["mich1", "mich2", "mich3"]; //TODO get a list of cities? Does it make sense (too much possibilities)

  WizardTestView({super.key});

  @override
  State<StatefulWidget> createState() => _WizardTestViewState();
}

class _WizardTestViewState extends State<WizardTestView> {
  List<String> _cities = [];
  List<String> _countries = [];
  List<String> _interests = [];

  @override
  Widget build(BuildContext context) {
    NewsSettingsViewModel newsSettingsModel = Provider.of<NewsSettingsViewModel>(context, listen: false);
    NewsSettings newsSettingsDefault = NewsSettings.defaults();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 50, 16, 8.0),
          child: const Text(
            "Tell us more about your interests",
            textScaler: TextScaler.linear(2.0),
            style: TextStyle(
              fontFamily: 'EB Garamond',
              fontWeight: FontWeight.w700,
              color: Colors.black
            ),
            maxLines: 2,
          ),
        )
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            //each formField is an entry in the wizard
            SelectorWithInstruction(
                (value) { setState(() { _countries = value; }); },
                "Select some countries",
                newsSettingsDefault.countries,
                "Country"
            ),
            SelectorWithInstruction(
                (value) { setState(() { _cities = value; }); },
                "Select some cities",
                newsSettingsDefault.cities,
                "City"
            ),
            SelectorWithInstruction(
                (value) { setState(() { _interests = value; }); },
                "Select some interests",
                newsSettingsDefault.interests,
                "Interests"
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(205.0, 8.0, 16.0, 24.0),
        child: SizedBox(
          height: 60.0,
          child: OutlinedButton(
            onPressed: () {
              // log('countries: $_countries\n'
              //     'cities: $_cities\n'
              //     'interests: $_interests\n'
              //     'data sent successfully');
              NewsSettings toSend = NewsSettings(
                  cities: _cities,
                  countries: _countries,
                  interests: _cities,
                  wantsCities: true,
                  wantsCountries: true,
                  wantsInterests: true
              );
              // log('settings : $toSend');
              newsSettingsModel.pushSettings(toSend);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                width: 3.5,
                color: Colors.lightBlueAccent
              ),
              foregroundColor: Colors.lightBlueAccent,
            ),
            child: const Text(
              "Validate",
              textScaler: TextScaler.linear(1.75),
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Fira Code',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      )
    );
  }
}

