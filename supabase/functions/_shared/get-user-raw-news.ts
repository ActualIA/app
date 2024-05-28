import { fetchNews } from "../providers.ts";
import SupabaseClient from "https://esm.sh/v135/@supabase/supabase-js@2.42.4/dist/module/SupabaseClient.js";
import { getUserSettings } from "../database.ts";

export async function getUserRawNews(
  user: string | NewsSettings,
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
