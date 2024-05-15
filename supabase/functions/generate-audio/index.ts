import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.4";
import { assertHasEnv } from "../util.ts";
import {
  isIn,
  isNumber,
  nullable,
  required,
  validate,
} from "https://deno.land/x/validasaur@v0.15.0/mod.ts";

import { generateAudio } from "../_shared/generate-audio.ts";

const bodySchema = {
  transcriptId: [required, isNumber],
  voiceWanted: [
    isIn(["echo", "alloy", "fable", "onyx", "nova", "shimmer"]),
    nullable,
  ],
};

Deno.serve(async (req) => {
  assertHasEnv("OPENAI_API_KEY");

  const body = await req.json();
  const [passes, errors] = await validate(body, bodySchema);
  if (!passes) {
    console.log(`Invalid body: ${JSON.stringify(errors)}`);
    return new Response(JSON.stringify({ errors }), { status: 400 });
  }

  const transcriptId: number = body.transcriptId;
  const voiceWanted: string = body.voiceWanted || "echo";

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  return await generateAudio(transcriptId, voiceWanted, supabaseClient);
});
