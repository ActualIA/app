import 'dart:math';

import 'package:actualia/models/news_settings.dart';
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

    Container getInterests() {
      if (!isInterestUnfold.value) {
        // Nothing
        return Container();
      } else {
        // List of all interests
        return Container(
          padding: EdgeInsets.symmetric(
              vertical: verticalPadding, horizontal: horizontalPadding),
          child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _interests.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                        child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_interests[index])));
                  })),
        );
      }
    }

    isInterestUnfold.addListener(() {
      getInterests();
    });

    return SingleChildScrollView(
        child: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Username display
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.only(
                  top: verticalPadding,
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: verticalPadding / 2),
              child: Text("Hey, ${_username ?? "unknown"} !")),
        ]),

        // Logout
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.only(
                  left: 2 * horizontalPadding, bottom: verticalPadding / 2),
              child: OutlinedButton(
                  onPressed: () async {
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
                  },
                  child: const Text('Done',
                      style: TextStyle(color: Colors.black)))),
        ]),
      ],
    )));
  }
}
