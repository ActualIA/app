import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/interests_wizard_view.dart';
import 'package:flutter/material.dart';
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
    switch (e.name) {
      case "Interests":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const InterestWizardView()));
      default:
        debugPrint("Click on ${e.name}");
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
      shrinkWrap: true,
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
                  child: const Text('Done'))),
        ]),
      ],
    ));

    return Material(
      child: Container(
          padding: const EdgeInsets.fromLTRB(
              UNIT_PADDING, 6 * UNIT_PADDING, UNIT_PADDING, UNIT_PADDING),
          child: profilePage),
    );
  }
}
