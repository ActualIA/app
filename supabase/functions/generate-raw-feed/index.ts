import { assertHasEnv } from "../_shared/util.ts";
import { News } from "../_shared/model.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.40.0";
import { getUserRawNews } from "../_shared/get-user-raw-news.ts";

Deno.serve(async (request) => {
  assertHasEnv("RSSHUB_BASE_URL");

  // Create a Supabase client with the user's token.
  const authHeader = request.headers.get("Authorization")!;
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  // Get the user from the token.
  const user = await supabaseClient.auth.getUser();
  if (user.error !== null) {
    console.error(user.error);
    return new Response("Authentication error", { status: 401 });
  }
  const userId = user.data.user.id;
  console.log("We start the process for the user with ID:", userId);

  const news = await getUserRawNews(userId, supabaseClient) as News[];

  return new Response(JSON.stringify(news), { status: 200 });
});
