import { News, NewsSettings, Provider } from "../functions/model.ts";
import { parseFeed } from "https://deno.land/x/rss@1.0.2/mod.ts";
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";

/**
 * Fetch and normalize news from a given provider.
 * @param provider One or several providers where to fetch the news.
 * @param newsSettings The settings to filter the fetched news.
 * @returns The news of today from that provider.
 */
export async function fetchNews(
  provider: Provider | Provider[],
  newsSettings: NewsSettings,
): Promise<News[]> {
  async function singleFetch(
    provider: Provider,
    newsSettings: NewsSettings,
  ): Promise<News[]> {
    async function innerFetch(
      provider: Provider,
      topics: string[],
      topic: string | undefined,
    ) {
      let url = provider.replaceAll(":query", topic || "");
      if (url.startsWith("/")) {
        url = Deno.env.get("RSSHUB_BASE_URL") + url;
      }
      console.info("Fetching from ", url);

      // Fetches and parses the rss feed.
      const response = await fetch(url);
      const xml = await response.text();
      const feed = await parseFeed(xml);

      // Normalizes the output and filters out out of date news.
      const news: News[] = feed.entries.map((i) => {
        return {
          title: i.title?.value || "",
          description: i.description?.value || "",
          content: i.description?.value || "",
          publishedAt: i.published || new Date(Date.now()),
          url: i.links[0].href || "",
          source: {
            name: provider,
            url: provider,
          },
        };
      })
        .filter((i: News) => (Date.now() - i.publishedAt.getTime()) < 86400000);

      if (topic) {
        return news;
      }

      // Filter news by AI according to user settings.
      const openai = new OpenAI();
      const completion = await openai.chat.completions.create({
        "model": "gpt-3.5-turbo",
        "response_format": {
          "type": "json_object",
        },
        "messages": [
          {
            "role": "system",
            "content":
              "You are a trained news assistant. You're given a JSON of news, and in this JSON you must select the news that matches the following themes:" +
              topics +
              "You return a JSON in the same form, but without the news that doesn't match the themes.",
          },
          {
            "role": "user",
            "content": JSON.stringify(news),
          },
        ],
      });

      // Verify that the completion is valid.
      let filteredNews = { news: [] as News[] };
      try {
        filteredNews = JSON.parse(
          completion.choices[0].message.content || "",
        );
      } catch (error) {
        console.error("Error parsing filtered news:", error);
      }

      return filteredNews.news;
    }

    let topics: string[] = [];
    if (newsSettings.wants_interests) {
      topics = topics.concat(JSON.parse(newsSettings.interests));
    }
    if (newsSettings.wants_countries) {
      topics = topics.concat(JSON.parse(newsSettings.countries));
    }
    if (newsSettings.wants_cities) {
      topics = topics.concat(JSON.parse(newsSettings.cities));
    }

    if (topics.length === 0) {
      console.log("No topics, setting defaults");
      topics = ["Politics", "Technology"];
    }

    try {
      console.info("Fetching RSS from ", provider);

      if (provider.match(":query")) {
        return (await Promise.all(
          topics.map((t) => innerFetch(provider, topics, t)),
        )).flat();
      } else {
        return await innerFetch(provider, topics, undefined);
      }
    } catch (e) {
      console.error(
        `Error while fetching from ${JSON.stringify(provider)}: ${e}`,
      );
      return [];
    }
  }

  if (Array.isArray(provider)) {
    if (provider.length > 0) {
      return (await Promise.all(
        provider.map((p) => singleFetch(p, newsSettings)),
      )).flat();
    } else {
      return await singleFetch("/google/news/:query", newsSettings);
    }
  } else {
    return await singleFetch(provider, newsSettings);
  }
}
