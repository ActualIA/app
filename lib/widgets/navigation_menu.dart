import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';

import '../models/navigation_menu.dart';

class ActualiaBottomNavigationBar extends StatefulWidget {
  final List<Destination> destinations;
  const ActualiaBottomNavigationBar({required this.destinations, super.key});

  @override
  State<ActualiaBottomNavigationBar> createState() =>
      _ActualiaBottomNavigationBar();
}

class _ActualiaBottomNavigationBar extends State<ActualiaBottomNavigationBar> {
  Views _currentView = Views.NEWS;

  void setCurrentViewState(Views view) {
    setState(() {
      _currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bar = Container(
      padding: const EdgeInsets.all(16.0),
      color: THEME_LIGHTGRAY,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.destinations.map((dest) {
          return RawMaterialButton(
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(UNIT_PADDING * 2))),
            onPressed: () {
              setCurrentViewState(dest.view);
              dest.onPressed(_currentView);
            },
            child: dest.view == _currentView
                ? Icon(
                    dest.icon,
                    color: THEME_BUTTON,
                    size: ICON_NAV_SIZE,
                  )
                : Icon(
                    dest.icon,
                    color: THEME_GREY,
                    size: ICON_NAV_SIZE,
                  ),
          );
        }).toList(),
      ),
    );

    return bar;
  }
}
