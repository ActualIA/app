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
- `GNEWS_API_KEY`: Get yours [here](https://gnews.io/). It grants you 100 requests per day.

## Tests

Each Edge function should have its dedicated test file in `supabase/functions/tests`. To run the tests, use:
```sh
deno test --allow-all supabase/functions/tests/*.ts --env .env
```
