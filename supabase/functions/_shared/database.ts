import * as postgres from "https://deno.land/x/postgres@v0.17.0/mod.ts";

// Get the connection string from the environment variable "SUPABASE_DB_URL"
export const databaseUrl = Deno.env.get("SUPABASE_DB_URL")!;

// Create a database pool with three connections that are lazily established
export const pool = new postgres.Pool(databaseUrl, 10, true);
