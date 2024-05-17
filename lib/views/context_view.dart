import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';

class ContextView extends StatelessWidget {
  final String text;
  const ContextView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.fromLTRB(
                UNIT_PADDING * 2, UNIT_PADDING * 2, UNIT_PADDING * 2, 0),
            child: Text(
              "Here is some context regarding the text you just photographed:",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(height: 1.2),
            )),
        Container(
            padding: const EdgeInsets.all(UNIT_PADDING * 2),
            child: Text(text,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center)),
      ],
    );
  }
}
