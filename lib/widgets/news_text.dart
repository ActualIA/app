import 'package:flutter/material.dart';

class NewsText extends StatelessWidget {
  final String title;
  final String date;
  final List<Paragraph> paragraphs;

  const NewsText(
      {super.key,
      required this.title,
      required this.date,
      required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            //Box containing the title and the date
            //NB : The alignment will change after we add the button to play the audio
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFFCDCDDC),
                    fontSize: 8,
                    fontFamily: 'Fira Code',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontFamily: 'EB Garamond',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 64.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: paragraphs
                  .map((paragraph) => GestureDetector(
                        onTap: () {
                          //TODO: Action for the source button
                          print("Source du paragraphe: ${paragraph.source}");
                        },
                        child: Text(
                          '${paragraph.text}\n',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Fira Code',
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Paragraph {
  final String text;
  final String source;

  Paragraph({required this.text, required this.source});
}
