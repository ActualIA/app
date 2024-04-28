import { assertHasEnv } from "../util.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.40.0";
import OpenAI from "https://deno.land/x/openai@v4.33.0/mod.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { fetchNews } from "../providers.ts";
import { News } from "../model.ts";

interface Result {
  transcript: string;
}

interface NewsJsonLLM {
  totalNewsByLLM: string;
  news: Result[];
}

interface Transcript {
  totalArticles: number;
  totalNewsByLLM: string;
  articles: (News & Result)[];
}

Deno.serve(async (request) => {
  // Check that the required environment variables are available.
  assertHasEnv("GNEWS_API_KEY");
  assertHasEnv("OPENAI_API_KEY");

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

  // Get the user's interests.
  console.log("Fetching user settings");
  const interestsDB = await supabaseClient.from("news_settings").select(
    "*",
  )
    .filter("created_by", "eq", userId)
    .filter("wants_interests", "eq", true);

  let interests = null;
  if (interestsDB.error) {
    console.error("We can't get the user's interests");
    console.error(interestsDB.error);
    return new Response("Internal Server Error", { status: 500 });
  } else {
    interests = interestsDB.data[0];
  }

  console.log("Fetching provider from the database");
  const providersDB = await supabaseClient.from("news_providers").select("*")
    .in(
      "id",
      interests["providers_id"] || [],
    );
  let providers = null;
  if (providersDB.error) {
    console.error("We can't get the user's providers");
    console.error(providersDB.error);
    return new Response("Internal Server Error", { status: 500 });
  } else {
    providers = providersDB.data.map((p) => p.type);
  }

  // Get the news.
  console.log(`Fetching news from ${providers.length} providers`);
  const news = await fetchNews(providers || [], interests);

  // Generate a transcript from the news.
  console.log("Generating transcript from news");
  const transcript = news.length > 0 ? await generateTranscript(news) : {
    totalArticles: 0,
    totalNewsByLLM: 0,
    articles: [],
  };

  // Insert the transcript into the database.
  console.log(
    "Inserting transcript in the database: ",
    JSON.stringify(transcript),
  );
  const { error } = await supabaseClient.from("news").insert({
    user: userId,
    title: "Hello! This is your daily news",
    transcript: transcript,
  });
  if (error) {
    console.error(error);
  }

  // return transcript
  return new Response(JSON.stringify(transcript), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
    status: 200,
  });
});

// Call OpenAI API for json generation
async function generateTranscript(news: News[]): Promise<Transcript> {
  const openai = new OpenAI();
  const completion = await openai.chat.completions.create({
    "model": "gpt-3.5-turbo",
    "response_format": {
      "type": "json_object",
    },
    "messages": [
      {
        "role": "system",
        "content":
          'You are a journalist who provide a transcript from a selection of article headlines that we give you. It\'s up \
          to you to compose your own text according to these, and to make interesting transitions between transcript items \
          (IMPORTANT). For example, you can use Also, On the other hand, etc. to do the transition between news. Create a \
          valid JSON array from this news-cut transcript, as in the example here {"totalNewsByLLM":"The number of news you \
          proceed (ex. 3 here)","news":[{"transcript":"The summary of the news 1"},{"transcript":"The summary of the news 2"},{"transcript":"etc."}]}',
      },
      {
        "role": "user",
        "content": news.reduce(
          (s, n) => `${s}${n.title}\n${n.description}\n\n`,
          "",
        ),
      },
    ],
  });

  const transcriptJSON: NewsJsonLLM = JSON.parse(
    completion.choices[0].message.content || "",
  );

  return {
    totalArticles: news.length,
    totalNewsByLLM: transcriptJSON.totalNewsByLLM,
    articles: news.map((n, i) => ({
      ...transcriptJSON.news[i],
      ...n,
    })),
  };
}
