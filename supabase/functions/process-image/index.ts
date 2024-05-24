import { assertHasEnv } from "../_shared/util.ts";
import {
  isString,
  validate,
} from "https://deno.land/x/validasaur@v0.15.0/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.4";
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";

const bodySchema = {
  textFromImage: isString,
};

Deno.serve(async (request) => {
  // Check that the required environment variables are available.
  assertHasEnv("OPENAI_API_KEY");

  let textFromImage: string = "";
  try {
    const body = await request.json();
    const [passes, errors] = await validate(body, bodySchema);
    if (!passes) {
      console.log(`Invalid body: ${JSON.stringify(errors)}`);
      return new Response(JSON.stringify({ errors }), { status: 400 });
    }
    textFromImage = body.textFromImage;
  } catch (_) {
    console.trace('Received body is not a valid JSON')
  }

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

  const openai = new OpenAI();
  const completion = await openai.chat.completions.create({
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content":
          "The user provides you an OCR text (not necessarily perfectly formatted) of a photo from a newspaper, or some other news item. The news is not recent, so you should be able to find it. If this doesn't mean anything to you, simply return a message saying you don't know the facts. If you do know the facts, then you give as much context as you can on them, relate the historical facts, the people involved, and so on.",
      },
      {
        "role": "user",
        "content": textFromImage,
      },
    ],
  });
  const fullTranscript = completion.choices[0].message.content;

  return new Response(fullTranscript, { status: 200 });
});
