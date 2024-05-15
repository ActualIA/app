// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
      title: json['title'] as String,
      date: json['date'] as String,
      transcriptId: (json['transcriptID'] as num).toInt(),
      audio: json['audio'] as String?,
      paragraphs: (json['paragraphs'] as List<dynamic>)
          .map((e) => Paragraph.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'title': instance.title,
      'date': instance.date,
      'transcriptID': instance.transcriptId,
      'audio': instance.audio,
      'paragraphs': instance.paragraphs,
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
