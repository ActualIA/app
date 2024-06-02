class Article {
  final String content;
  final String description;
  final String title;
  final String origin;
  final String date;
  final String url;

  const Article({
    this.content = "",
    this.title = "",
    this.description = "",
    this.date = "",
    this.origin = "",
    this.url = "",
  });

  @override
  bool operator ==(Object other) {
    if (other is! Article) {
      return false;
    }
    final a = other;

    return content == a.content &&
        title == a.title &&
        description == a.description &&
        date == a.date &&
        origin == a.origin &&
        url == a.url;
  }
}
