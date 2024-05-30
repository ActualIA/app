import 'package:http/http.dart' as http;

import 'package:dartz/dartz.dart';
import 'package:xml/xml.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class _ProviderFactory {
  const _ProviderFactory();

  /// Builds a NewsProvider from its different parameters.
  /// If one or more of the parameters is invalid, returns a list of errors for each one of them (in the same order as fed to the function).
  Future<Either<NewsProvider, List<String?>>> build(
      ProviderType type, List<String> values, AppLocalizations loc);
}

class _DefaultProviderFactory extends _ProviderFactory {
  const _DefaultProviderFactory();

  @override
  Future<Either<NewsProvider, List<String?>>> build(
          ProviderType type, List<String> values, AppLocalizations loc) async =>
      Left(NewsProvider(
          url: [type.basePath, ...values]
              .where((e) => e.isNotEmpty)
              .join(", ")));
}

class TelegramProviderFactory extends _ProviderFactory {
  const TelegramProviderFactory();

  static final _telegramIdRegex =
      RegExp(r"^(?:https://t\.me/|@)?([a-zA-Z0-9_-]+)$");

  @override
  Future<Either<NewsProvider, List<String?>>> build(
      ProviderType type, List<String> values, AppLocalizations loc) async {
    var match = _telegramIdRegex.firstMatch(values[0]);
    if (match != null) {
      return Left(NewsProvider(url: "${type.basePath}/${match.group(1)}"));
    } else {
      return Right([loc.telegramInvalidId]);
    }
  }
}

class RSSFeedProviderFactory extends _ProviderFactory {
  const RSSFeedProviderFactory({this.client});

  final http.Client? client;

  /// Simple paths which may point to a rss feed.
  static const paths = [
    "/feed/",
    "/rss/",
    "/blog/feed/",
    "/blog/rss/",
    "/rss.xml",
    "/blog/rss.xml",
    "/pageslug?format=rss"
  ];

  /// Regex matching any XML attribute containing either "rss" or "feed"
  static final _rssUrlAttributeRegex =
      RegExp(r'"([^"]*(feed|rss)[^"]*)"', caseSensitive: false);

  Future<http.Response> _get(Uri url) {
    if (client != null) {
      return client!.get(url);
    } else {
      return http.get(url);
    }
  }

  /// Checks whether a url is a rss document.
  ///
  /// To do so, it requests the url, parses it as a XML file and looks for a <rss></rss> tag.
  Future<bool> _isRss(Uri url) async {
    try {
      var document = XmlDocument.parse((await _get(url)).body);
      return document.findAllElements("rss").isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<Uri>> _listFromSitemap(Uri url) async {
    try {
      var document =
          XmlDocument.parse((await _get(url.resolve("/sitemap.xml"))).body);

      return document
          .findAllElements("loc")
          .map((e) =>
              e.innerText.contains(RegExp("(rss|feed)", caseSensitive: false))
                  ? Uri.tryParse(e.innerText)
                  : null)
          .whereType<Uri>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// List all the urls that may point to a rss feed in a string. Should be used on HTML documents.
  List<String> _listRssUrl(String input) {
    var r = _rssUrlAttributeRegex
        .allMatches(input)
        .map((m) => m.group(1))
        .whereType<String>()
        .toList();
    return r;
  }

  @override
  Future<Either<NewsProvider, List<String?>>> build(
      ProviderType type, List<String> values, AppLocalizations loc) async {
    try {
      var url = Uri.parse(values[0]);
      var document = (await http.get(url)).body;

      // Finds a related RSS feed by iterating over a list of predefined uris often used for feeds.
      var urls = [
        url,
        ...paths.map((e) => url.resolve(e)),
        ..._listRssUrl(document).map((e) => Uri.tryParse(e)).whereType<Uri>(),
        ...(await _listFromSitemap(url))
      ];

      var feeds = (await Future.wait(
              urls.map((e) => _isRss(e).then((value) => (e, value)))))
          .where((element) => element.$2);

      if (feeds.isNotEmpty) {
        return Left(NewsProvider(url: feeds.firstOrNull!.$1.toString()));
      } else {
        return Right([loc.rssFeedNotFound]);
      }
    } catch (e) {
      return Right([loc.rssInvalidUrl]);
    }
  }
}

/// List all available provider types, as well as useful information for display
enum ProviderType {
  telegram("/telegram/channel", "Telegram",
      parameters: ["Channel ID"], factory: TelegramProviderFactory()),
  google("gnews", "Google News"),
  rss("", "RSS", parameters: ["URL"], factory: RSSFeedProviderFactory()),
  leTemps("https://www.letemps.ch/articles.rss", "Le Temps",
      factory: RSSFeedProviderFactory()),
  twentyMinutes("https://partner-feeds.20min.ch/rss/20minutes", "20 Minutes CH",
      factory: RSSFeedProviderFactory()),
  epfl("https://actu.epfl.ch/feeds/rss/fr/", "Actu EPFL",
      factory: RSSFeedProviderFactory()),
  rts("https://www.rts.ch/info/suisse?format=rss/news", "RTS",
      factory: RSSFeedProviderFactory());

  /// Base url of the provider, used for matching
  final String basePath;

  /// Name of the provider
  final String displayName;

  /// Display name of the additional parameters.
  /// They are appended in the url in the same order as provided.
  final List<String> parameters;

  final _ProviderFactory _factory;

  const ProviderType(this.basePath, this.displayName,
      {this.parameters = const [],
      _ProviderFactory factory = const _DefaultProviderFactory()})
      : _factory = factory;

  Future<Either<NewsProvider, List<String?>>> build(
      List<String> values, AppLocalizations loc) {
    return _factory.build(this, values, loc);
  }
}

class NewsProvider {
  final String url;
  late final ProviderType type;
  late final List<String> parameters;

  NewsProvider({required this.url}) {
    type = ProviderType.values.firstWhere((e) => url.startsWith(e.basePath));
    if (type == ProviderType.rss) {
      parameters = [url];
    } else {
      parameters = url
          .substring(ProviderType.values
              .firstWhere((e) => url.startsWith(e.basePath))
              .basePath
              .length)
          .split("/")
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  String displayName() {
    if (type == ProviderType.rss) {
      var name = (RegExp(r"https?:\/\/(?:[^./]+\.)*([^./]+)\.[^./]+(?:\/.*)?")
                  .firstMatch(url)
                  ?.group(1) ??
              "")
          .replaceAll("[^a-zA-Z0-9]", " ");

      return "RSS ($name)";
    } else {
      return parameters.isEmpty
          ? type.displayName
          : "${type.displayName} (${parameters.join(", ")})";
    }
  }
}
