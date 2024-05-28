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
}

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
}
