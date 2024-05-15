import 'package:actualia/models/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Correctly parses GNews provider", () {
    var prov = NewsProvider(url: "/google/news/:query/en");
    expect(prov.type, equals(ProviderType.google));
    expect(listEquals(prov.parameters, []), isTrue);
  });
  test("Correctly parses Telegram provider", () {
    var prov = NewsProvider(url: "/telegram/channel/clicnews");
    expect(prov.type, equals(ProviderType.telegram));
    expect(listEquals(prov.parameters, ["clicnews"]), isTrue);
  });
  test("Correctly parses RSS provider", () {
    var prov = NewsProvider(url: "http://rss.cnn.com/rss/cnn_topstories.rss");
    expect(prov.type, equals(ProviderType.rss));
    expect(
        listEquals(
            prov.parameters, ["http://rss.cnn.com/rss/cnn_topstories.rss"]),
        isTrue);
  });

  test("Correctly displays GNews provider", () {
    var prov = NewsProvider(url: "/google/news/:query/en");
    expect(prov.displayName(), equals("Google News"));
  });
  test("Correctly displays Telegram provider", () {
    var prov = NewsProvider(url: "/telegram/channel/clicnews");
    expect(prov.displayName(), equals("Telegram (clicnews)"));
  });
  test("Correctly displays RSS provider", () {
    var prov = NewsProvider(url: "http://rss.cnn.com/rss/cnn_topstories.rss");
    expect(prov.displayName(), equals("RSS (cnn)"));
  });

  test("Telegram provider is correctly built", () async {
    (await ProviderType.telegram.build(["clicnews"])).fold(
        (l) => expect(l.url, equals("/telegram/channel/clicnews")),
        (r) => fail("Provider build should have been successful"));
    (await ProviderType.telegram.build(["clic.news"]))
        .fold((l) => fail("Provider build should have failed"), (r) {});
  });
}
