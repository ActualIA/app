import { fetchNews } from "./providers.ts";
import SupabaseClient from "https://esm.sh/v135/@supabase/supabase-js@2.42.4/dist/module/SupabaseClient.js";
import { NewsSettings } from "./model.ts";

export async function getUserRawNews(
  userId: string,
  supabaseClient: SupabaseClient,
) {
  // Get the user's interests.
  console.log("Fetching user settings");
  const interestsDB = await supabaseClient.from("news_settings").select(
    "*",
  )
    .filter("created_by", "eq", userId)
    .filter("wants_interests", "eq", true);

  if (interestsDB.error) {
    console.error("We can't get the user's interests");
    console.error(interestsDB.error);
    return new Response("Internal Server Error", { status: 500 });
  }
  const interests: NewsSettings = interestsDB.data[0];

  // Get the news.
  console.log(`Fetching news from ${interests.providers.length} providers`);
  const news = await fetchNews(interests.providers || [], interests);

  return news;
}
