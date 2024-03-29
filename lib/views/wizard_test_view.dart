import 'package:actualia/models/news_settings.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:flutter/material.dart';
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
  String? _city;
  String? _country;
  String? _interest1;
  String? _interest2;

  @override
  Widget build(BuildContext context) {
    NewsSettingsViewModel newsSettingsModel = Provider.of<NewsSettingsViewModel>(context, listen: false);
    NewsSettings newsSettingsDefault = NewsSettings.defaults();

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            //each formField is an entry in the wizard
            SelectorWithInstruction(
                (value) { setState(() { _country = value; }); },
                "Select a country",
                newsSettingsDefault.countries,
                "Country"),
            SelectorWithInstruction(
                (value) { setState(() { _city = value; }); },
                "Select a city",
                widget.cities,
                "City"
            ),
            TextFormFieldWithInstruction(
                (value) { setState(() { _interest1 = value; }); },
                "Enter a center of interest",
                "Interest 1"),
            TextFormFieldWithInstruction(
                (value) { setState(() { _interest2 = value; }); },
                "Enter a second center of interest",
                "Interest 2")
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 100,
          child: OutlinedButton(
            onPressed: () {
              log('country: $_country\n'
                  'city: $_city\n'
                  'interest1: $_interest1\n'
                  'interest2: $_interest2\n'
                  'data sent successfully');
              newsSettingsModel.pushSettings(newsSettingsDefault);
            },
            child: const Text(
              "Validate",
              textScaler: TextScaler.linear(2.0),
            ),
          ),
        ),
      )
    );
  }
}

