import 'package:actualia/views/source_view.dart';
import 'package:flutter/material.dart';
import 'package:actualia/models/news.dart';

class NewsText extends StatelessWidget {
  final News news;
  const NewsText({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(news.date);
    List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    String suffix;
    if (dateTime.day == 1 || dateTime.day == 21 || dateTime.day == 31) {
      suffix = "st";
    } else if (dateTime.day == 2 || dateTime.day == 22) {
      suffix = "nd";
    } else if (dateTime.day == 3 || dateTime.day == 23) {
      suffix = "rd";
    } else {
      suffix = "th";
    }
    String date =
        "${weekDays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}$suffix, ${dateTime.year}";
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            //Box containing the title and the date
            //NB : The alignment will change after we add the button to play the audio
            //Note for audio : Use the transcriptID and audio fields from the news.
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
                  news.title,
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
              children: news.paragraphs
                  .map((paragraph) => GestureDetector(
                        onTap: () {
                          //TODO: Action for the source button
                          //Note for source: Use the fields
                          //"source", "title", "date" and "content"
                          //from the paragraph.
                          print("Source du paragraphe: ${paragraph.source}");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => SourceView(
                                      article: paragraph.content,
                                      title: paragraph.title,
                                      date: paragraph.date.substring(0, 10),
                                      newsPaper: paragraph.source)));
                        },
                        child: Text(
                          '${paragraph.transcript}\n',
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
