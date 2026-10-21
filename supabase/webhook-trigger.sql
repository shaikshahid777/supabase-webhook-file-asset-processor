-- supabase/webhook-trigger.sql
-- Replacement for the removed "Database Webhooks" dashboard screen.
-- Uses the pg_net extension to POST a JSON payload to the n8n production webhook.
--
-- BEFORE RUNNING: replace the placeholder URL below with YOUR n8n Cloud
-- PRODUCTION webhook URL (the one that contains /webhook/, not /webhook-test/).
-- The n8n workflow must be published/active, otherwise n8n will not accept the call.
--
-- STATUS: The same function/trigger structure was run successfully in the author's
-- project ("Success. No rows returned"). The URL there is the author's own n8n host.

create extension if not exists pg_net with schema extensions;

create or replace function public.notify_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  perform net.http_post(
    url     := 'https://<YOUR-N8N-CLOUD-HOST>/webhook/new-user',  -- PLACEHOLDER
    headers := '{"Content-Type":"application/json"}'::jsonb,
    body    := jsonb_build_object(
                 'type',       'INSERT',
                 'table',      'users',
                 'schema',     'public',
                 'record',     to_jsonb(NEW),
                 'old_record', null
               )
  );
  return NEW;
end
$$;

drop trigger if exists on_user_insert on public.users;

create trigger on_user_insert
after insert on public.users
for each row execute function public.notify_new_user();
