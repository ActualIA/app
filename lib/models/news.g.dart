//coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
      title: json['title'] as String,
      date: json['date'] as String,
      transcriptId: json['transcriptId'] as int,
      audio: json['audio'] as String?,
      paragraphs: (json['paragraphs'] as List<Paragraph>)
          .map(Paragraph.fromJson)
          .toList(),
      fullTranscript: json['fullTranscript'] as String,
    );

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'title': instance.title,
      'date': instance.date,
      'transcriptId': instance.transcriptId,
      'audio': instance.audio,
      'paragraphs': instance.paragraphs,
      'fullTranscript': instance.fullTranscript,
    };

Paragraph _$ParagraphFromJson(Map<String, dynamic> json) => Paragraph(
      transcript: json['transcript'] as String,
      source: json['source'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ParagraphToJson(Paragraph instance) => <String, dynamic>{
      'transcript': instance.transcript,
      'source': instance.source,
      'url': instance.url,
      'title': instance.title,
      'date': instance.date,
      'content': instance.content,
    };
