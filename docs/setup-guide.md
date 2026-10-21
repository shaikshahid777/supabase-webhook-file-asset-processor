# Setup Guide

> **Status:** These steps describe how the author's project was built. A completely fresh deployment from this guide has **not** been performed, so treat it as a verified-by-construction guide, not as a re-tested one.

## Prerequisites

- A Supabase account and a free project
- An n8n Cloud account (provides a public HTTPS webhook URL, so ngrok is not required)
- A browser; Postman is optional (only for the RLS check)

Never paste real keys into this repository or into chat tools. Use `.env.example` as a checklist for the values you need.

## 1. Supabase project

1. Create a project (for example `TraineeBackend`, Free plan).
2. Open **Project Settings -> API** and note the **Project URL**, **anon key**, and **service_role key** in a private place. The service_role key bypasses RLS and must never be committed.

## 2. Table, RLS, policies

1. Open **SQL Editor -> New query**.
2. Run [`supabase/schema.sql`](../supabase/schema.sql), then [`supabase/rls-policies.sql`](../supabase/rls-policies.sql).
3. Expected output: `Success. No rows returned`. Check **Table Editor** for `users`.

## 3. Storage bucket

1. Open **Storage -> New bucket**.
2. Name it `assets` and turn **Public bucket** on, then create it.

## 4. n8n workflow

Build the five nodes described in [`n8n/README.md`](../n8n/README.md): Webhook, Verify User, Code, Upload File, Respond to Webhook. Replace the project ref and key placeholders with your own values inside n8n only. Then **publish** the workflow.

Your production webhook URL will look like:

`https://<your-instance>.app.n8n.cloud/webhook/new-user`

## 5. Database trigger

1. Open [`supabase/webhook-trigger.sql`](../supabase/webhook-trigger.sql).
2. Replace `https://<YOUR-N8N-CLOUD-HOST>/webhook/new-user` with your production URL.
3. Run it in the SQL Editor. Expected: `Success. No rows returned`.

## 6. Test it

```sql
insert into public.users (name, email, role)
values ('Asha Rao', 'asha@example.com', 'developer');
```

Expected (this is what happened in the author's first test):

- n8n **Executions** shows a new succeeded execution within a few seconds.
- **Storage -> assets** contains `onboarding_<id>.txt`.
- Opening `https://<project-ref>.supabase.co/storage/v1/object/public/assets/onboarding_<id>.txt` shows the personalized text.

## Troubleshooting

See the Troubleshooting section in the main [README](../README.md#troubleshooting).
