import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/source_view.dart';
import 'package:flutter/material.dart';
import 'package:actualia/models/news.dart';

class NewsText extends StatelessWidget {
  final News news;
  const NewsText({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(
            UNIT_PADDING * 3, UNIT_PADDING * 1, UNIT_PADDING * 3, 0),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            NewsDateTitle(news: news),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: news.paragraphs
                  .map((paragraph) => GestureDetector(
                        onTap: () {
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
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ));
  }
}

class NewsDateTitle extends StatelessWidget {
  final News news;

  const NewsDateTitle({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    String parseDateTime(String dateString) {
      DateTime dateTime = DateTime.parse(dateString);
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
      return "${weekDays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}$suffix, ${dateTime.year}";
    }

    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
            horizontal: UNIT_PADDING, vertical: UNIT_PADDING * 2),
        children: <Widget>[
          Text(
            parseDateTime(news.date),
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(color: THEME_GREY, fontWeight: FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING / 2),
            child: Text(
              news.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(height: 1.2),
            ),
          ),
        ]);
  }
}
