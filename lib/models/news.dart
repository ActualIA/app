import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'news.g.dart';

@JsonSerializable()
class News {
  final String title;
  final String date;
  final int transcriptId;
  String? audio;
  final List<Paragraph> paragraphs;
  final String fullTranscript;

  News({
    required this.title,
    required this.date,
    required this.transcriptId,
    required this.audio,
    required this.paragraphs,
    required this.fullTranscript,
  });

  factory News.fromJson(dynamic json) {
    return News(
        title: json['title'] as String,
        date: json['date'] as String,
        transcriptId: json['transcriptID'] as int,
        audio: json['audio'] as String?,
        paragraphs: (json['paragraphs'] != null)
            ? (json["paragraphs"]) as List<Paragraph>
            : List.empty());
  }

  Map<String, dynamic> toJson() => _$NewsToJson(this);

  // Needed when deserializing
  @override
  bool operator ==(Object n) =>
      n is News &&
      n.title == title &&
      n.date == date &&
      n.transcriptId == transcriptId &&
      n.audio == audio &&
      listEquals(n.paragraphs, paragraphs);

  @override
  int get hashCode => super.hashCode;
}

@JsonSerializable()
class Paragraph {
  final String transcript; //Text of the paragraph
  final String source; //Newspaper or website where the article comes from
  final String url; //URL of the article
  final String title; //Title of the article
  final String date; //Date of the article
  final String content; //Content of the article

  Paragraph({
    required this.transcript,
    required this.source,
    required this.url,
    required this.title,
    required this.date,
    required this.content,
  });

  factory Paragraph.fromJson(dynamic json) => _$ParagraphFromJson(json);

  dynamic toJson() => _$ParagraphToJson(this);

  @override
  bool operator ==(Object other) {
    return other is Paragraph &&
        transcript == other.transcript &&
        source == other.source &&
        title == other.title &&
        date == other.date &&
        content == other.content;
  }

  @override
  int get hashCode => super.hashCode;
}
