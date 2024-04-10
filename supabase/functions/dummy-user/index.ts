import { createClient } from "https://esm.sh/@supabase/supabase-js@2.40.0";

Deno.serve(async (req) => {
  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) {
    return new Response("Unauthorized", { status: 401 });
  }

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    auth.substring(7),
  );

  const users = await supabaseClient.auth.admin.listUsers();
  if (users.error !== null) {
    return new Response("Forbidden", { status: 403 });
  }
  const alreadyExists = users.data.users.find((u) =>
    u.email === "actualia@example.com"
  ) !== undefined;

  if (!alreadyExists) {
    await supabaseClient.auth.admin.createUser({
      email: "actualia@example.com",
      password: "1234",
      email_confirm: true,
    });
  }

  const session = await supabaseClient.auth.signInWithPassword({
    email: "actualia@example.com",
    password: "1234",
  });

  if (!alreadyExists) {
    const dummyClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: {
            "Authorization": `Bearer ${session.data.session?.access_token}`,
          },
        },
      },
    );

    await dummyClient.from("profiles").insert({
      id: session.data.user?.id,
      username: "ActualIA",
    });
    await dummyClient.from("news_settings").insert({
      created_by: session.data.user?.id,
      interests: ["chocolate", "tea"],
      wants_interests: true,
    });
  }

  return new Response(
    JSON.stringify(session),
    { headers: { "Content-Type": "application/json" } },
  );
});
