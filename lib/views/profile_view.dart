// ignore_for_file: constant_identifier_names

import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/narrator_settings_view.dart';
import 'package:actualia/views/news_alert_setup_view.dart';
import 'package:actualia/views/interests_wizard_view.dart';
import 'package:actualia/views/providers_wizard_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:actualia/models/auth_model.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  @override
  State<ProfilePageView> createState() => _ProfilePageState();
}

enum SettingsRows {
  INTERESTS("Interests"),
  SOURCES("Sources"),
  ALARM("Alarm"),
  STORAGE("Storage"),
  NARRATOR("Narrator"),
  ACCESSIBILITY("Accessibility");

  const SettingsRows(this.name);
  final String name;
}

class _ProfilePageState extends State<ProfilePageView> {
  ValueNotifier<bool> isInterestUnfold = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    isInterestUnfold.addListener(() {
      build(context);
    });
  }

  void handleRowTap(SettingsRows e) {
    switch (e) {
      case SettingsRows.INTERESTS:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const InterestWizardView()));
        break;
      case SettingsRows.SOURCES:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ProvidersWizardView()));
        break;
      case SettingsRows.ALARM:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NewsAlertSetupView()));
      case SettingsRows.NARRATOR:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NarratorSettingsView()));
      default:
        debugPrint("Click on ${e.name}");
        Fluttertoast.showToast(
            msg: "The view for ${e.name} is not yet implemented.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color.fromARGB(255, 22, 231, 105),
            textColor: Colors.white,
            fontSize: 16.0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of<AuthModel>(context);

    String? _username = authModel.user?.email;

    Widget profilePage = Center(
        child: ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        // Username display
        Container(
            padding: const EdgeInsets.symmetric(
                vertical: UNIT_PADDING / 2, horizontal: UNIT_PADDING * 2),
            alignment: Alignment.centerLeft,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(style: Theme.of(context).textTheme.titleLarge, "Hello!"),
                  Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: UNIT_PADDING,
                        horizontal: 1.5 * UNIT_PADDING,
                      ),
                      child: Text(
                          style: Theme.of(context).textTheme.bodyMedium,
                          _username ?? "Unknown User")),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.pop(context);
                      await authModel.signOut();
                    },
                    child: const Text(
                        style: TextStyle(fontFamily: "Fira Code"), "Logout"),
                  )
                ])),

        Container(
            padding: const EdgeInsets.all(UNIT_PADDING),
            child: ListView.separated(
              itemCount: SettingsRows.values.length,
              shrinkWrap: true,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                SettingsRows row = SettingsRows.values[index];
                return ListTile(
                    dense: true,
                    title: Text(
                        style: Theme.of(context).textTheme.displaySmall,
                        row.name),
                    titleAlignment: ListTileTitleAlignment.center,
                    onTap: () {
                      handleRowTap(row);
                    });
              },
            )),

        // Redirection to home page
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: UNIT_PADDING),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyMedium, // Small
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Done',
                      style: TextStyle(color: Colors.black)))),
        ]),
      ],
    ));

    return Material(
      elevation: 5.0,
      child: Container(
          padding: const EdgeInsets.fromLTRB(
              UNIT_PADDING, 6 * UNIT_PADDING, UNIT_PADDING, UNIT_PADDING),
          child: profilePage),
    );
  }
}
