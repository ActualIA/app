// ignore_for_file: constant_identifier_names

import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/views/accessibility.dart';
import 'package:actualia/views/news_alert_setup_view.dart';
import 'package:actualia/views/interests_wizard_view.dart';
import 'package:actualia/views/providers_wizard_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:actualia/models/auth_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  @override
  State<ProfilePageView> createState() => _ProfilePageState();
}

enum SettingsRows {
  INTERESTS("profileInterests"),
  SOURCES("profileSources"),
  ALARM("profileAlarm"),
  STORAGE("profileStorage"),
  NARRATOR("profileNarrator"),
  ACCESSIBILITY("profileAccessibility");

  String displayName(AppLocalizations loc) {
    switch (key) {
      case "profileInterests":
        return loc.profileInterests;
      case "profileSources":
        return loc.profileSources;
      case "profileAlarm":
        return loc.profileAlarm;
      case "profileStorage":
        return loc.profileStorage;
      case "profileNarrator":
        return loc.profileNarrator;
      case "profileAccessibility":
        return loc.profileAccessibility;
    }

    throw Exception("Unknown profile menu key: $key");
  }

  const SettingsRows(this.key);

  final String key;
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
      case SettingsRows.ACCESSIBILITY:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AccessibilityView()));
      default:
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.notImplemented,
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
    var loc = AppLocalizations.of(context)!;
    AuthModel authModel = Provider.of<AuthModel>(context);

    String? username = authModel.user?.email;

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
                  Text(
                      style: Theme.of(context).textTheme.titleLarge,
                      loc.profileGreeting),
                  Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: UNIT_PADDING,
                        horizontal: 1.5 * UNIT_PADDING,
                      ),
                      child: Text(
                          style: Theme.of(context).textTheme.bodyMedium,
                          username ?? loc.profileUnknownUser)),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.pop(context);
                      await authModel.signOut();
                    },
                    child: Text(
                        style: const TextStyle(fontFamily: "Fira Code"),
                        loc.logout),
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
                        row.displayName(loc)),
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
                  child: Text(loc.done,
                      style: const TextStyle(color: Colors.black)))),
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
