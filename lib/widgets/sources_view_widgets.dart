import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScrollableText extends StatelessWidget {
  final String text;

  const ScrollableText({this.text = "", super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Fira Code',
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.left,
              ),
            )));
  }
}

class DisplayOrigin extends StatelessWidget {
  final String origin;
  final String date;

  const DisplayOrigin({this.origin = "", this.date = "", super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Wrap(
          children: [
            Text(
              "Article from $origin,",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'EB Garamond',
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            Text(
              "published the $date",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'EB Garamond',
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            )
          ],
        ));
  }
}

class DisplayTitle extends StatelessWidget {
  final String title;

  const DisplayTitle({this.title = "", super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Title of the article : $title",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontFamily: 'EB Garamond',
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ));
  }
}
