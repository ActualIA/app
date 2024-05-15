import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { fetchNews } from "../providers.ts";
import { News } from "../model.ts";
import SupabaseClient from "https://esm.sh/v135/@supabase/supabase-js@2.40.0/dist/module/SupabaseClient.js";
import { NewsSettings } from "../model.ts";

interface Result {
  transcript: string;
}

interface NewsJsonLLM {
  totalNewsByLLM: string;
  intro: string;
  outro: string;
  news: Result[];
}

interface Transcript {
  totalNews: number;
  totalNewsByLLM: string;
  intro: string;
  outro: string;
  fullTranscript: string;
  news: (News & Result)[];
}

export async function generateTranscript(
  userId: string,
  supabaseClient: SupabaseClient,
) {
  console.log("We start the process for the user with ID:", userId);

  // Get the user's interests.
  console.log("Fetching user settings");
  const interestsDB = await supabaseClient.from("news_settings").select(
    "*",
  )
    .filter("created_by", "eq", userId)
    .filter("wants_interests", "eq", true);

  if (interestsDB.error) {
    console.error("We can't get the user's interests");
    console.error(interestsDB.error);
    return new Response("Internal Server Error", { status: 500 });
  }
  const interests: NewsSettings = interestsDB.data[0];

  // Get the news.
  console.log(`Fetching news from ${interests.providers.length} providers`);
  const news = await fetchNews(interests.providers || [], interests);

  // Generate a transcript from the news.
  console.log("Generating transcript from news");
  const transcript = news.length > 0 ? await createTranscript(news) : {
    totalNews: 0,
    totalNewsByLLM: 0,
    news: [],
  };

  // Insert the transcript into the database.
  console.log(
    "Inserting transcript in the database: ",
    JSON.stringify(transcript),
  );
  const { data: transcriptRow, error } = await supabaseClient.from("news")
    .insert({
      user: userId,
      title: "Hello! This is your daily news",
      transcript: transcript,
    }).select().single();
  if (error) {
    console.error(error);
  }

  // return transcript
  return new Response(JSON.stringify(transcriptRow), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
    status: 200,
  });
}

// Call OpenAI API for json generation
async function createTranscript(news: News[]): Promise<Transcript> {
  const newsToGenerate = news.reduce(
    (s, n) => `${s}${n.title}\n${n.description}\n\n`,
    "",
  );

  const openai = new OpenAI();
  const completion1 = await openai.chat.completions.create({
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content":
          "You're a radio journalist writing a script to announce the day's news. The user gives you the news to announce. Your radio broadcast should only last 2-3 minutes, so try to find interesting transitions between the news items. Write the script.",
      },
      {
        "role": "user",
        "content": newsToGenerate,
      },
    ],
  });
  const fullTranscript = completion1.choices[0].message.content;

  const completion2 = await openai.chat.completions.create({
    "model": "gpt-3.5-turbo",
    "response_format": {
      "type": "json_object",
    },
    "messages": [
      {
        "role": "system",
        "content":
          'You\'re an assistant trained to create JSON. You\'re given a text which is a radio chronicle about the news of the day. You\'re asked to recognize each news item and classify it in the JSON below. You should also be able to recognize the intro and conclusion. Don\'t leave out any words from the text. {"totalNewsByLLM":"Number of news you have recognized ","intro":"intro you have recognized","outro":"outro you have recognized","news":[{"transcript":"Content of the first news"},{"transcript":"Content of the second news"},{"transcript":"etc."}]}',
      },
      {
        "role": "user",
        "content": fullTranscript || "",
      },
    ],
  });

  const transcriptJSON: NewsJsonLLM = JSON.parse(
    completion2.choices[0].message.content || "",
  );

  console.log("Transcript JSON: ", transcriptJSON);

  return {
    totalNews: news.length,
    totalNewsByLLM: transcriptJSON.totalNewsByLLM,
    intro: transcriptJSON.intro,
    outro: transcriptJSON.outro,
    fullTranscript: fullTranscript || "",
    news: news.map((n, i) => ({
      ...transcriptJSON.news[i],
      ...n,
    })),
  };
}
