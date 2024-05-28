import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/streamed_response.dart';

import 'utils.dart';

class MockHttp extends BaseMockedHttpClient {
  @override
  get extraUserMetadata => {"onboardingDone": true};

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return Future(() {
      if (request.url.toString().startsWith(
          "${BaseMockedHttpClient.baseUrl}/rest/v1/news?select=%2A")) {
        return response([
          {
            "id": 162,
            "user": BaseMockedHttpClient.uuid,
            "title": "Hello! This is your daily news",
            "transcript": {
              "totalArticles": 5,
              "totalNewsByLLM": "5",
              "intro": "Hello! This is your daily news",
              "outro": "That's all for today. Have a great day!",
              "fullTranscript": "full-transcript",
              "news": [
                {
                  "transcript":
                      "Amazon Gaming Week sale is live - here's 15 deals I'd buy now for PlayStation, Switch, Xbox and PC. Amazon just launched its Gaming Week 2024 sale and there's unmissable deals across PlayStation, Switch, Xbox and PC.",
                  "title":
                      "Amazon Gaming Week sale is live - here's 15 deals I'd buy now for PlayStation, Switch, Xbox and PC",
                  "description":
                      "Amazon just launched its Gaming Week 2024 sale and there's unmissable deals across PlayStation, Switch, Xbox and PC.",
                  "content":
                      "Amazon's Gaming Week sale has arrived, and this annual collection of deals across PlayStation, Nintendo Switch, Xbox and PC is offering some of the best savings of the year so far on everything from must-play video games to essential accessories.\nSom... [6479 chars]",
                  "url":
                      "https://www.tomsguide.com/gaming/amazon-gaming-week-sale-is-live-heres-15-deals-id-buy-now-for-playstation-switch-xbox-and-pc",
                  "image":
                      "https://cdn.mos.cms.futurecdn.net/EDwkuYJU5ntp5CTYLku2cE-1200-80.jpg",
                  "publishedAt": DateTime.now().toIso8601String(),
                  "source": {
                    "name": "Tom's Guide",
                    "url": "https://www.tomsguide.com"
                  }
                },
                {
                  "transcript":
                      "The best new gadgets right now. April was teeming with new TVs, gaming rigs, and peripherals.",
                  "title": "The best new gadgets right now",
                  "description":
                      "April was teeming with new TVs, gaming rigs, and peripherals",
                  "content":
                      "We hope you like TVs because that's what April had to deliver in 2024. Samsung showed off its latest Neo QLED 4K TV, while Sony refreshed its entire QLED-based Bravia lineup.\nAdvertisement\nGamers also had their appetites whetted big time. The Alienwa... [440 chars]",
                  "url":
                      "https://qz.com/best-new-gadgets-april-2024-1851445638",
                  "image":
                      "https://i.kinja-img.com/image/upload/c_fill,h_675,pg_1,q_80,w_1200/ed654e1eaea2c226db0b1d3e770320c4.png",
                  "publishedAt": "2024-04-30T14:35:10.000Z",
                  "source": {"name": "Quartz India", "url": "https://qz.com"}
                },
                {
                  "transcript":
                      "SteelSeries unveils a new white aesthetic for its Arctis Nova Pro line - and it's about as beautiful as gaming headsets can get. SteelSeries has revealed a new white variant of its premium gaming headset, the Arctis Nova Pro Wireless.",
                  "title":
                      "SteelSeries unveils a new white aesthetic for its Arctis Nova Pro line - and it's about as beautiful as gaming headsets can get",
                  "description":
                      "SteelSeries has revealed a new white variant of its premium gaming headset, the Arctis Nova Pro Wireless.",
                  "content":
                      "SteelSeries has just announced an all-new white version of its supreme Arctis Nova Pro line of wireless gaming headsets - and it's slick as heck.\nWe received a white SteelSeries Arctis Nova Pro Wireless gaming headset recently, and have found it to b... [2662 chars]",
                  "url":
                      "https://www.techradar.com/gaming/steelseries-unveils-new-white-arctis-nova-pro-headset-line",
                  "image":
                      "https://cdn.mos.cms.futurecdn.net/5LmUaqfi66CiLWWAVsehAY-1200-80.jpg",
                  "publishedAt": "2024-04-30T14:00:00.000Z",
                  "source": {
                    "name": "TechRadar",
                    "url": "https://www.techradar.com"
                  }
                },
                {
                  "transcript":
                      "The Best New Gadgets of April 2024. April was teeming with new TVs, gaming rigs, and peripherals.",
                  "title": "The Best New Gadgets of April 2024",
                  "description":
                      "April was teeming with new TVs, gaming rigs, and peripherals.",
                  "content":
                      "We hope you like TVs because that's what April had to deliver in 2024. Samsung showed off its latest Neo QLED 4K TV, while Sony refreshed its entire QLED-based Bravia lineup.\nAdvertisement\nGamers also had their appetites whetted big time. The Alienwa... [440 chars]",
                  "url":
                      "https://gizmodo.com/the-best-new-gadgets-of-april-2024-1851444390",
                  "image":
                      "https://i.kinja-img.com/image/upload/c_fill,h_675,pg_1,q_80,w_1200/ed654e1eaea2c226db0b1d3e770320c4.png",
                  "publishedAt": "2024-04-30T13:35:00.000Z",
                  "source": {"name": "Gizmodo", "url": "https://gizmodo.com"}
                },
                {
                  "transcript":
                      "Sony's Inzone gaming monitors are heavily discounted right now - including a ridiculous UK price on the M3. Sony's perfect-for-PS5 Inzone gaming monitors are heavily discounted right now on both sides of the Atlantic.",
                  "title":
                      "Sony's Inzone gaming monitors are heavily discounted right now - including a ridiculous UK price on the M3",
                  "description":
                      "Sony's perfect-for-PS5 Inzone gaming monitors are heavily discounted right now on both sides of the Atlantic.",
                  "content":
                      "Sony's official Inzone gaming monitor line has got some incredible record-low discounts on both sides of the Atlantic right now.\nIn the US, the official Sony inzone M9 monitor has returned to its lowest ever price of just \$698 at Amazon (was \$899.99)... [2465 chars]",
                  "url":
                      "https://www.techradar.com/gaming/sonys-inzone-gaming-monitors-are-heavily-discounted-right-now-including-a-ridiculous-uk-price-on-the-m3",
                  "image":
                      "https://cdn.mos.cms.futurecdn.net/racieFQX74MnCU8gGs8ipS-1200-80.jpg",
                  "publishedAt": "2024-04-30T13:29:32.000Z",
                  "source": {
                    "name": "TechRadar",
                    "url": "https://www.techradar.com"
                  }
                },
                {
                  "transcript":
                      "Microsoft fuels portable Xbox rumors by asking if you plan on buying a gaming handheld. Is a new console on the horizon?",
                  "title":
                      "Microsoft fuels portable Xbox rumors by asking if you plan on buying a gaming handheld",
                  "description": "Is a new console on the horizon?",
                  "content":
                      "Key Takeaways Microsoft is sending out surveys about gaming handhelds, hinting at a possible entry into the market in the near future.\nRumors suggest Microsoft is prototyping a handheld, but it's not a guarantee that a model will actually be released... [2040 chars]",
                  "url":
                      "https://www.xda-developers.com/microsoft-portable-xbox-rumors-survey/",
                  "image":
                      "https://static1.xdaimages.com/wordpress/wp-content/uploads/2023/05/asus-rog-ally-dock.png",
                  "publishedAt": "2024-04-30T13:01:13.000Z",
                  "source": {
                    "name": "XDA Developers",
                    "url": "https://www.xda-developers.com"
                  }
                },
                {
                  "transcript":
                      "Melco Resorts gains after showing strong Q1 results, slight reduction in debt. Melco Resorts & Entertainment (MLCO) reports strong Q1 results, with operating revenue up 55% YoY, driven by gaming and non-gaming operations.",
                  "title":
                      "Melco Resorts gains after showing strong Q1 results, slight reduction in debt",
                  "description":
                      "Melco Resorts & Entertainment (MLCO) reports strong Q1 results, with operating revenue up 55% YoY, driven by gaming and non-gaming operations.",
                  "content":
                      "Melco Resorts & Entertainment Limited (NASDAQ:MLCO) pushed higher in early trading on Tuesday after reporting solid results for a quarter that could be the last to include year-ago comparisons to a period with COVID restrictions.\nOperating revenue fo... [1625 chars]",
                  "url":
                      "https://seekingalpha.com/news/4096207-melco-resorts-gains-after-showing-strong-q1-results-slight-reduction-in-debt",
                  "image":
                      "https://static.seekingalpha.com/cdn/s3/uploads/getty_images/832165940/image_832165940.jpg?io=getty-c-w750",
                  "publishedAt": "2024-04-30T12:46:07.000Z",
                  "source": {
                    "name": "Seeking Alpha",
                    "url": "https://seekingalpha.com"
                  }
                },
                {
                  "transcript":
                      "It's time to stop settling for a noisy gaming PC. It's easy to settle for a loud gaming PC after getting everything set up, but with a little tweaking, you can make your rig run cooler and quieter.",
                  "title": "It's time to stop settling for a noisy gaming PC",
                  "description":
                      "It's easy to settle for a loud gaming PC after getting everything set up, but with a little tweaking, you can make your rig run cooler and quieter.",
                  "content":
                      "I wouldn't blame you if you've learned to live with your loud gaming PC. I certainly have in the past. You spend all the time picking out your parts, putting everything together, and setting up all of your software. Once you're done, it's easy enough... [14913 chars]",
                  "url":
                      "https://www.digitaltrends.com/computing/stop-settling-loud-gaming-pc/",
                  "image":
                      "https://www.digitaltrends.com/wp-content/uploads/2023/02/hyte-y40-case-review-01.jpg?resize=1200%2C630&p=1",
                  "publishedAt": "2024-04-30T12:45:16.000Z",
                  "source": {
                    "name": "Digital Trends",
                    "url": "https://www.digitaltrends.com"
                  }
                },
                {
                  "transcript":
                      "Game on! The Provenance PlayStation emulator is closer to the App Store than ever as beta testing begins. Provenance is an upcoming gaming emulator for iPhone and it's now entered beta testing ahead of a final release to the public. Fallout season two update as show becomes second most-watched ever on Amazon Prime Video. Fallout is based on the hit gaming series of the same name.",
                  "title":
                      "Game on! The Provenance PlayStation emulator is closer to the App Store than ever as beta testing begins",
                  "description":
                      "Provenance is an upcoming gaming emulator for iPhone and it's now entered beta testing ahead of a final release to the public.",
                  "content":
                      "The world of emulated gaming on the iPhone and iPad is changing quickly now that the apps are allowed into the App Store. The Delta game emulator is already available, and more are on the way. And one of them is now closer than ever.\nThat emulator is... [1217 chars]",
                  "url":
                      "https://www.imore.com/gaming/game-on-the-provenance-playstation-emulator-is-closer-to-the-app-store-than-ever-as-beta-testing-begins",
                  "image":
                      "https://cdn.mos.cms.futurecdn.net/gdKTgjKG2sEnMwGag8YLzZ-1200-80.jpg",
                  "publishedAt": "2024-04-30T12:33:10.000Z",
                  "source": {"name": "iMore", "url": "https://www.imore.com"}
                },
              ]
            },
            "date": DateTime.now().toIso8601String(),
            "audio": null
          }
        ], 200, request);
      }

      switch (request.url.toString()) {
        case "${BaseMockedHttpClient.baseUrl}/rest/v1/news_settings?select=%2A&created_by=eq.${BaseMockedHttpClient.uuid}":
          return response([
            {
              "id": 345,
              "created_at": "2024-04-30T14:39:28.189469+00:00",
              "created_by": "0448dda0-d373-4b73-8a04-7507af0b2d6c",
              "interests": "[\"Gaming\"]",
              "wants_interests": true,
              "countries": "[\"Albania\"]",
              "wants_countries": true,
              "cities": "[\"Lausanne\"]",
              "wants_cities": true,
              "user_prompt": null,
              "providers_id": null,
              "voice_wanted": null
            }
          ], 200, request);
        case "${BaseMockedHttpClient.baseUrl}/functions/v1/generate-transcript":
        case "${BaseMockedHttpClient.baseUrl}/functions/v1/generate-audio":
        case "${BaseMockedHttpClient.baseUrl}/storage/v1/object/audios/%22%22":
          return response("", 200, request);
      }

      return super.send(request);
    });
  }
}

void main() {
  testWidgets('User can consult source articles by tapping on them',
      (tester) async {
    await tester.pumpWidget(AppWrapper(httpClient: MockHttp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("signin-guest")));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining("Amazon Gaming Week sale is live"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Tom's Guide"), findsWidgets);
    expect(find.textContaining("must-play video games"), findsWidgets);

    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();

    expect(
        find.textContaining("The best new gadgets right now."), findsWidgets);
  });
}
