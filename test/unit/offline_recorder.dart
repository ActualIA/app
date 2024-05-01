import 'dart:convert';

import 'package:actualia/models/news.dart';
import 'package:actualia/models/offline_recorder.dart';
import 'package:flutter_test/flutter_test.dart';

News testNews = News(
    title: "Test title",
    date: "17/10/2002",
    transcriptID: 0,
    audio: "./audio/test0",
    paragraphs: [
      Paragraph(
          transcript: "0",
          title:
              "Sweet Victory: Local Bakery Garners National Accolades for Inventive Cupcake Creations",
          date: "17/10/2002",
          content:
              "Local bakery wins national award for innovative cupcake flavors, residents celebrate with free tastings. Mayor commends efforts, hails bakery as symbol of community creativity and entrepreneurship.",
          source:
              "This news comes from \"The Daily Gazette,\" a renowned source for community updates and local achievements, highlighting the innovative cupcake flavors and celebratory atmosphere at a nearby bakery."),
      Paragraph(
          transcript: "0",
          title:
              "Groundbreaking Study Reveals Surprising Benefits of Meditation on Workplace Productivity",
          date: "17/10/2002",
          content:
              "In a groundbreaking study published by \"The Mindful Worker,\" researchers unveil unexpected advantages of meditation in boosting workplace productivity. Findings suggest that regular meditation practices can significantly enhance focus and efficiency.",
          source:
              "This news comes from \"The Mindful Worker,\" a leading publication dedicated to exploring the intersection of mindfulness and professional success."),
    ]);

void main() {
  test("Correct Serialisation and Deserialization", () {
    expect(News.fromJson(testNews.toJson()), equals(testNews));
  });
}
