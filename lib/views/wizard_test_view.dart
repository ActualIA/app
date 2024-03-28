import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:developer';

class WizardTestView extends StatefulWidget {
  const WizardTestView({super.key});


  @override
  State<StatefulWidget> createState() => _WizardTestViewState();
}

class _WizardTestViewState extends State<WizardTestView> {
  String? country;
  String? city;
  String? interest1;
  String? interest2;

  @override
  Widget build(BuildContext context) {
      return Container(
        child: Scaffold(
          body: Container(
            margin: const EdgeInsets.fromLTRB(8.0, 40.0, 8.0, 8.0),
            child: Column(
              children: <Widget>[
                //each formField is an entry in the wizard
                const Text(
                  "Enter country",
                  textScaler: TextScaler.linear(1.5),
                ),
                TextFormField(
                    decoration: const InputDecoration(
                        icon: Icon(Icons.map),
                        labelText: "Country"
                    ),
                    onChanged: (String? val) {
                      country = val;
                    }
                ),
                const Text(
                  "Enter city",
                  textScaler: TextScaler.linear(1.5),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.location_city),
                      labelText: "city"
                  ),
                  onChanged: (String? val) {
                    city = val;
                  },
                ),
                const Text(
                    "Enter center of interest 1",
                    textScaler: TextScaler.linear(1.5),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.anchor),
                      labelText: "interest 1"
                  ),
                  onChanged: (String? val) {
                    interest1 = val;
                  },
                ),
                const Text(
                  "Enter center of interest 2",
                  textScaler: TextScaler.linear(1.5),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.anchor),
                      labelText: "interest 2"
                  ),
                  onChanged: (String? val) {
                    interest2 = val;
                  },
                )
              ],
            ),
          ),
          bottomNavigationBar: OutlinedButton(
            onPressed: sendData,
            child: const Text("Validate"),
          ),
        )
      );
  }

  bool isCountry(String? val) {
    //TODO implement, I think the logic should not be handled in the view
    return true;
  }

  bool isCity(String? val) {
    //TODO implement, I think the logic should not be handled in the view
    return false;
  }

  bool isInterestValid(String? val) {
    //TODO implement, I think the logic should not be handled in the view
    return true;
  }

  void sendData() {
    log('country: $country\n'
        'city: $city\n'
        'interest1: $interest1\n'
        'interest2: $interest2\n'
        'data sent successfully');
  }
}