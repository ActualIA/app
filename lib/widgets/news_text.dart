import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/source_view.dart';
import 'package:flutter/material.dart';
import 'package:actualia/models/news.dart';
import 'package:actualia/widgets/play_button.dart';

class NewsText extends StatelessWidget {
  final News news;
  const NewsText({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        NewsDateTitle(news: news),
        ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
              UNIT_PADDING * 3, UNIT_PADDING, UNIT_PADDING * 3, 0),
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
                                newsPaper: paragraph.source,
                                url: paragraph.url)));
                  },
                  child: Column(
                    children: [
                      Text(
                        paragraph.transcript,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Read more\n",
                            style: (Theme.of(context).textTheme.displaySmall)!
                                .apply(
                              color: THEME_BUTTON,
                              decoration: TextDecoration.underline,
                              decorationColor: THEME_BUTTON,
                              fontStyle: FontStyle.italic,
                            ),
                          ))
                    ],
                  )))
              .toList(),
        ),
        const Divider(
          height: UNIT_PADDING * 2,
          thickness: 0.5,
          indent: UNIT_PADDING * 3,
          endIndent: UNIT_PADDING * 3,
          color: THEME_GREY,
        )
      ],
    );
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

    Widget playButton = news.transcriptId == -1
        ? const SizedBox(width: 40, height: 40)
        : PlayButton(transcriptId: news.transcriptId);

    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
                UNIT_PADDING * 4.5, UNIT_PADDING * 2, UNIT_PADDING * 4.5, 0),
            child: Text(
              parseDateTime(news.date),
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(color: THEME_GREY, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: UNIT_PADDING),
              Align(alignment: Alignment.topLeft, child: playButton),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: UNIT_PADDING * 4.5),
                child: Text(
                  news.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(height: 1.2),
                ),
              ))
            ],
          )
        ]);
  }
}
