# Security and RLS

> No formal security audit was performed. This page documents the intended design and the known weaknesses.

## Keys

| Key | Use | Handling |
|---|---|---|
| anon key | Client-side requests; subject to RLS | Public by design, but still do not paste it carelessly |
| service_role key | Used by n8n for Verify User and Upload File | Bypasses **all** RLS. Never commit it, never show it in videos or screenshots, never use it in front-end code |
| Database password | Direct Postgres connection | Not used by this project's workflow. Never commit |

Use `.env.example` (placeholders only). The repository `.gitignore` excludes `.env` files.

## RLS policies on `public.users`

Defined in [`supabase/rls-policies.sql`](../supabase/rls-policies.sql):

| Operation | anon | authenticated | service_role |
|---|---|---|---|
| SELECT | allowed (`using (true)`) | allowed | bypasses RLS |
| INSERT | blocked (no policy) | allowed (`with check (true)`) | bypasses RLS |
| UPDATE / DELETE | denied (no policy) | denied (no policy) | bypasses RLS |

Because the row is inserted by a trusted SQL session (the SQL Editor runs with elevated database privileges) the trigger fires there; REST inserts with the anon key are expected to be rejected.

> The anon-insert-blocked behaviour is the **intended** result of the policies. It is not recorded as a verified test in this repository (see `docs/testing.md`).

## Trigger function

`public.notify_new_user()` is declared `security definer` so it can call `net.http_post` regardless of who inserted the row.

## Known limitations

1. **Unauthenticated webhook.** The n8n Webhook node uses no authentication. Anyone who learns the URL can post to it. The workflow re-queries Supabase by `id`, which limits fake payloads, but a shared-secret header check is recommended.
2. **Service-role key in node parameters.** In the author's workflow the key is stored in the HTTP Request nodes' headers. Anyone who can view or export the workflow can read it. Prefer an n8n Header Auth credential.
3. **Public bucket, guessable names.** `onboarding_<id>.txt` files contain names and emails and are readable by anyone with the URL; ids are sequential.
4. **Broad SELECT policy.** `using (true)` exposes every user row to the anon key.
5. **Broad INSERT policy.** `with check (true)` lets any authenticated user insert any row.
6. **No retries.** Failed webhook deliveries are not retried by this project.

## Before using this pattern outside a classroom

- Use a private bucket and signed URLs for personal data.
- Scope RLS policies to `auth.uid()`.
- Store secrets in n8n credentials and rotate any key that was ever exposed.
- Add webhook authentication and error handling (an error branch that returns a clean response).
