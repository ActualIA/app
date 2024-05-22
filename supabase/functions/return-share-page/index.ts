import { createClient } from "https://esm.sh/v135/@supabase/supabase-js@2.42.4/dist/module/index.js";

Deno.serve(async (req) => {
  // get the transcriptId from GET params
  const url = new URL(req.url);
  const transcriptId = url.searchParams.get("transcriptId");

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // get the transcript from the database
  const { data: transcript, error } = await supabaseClient
    .from("news")
    .select("*")
    .eq("id", transcriptId)
    .single();

  // Verify that the transcript is public
  if (transcript?.is_public === false) {
    return new Response(returnSharePage("Error", "The transcript is not public"), { status: 200 });
  }

  // return HTML with the transcript
  return new Response(returnSharePage(transcript.title, transcript.transcript.fullTranscript),
    { status: 200 },
  );
});

function returnSharePage(title: string, message: string) {
  return `
  <html>
  <link href="https://cdn.jsdelivr.net/npm/daisyui@4.11.1/dist/full.min.css" rel="stylesheet" type="text/css" />
  <script src="https://cdn.tailwindcss.com"></script>
  <div class="mockup-browser border bg-base-300">
     <div class="mockup-browser-toolbar">
        <div class="input">${title}</div>
     </div>
     <div class="flex justify-center px-4 py-16 bg-base-200">${message}</div>
  </div>
  </html>
  `
}

