import { fetchNews } from "../providers.ts";
import SupabaseClient from "https://esm.sh/v135/@supabase/supabase-js@2.40.0/dist/module/SupabaseClient.js";
import { NewsSettings } from "../model.ts";

export async function getUserRawNews(
  user: string | NewsSettings,
  supabaseClient: SupabaseClient,
) {
  if (typeof user === "string") {
    // Get the user's interests.
    console.log("Fetching user settings");
    const interestsDB = await supabaseClient.from("news_settings").select(
      "*",
    )
      .filter("created_by", "eq", user)
      .filter("wants_interests", "eq", true);

    if (interestsDB.error) {
      console.error("We can't get the user's interests");
      console.error(interestsDB.error);
      return new Response("Internal Server Error", { status: 500 });
    }
    user = interestsDB.data[0];
  }
  const u: NewsSettings = user as NewsSettings;

  // Get the news.
  console.log(`Fetching news from ${u.providers.length} providers`);
  const news = await fetchNews(u.providers || [], u);

  return news;
}
