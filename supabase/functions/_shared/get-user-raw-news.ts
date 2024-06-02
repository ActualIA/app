import { fetchNews } from "./providers.ts";
import SupabaseClient from "https://esm.sh/v135/@supabase/supabase-js@2.42.4/dist/module/SupabaseClient.js";
import { getUserSettings } from "./database.ts";

/**
 * Get all the news from the last 24h for a given user.
 *
 * @param userId id of the user whose providers will be used
 * @param supabaseClient client where the `news_settings` will be fetched
 * @returns
 */
export async function getUserRawNews(
  userId: string,
  supabaseClient: SupabaseClient,
) {
  const user = await getUserSettings(userId, supabaseClient);
  if (user == null) {
    return new Response("Internal Server Error", { status: 500 });
  }

  // Get the news.
  console.log(`Fetching news from ${user.providers.length} providers`);
  const news = await fetchNews(user.providers || [], user);

  return news;
}
