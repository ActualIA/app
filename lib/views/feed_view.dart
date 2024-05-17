import 'dart:developer';

import 'package:actualia/utils/themes.dart';
import 'package:actualia/widgets/sources_view_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

// TODO: Implement ViewModel plugging into existing EF.

class FeedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: ListView.builder(
          padding: const EdgeInsets.only(
              left: UNIT_PADDING * 3,
              right: UNIT_PADDING * 3,
              top: UNIT_PADDING * 3,
              bottom: UNIT_PADDING * 3),
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (context, i) => SourceArticle(
              article:
                  "Lorem ipsum dolor sit amet, officia excepteur ex fugiat reprehenderit enim labore culpa sint ad nisi Lorem pariatur mollit ex esse exercitation amet. Nisi animcupidatat excepteur officia. Reprehenderit nostrud nostrud ipsum Lorem est aliquip amet voluptate voluptate dolor minim nulla est proident. Nostrud officia pariatur ut officia. Sit irure elit esse ea nulla sunt ex occaecat reprehenderit commodo officia dolor Lorem duis laboris cupidatat officia voluptate. Culpa proident adipisicing id nulla nisi laboris ex in Lorem sunt duis officia eiusmod. Aliqua reprehenderit commodo ex non excepteur duis sunt velit enim. Voluptate laboris sint cupidatat ullamco ut ea consectetur et est culpa et culpa duis.<",
              title: "Lorem Ipsum #$i",
              date: "32nd Brem. 1999",
              origin: "hehe"),
        ));
  }
}
