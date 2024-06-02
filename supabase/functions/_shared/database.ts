import * as postgres from "https://deno.land/x/postgres@v0.17.0/mod.ts";
import { NewsSettings } from "./model.ts";
import { SupabaseClient } from "https://esm.sh/v135/@supabase/supabase-js@2.42.4/dist/module/index.js";

// Get the connection string from the environment variable "SUPABASE_DB_URL"
export const databaseUrl = Deno.env.get("SUPABASE_DB_URL")!;

// Create a database pool with three connections that are lazily established
export const pool = new postgres.Pool(databaseUrl, 10, true);

export async function getUserSettings(
    id: string,
    supabaseClient: SupabaseClient,
): Promise<NewsSettings | null> {
  // Get the user's interests.
  console.log("Fetching user settings");
  const interestsDB = await supabaseClient.from("news_settings").select(
    "*",
  )
    .filter("created_by", "eq", id)
    .filter("wants_interests", "eq", true);

  if (interestsDB.error) {
    console.error("We can't get the user's interests");
    console.error(interestsDB.error);
    return null;
  } else {
    return interestsDB.data[0];
  }
}
