import { assertHasEnv } from "../util.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.40.0";

Deno.serve(async (request) => {
  // Check that the required environment variables are available.
  assertHasEnv("GNEWS_API_KEY");

  const authHeader = request.headers.get("Authorization")!;
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const user = await supabaseClient.auth.getUser();
  if (user.error !== null) {
    console.error(user.error);
    return new Response("Authentication error", { status: 401 });
  }

  const interests = await supabaseClient.from("news_settings").select(
    "*",
  )
    .filter("created_by", "eq", user.data.user.id)
    .filter("wants_interests", "eq", true);
  if (interests.data === null) {
    console.error(interests.error);
    return new Response("Internal Server Error", { status: 500 });
  }

  // Computes the GNews query by ORing all the categories.
  // The categories must be "escaped" by putting them in quotes.
  // See https://gnews.io/docs/v4#search-endpoint-query-parameters for more details.
  const query = interests.data.length > 0
    ? (interests.data[0].interests as string[]).map((s) => `"${s}"`).join(
      " OR ",
    )
    : "";

  // Constructs the query URL.
  const url = `https://gnews.io/api/v4/search?q=${
    encodeURIComponent(query)
  }&apikey=${encodeURIComponent(Deno.env.get("GNEWS_API_KEY") || "")}`;

  // Send the query and parse its result.
  const result = await fetch(url);
  const json = await result.json();

  // TODO: more advanced processing
  console.log(json);

  return new Response(JSON.stringify({ news: json }), {
    headers: { "Content-Type": "application/json" },
  });
});
