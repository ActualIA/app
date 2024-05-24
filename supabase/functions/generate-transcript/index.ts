import { assertHasEnv } from "../_shared/util.ts";
import { generateTranscript } from "../_shared/generate-transcript.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.40.0";
import {
  isString,
  match,
  validate,
} from "https://deno.land/x/validasaur@v0.15.0/mod.ts";

const bodySchema = {
  userId: [
    isString,
    match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/),
  ],
};

Deno.serve(async (request) => {
  // Check that the required environment variables are available.
  assertHasEnv("GNEWS_API_KEY");
  assertHasEnv("OPENAI_API_KEY");
  assertHasEnv("RSSHUB_BASE_URL");

  let userId: string = "";
  try {
    const body = await request.json();
    const [passes, errors] = await validate(body, bodySchema);
    if (!passes) {
      console.log(`Invalid body: ${JSON.stringify(errors)}`);
      return new Response(JSON.stringify({ errors }), { status: 400 });
    }

    userId = body.userId;
  } catch (_) {
    return new Response("Body must be a valid JSON", { status: 400 });
  }

  let supabaseClient;

  if (userId !== "" && typeof userId === "string") {
    supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
  } else {
    // Create a Supabase client with the user's token.
    const authHeader = request.headers.get("Authorization")!;
    supabaseClient = createClient(
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
    userId = user.data.user.id;
  }

  return await generateTranscript(userId, supabaseClient);
});
