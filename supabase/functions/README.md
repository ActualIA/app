# Supabase

[Supabase](https://supabase.com/) is an open source alternative to Firebase. This folder (`supabase/`) is dedicated to all the components for the [Supabase project](https://supabase.com/dashboard/project/dpxddbjyjdscvuhwutwu).

## Setup

First of all, install the [Supabase CLI toolchain](https://supabase.com/docs/guides/cli/getting-started), as well as [Deno](https://docs.deno.com/runtime/manual/getting_started/installation). The first one also requires [Docker](https://docs.docker.com/get-docker/). You may also want to install the Deno plugin(s) on your IDE (see this [tutorial](https://docs.deno.com/runtime/manual/getting_started/setup_your_environment#using-an-editoride)).

To run supabase locally, run (from the root of the project or the `supabase/` directory)

```sh
supabase start
```

To stop it:

```sh
supabase stop
```

Then, export the required environment variables with

```sh
supabase status -o env --override-name api.url=SUPABASE_URL --override-name auth.anon_key=SUPABASE_ANON_KEY > supabase/.env
```

The Edge Functions also require some additional environment variables, see the `supabase/functions/.env.example`. Copy this file into `supabase/functions/.env` and provide the following variables:

- `GNEWS_API_KEY`: Key to use the [GNews](https://gnews.io) API, for news fetching.
- `OPENAI_API_KEY`: Key to use the [OpenAI](https://openai.com) API, used to generate transcripts and audios.
- `RSSHUB_BASE_URL`: Url of a [RSSHub](https://rsshub.app) endpoint, queried to get news in RSS format.

## Dev

Each Edge Function is an `index.ts` file stored in a folder with the function's name, in the `functions` directory. Any piece of code that needs to be shared between multiple functions should be placed in `functions/_shared`.

Edge Functions use the [Deno](https://deno.com/) framework, which comes with its own dependency management system ([here](https://deno.land/x)).
