-- supabase/rls-policies.sql
-- Row-Level Security for public.users.
--
-- STATUS: Matches the script used during setup. Not re-exported from the live project.
-- Intended access rules (unchanged):
--   * anon + authenticated : SELECT allowed (public read)
--   * authenticated only   : INSERT allowed
--   * anon INSERT          : blocked (no matching policy)
--   * UPDATE / DELETE      : no policy exists, so they are denied for anon and authenticated
--   * service_role key     : bypasses RLS entirely (used only by n8n, server side)

alter table public.users enable row level security;

create policy "Allow public SELECT" on public.users
  for select using (true);

create policy "Allow authenticated INSERT" on public.users
  for insert to authenticated with check (true);
