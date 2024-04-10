// Import required libraries and modules
import {
  assert,
  assertNotEquals,
} from "https://deno.land/std@0.192.0/testing/asserts.ts";
import {
  createClient,
  SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2.23.0";
import {
  isString,
  required,
  validate,
  validateArray,
  validateObject,
} from "https://deno.land/x/validasaur@v0.15.0/mod.ts";

// Set up the configuration for the Supabase client
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const options = {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
    detectSessionInUrl: false,
  },
};

const testValid = async () => {
  const client: SupabaseClient = createClient(
    supabaseUrl,
    supabaseKey,
    options,
  );

  const session = await client.functions.invoke("dummy-user", {
    headers: {
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
    },
  });

  const res = await client.functions.invoke("get-news", {
    headers: {
      Authorization: `Bearer ${session.data.data.session.access_token}`,
    },
  });

  assertNotEquals(res.data, null);

  const news = res.data;

  const schema = {
    news: validateObject(true, {
      articles: validateArray(
        true,
        validateObject(true, {
          title: [isString, required],
          description: [isString, required],
          content: [isString, required],
          url: [isString, required],
        }),
      ),
    }),
  };

  const [passed, _] = await validate(news, schema);
  assert(passed);
};

// Register and run the tests
Deno.test("get-news with valid parameters", testValid);
