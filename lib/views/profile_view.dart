import 'package:actualia/views/wizard_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:actualia/models/auth_model.dart';
import 'package:actualia/viewmodels/news_settings.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  @override
  State<ProfilePageView> createState() => _ProfilePageState();
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

  @override
  Widget build(BuildContext context) {
    AuthModel authModel = Provider.of<AuthModel>(context);
    NewsSettingsViewModel newsSettings =
        Provider.of<NewsSettingsViewModel>(context);

    String? _username = authModel.user?.email;
    List<String> _interests = newsSettings.settings?.interests ?? [];

    double verticalPadding = 20.0;
    double horizontalPadding = 16.0;

    Container line = Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: const Divider());

    Container fullLine = Container(child: const Divider());

    Widget profilePage = Center(
        child: ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        // Username display
        Container(
            padding: EdgeInsets.only(
                top: verticalPadding,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: verticalPadding / 2),
            child: Text("Hey, ${_username ?? "unknown"} !")),

        // Logout
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.only(
                  left: 2 * horizontalPadding, bottom: verticalPadding / 2),
              child: OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    print("Logout button pressed");
                    if (await authModel.signOut()) {
                      print("Logout successful !");
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Logout',
                      style: TextStyle(color: Colors.black)))),
        ]),

        fullLine,

        // User interests, initially folded but can be unfolded by clicking on "Interests"
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    // TODO 1 : Implement showig interests directly on this page
                    //isInterestUnfold.value = !isInterestUnfold.value;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WizardView(
                                  isInitialOnboarding: false,
                                )));
                    print("Click on Interests");
                  },
                  child: const Text('Interests'))),
        ]),

        // TODO 1 : Implement showig interests directly on this page
        /*
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          getInterests(),
        ]),
        */
        line,

        // Sources from which the user wants to be inform
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    print("Click on sources");
                  },
                  child: const Text('Sources'))),
        ]),

        line,

        // Alarm manager
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    print("Click on Alarm");
                  },
                  child: const Text('Alarm'))),
        ]),

        line,

        // Manage Storage
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    print("Click on \"Manage Storage\"");
                  },
                  child: const Text('Manage Storage'))),
        ]),

        line,

        // Narrator (voice) settings
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    print("Click on Narrator");
                  },
                  child: const Text('Narrator Settings'))),
        ]),

        line,

        // Accessibility
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    print("Click on Accessibility");
                  },
                  child: const Text('Accessibility'))),
        ]),

        fullLine,

        // Redirection to home page
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: 2 * verticalPadding, horizontal: horizontalPadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  onPressed: () {
                    print("Click on Done");
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
          padding: const EdgeInsets.fromLTRB(16, 96, 16, 16),
          child: profilePage),
    );
  }
}
