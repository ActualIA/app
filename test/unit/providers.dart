import 'package:actualia/models/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

class RssClient extends Fake implements Client {
  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    return Response(
        "<!DOCTYPE html><html><head><meta charset='utf-8'><meta http-equiv='X-UA-Compatible' content='IE=edge'><title>NY Times</title></head><body><a href=\"https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml\"></a></body></html>",
        200);
  }
}

void main() {
  test("Correctly parses GNews provider", () {
    var prov = NewsProvider(url: "gnews");
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
    var prov = NewsProvider(url: "gnews");
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

  test("RSS discovery", () async {
    (await ProviderType.rss.build(["http://nytimes.com"])).fold(
        (l) => expect(
            l.url,
            equals(
                "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml")),
        (r) => fail("Provider build should have been successful"));
  });
}
