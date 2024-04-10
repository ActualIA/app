/**
 * Check that Deno has an environment variable set. If not, throw an exception.
 * @param name the environment variable required
 */
export function assertHasEnv(name: string) {
  if (!Deno.env.has(name)) {
    console.error(
      "Missing ${name} environment variable.",
    );
    throw new Error(`Missing ${name} environment variable`);
  }
}
