import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String text;
  const LoadingView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(UNIT_PADDING),
              child: Text(text,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center)),
          const Align(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
