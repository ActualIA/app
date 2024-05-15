import 'package:dartz/dartz.dart';

abstract class _ProviderFactory {
  const _ProviderFactory();

  /// Builds a NewsProvider from its different parameters.
  /// If one or more of the parameters is invalid, returns a list of errors for each one of them (in the same order as fed to the function).
  Future<Either<NewsProvider, List<String?>>> build(
      ProviderType type, List<String> values);
}

class _DefaultProviderFactory extends _ProviderFactory {
  const _DefaultProviderFactory();

  @override
  Future<Either<NewsProvider, List<String?>>> build(
          ProviderType type, List<String> values) async =>
      Left(NewsProvider(
          url: [type.basePath, ...values]
              .where((e) => e.isNotEmpty)
              .join(", ")));
}

class _TelegramProviderFactory extends _ProviderFactory {
  const _TelegramProviderFactory();

  static final _telegramIdRegex =
      RegExp(r"^(?:https://t\.me/|@)?([a-zA-Z0-9_-]+)$");

  @override
  Future<Either<NewsProvider, List<String?>>> build(
      ProviderType type, List<String> values) async {
    var match = _telegramIdRegex.firstMatch(values[0]);
    if (match != null) {
      return Left(NewsProvider(url: "${type.basePath}/${match.group(1)}"));
    } else {
      return const Right(["Must be a channel name or an invite link"]);
    }
  }
}

/// List all available provider types, as well as useful information for display
enum ProviderType {
  telegram("/telegram/channel", "Telegram",
      parameters: ["Channel ID"], factory: _TelegramProviderFactory()),
  google("/google/news/:query/en", "Google News"),
  rss("", "RSS", parameters: ["URL"]);

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

  Future<Either<NewsProvider, List<String?>>> build(List<String> values) {
    return _factory.build(this, values);
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
