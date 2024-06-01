// index.ts
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";
import { SupabaseClient } from "https://esm.sh/v135/@supabase/supabase-js@2.42.4/dist/module/index.js";

/**
 * Generates the audio for a transcript and uploads it to the database. If the audio already exists, does nothing.
 *
 * @param transcriptId id of the transcript to convert to an audio
 * @param voiceWanted name of the voice model to use for generation
 * @param supabaseClient Supabase client where the transcript will be fetched and audio uploaded
 * @returns HTTP Response describing the outcome of the function
 */
export async function generateAudio(
  transcriptId: number,
  voiceWanted: string,
  supabaseClient: SupabaseClient,
) {
  console.log(
    "Generating audio for transcriptId:",
    transcriptId,
  );

  // We get the transcript from the database
  const { data, error } = await supabaseClient
    .from("news")
    .select()
    .eq("id", transcriptId);

  if (error) {
    console.error("Error getting transcript:", error);
    return new Response("Error getting transcript", { status: 500 });
  }
  if (!data || data.length === 0) {
    console.error("Transcript not found");
    return new Response("Transcript not found", { status: 404 });
  }

  // Verify that the file is not already existing in the db before generating it (audio column is empty)
  if (data[0].audio) {
    console.log("Audio already generated:", data[0].audio);
    return new Response(data[0].audio, { status: 200 });
  }

  const user = data[0].user;
  const full_transcript = data[0].transcript.fullTranscript;
  const path = `${user}/${transcriptId}.mp3`;

  const openai = new OpenAI();
  try {
    const audio = await openai.audio.speech.create({
      model: "tts-1",
      voice: voiceWanted as
        | "alloy"
        | "echo"
        | "fable"
        | "onyx"
        | "nova"
        | "shimmer",
      input: full_transcript,
    });

    const file = await audio.blob(); // Get the audio as a Blob

    const { data, error } = await supabaseClient.storage.from("audios").upload(
      path,
      file,
    );
    if (error) {
      console.error("Error uploading audio:", error);
      return new Response("Error uploading audio", { status: 500 });
    }

    console.log("Audio generated and uploaded:", data.path);

    // We update the transcript with the audio URL
    const { error: updateError } = await supabaseClient
      .from("news")
      .update({ audio: path })
      .eq("id", transcriptId);
    if (updateError) {
      console.error("Error updating transcript:", updateError);
      return new Response("Error updating transcript", { status: 500 });
    }

    return new Response(data.path, { status: 200 });
  } catch (error) {
    console.error("Error generating audio:", error);
    return new Response("Error generating audio", { status: 500 });
  }
}
