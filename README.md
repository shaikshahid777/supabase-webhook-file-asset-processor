# Database Webhook-Driven File Asset Processor

## Tayana Academy — Lesson 5: Supabase Integration

This project demonstrates an event-driven workflow that connects Supabase PostgreSQL, n8n Cloud, and Supabase Storage to create a personalized onboarding text file when a new user record is inserted.

## Demo Video

[Loom demonstration](https://www.loom.com/share/249aa23c99e342879157a28312eec379)

> Note: The Loom recording presents the previously configured workflow. A new live test was not performed during that recording.

## Project Components

- **Supabase Database:** `public.users` stores user ID, name, email, role, and creation timestamp.
- **Row-Level Security (RLS):** SELECT and INSERT access are controlled by table policies. Anonymous inserts are intended to be blocked by the authenticated-only INSERT policy.
- **PostgreSQL Trigger:** `on_user_insert` runs after a row is inserted and calls `public.notify_new_user()`.
- **pg_net:** The trigger function sends an HTTP POST event to the n8n Cloud production webhook.
- **n8n Cloud:** The `User Onboarding Processor` workflow receives the event, verifies the user through the Supabase REST API, builds onboarding text, uploads the file, and returns a response.
- **Supabase Storage:** The generated file is stored in the public `assets` bucket.

## Workflow Overview

1. **Webhook:** Receives a POST event for a new user.
2. **Verify User:** Queries the Supabase REST API to confirm the inserted record.
3. **Code:** Builds a personalized onboarding text file with the user details.
4. **Upload File:** Uploads the generated `.txt` file into the `assets` bucket.
5. **Respond to Webhook:** Returns a success status and the generated filename.

## Database Schema

The `public.users` table contains:

| Column | Purpose |
|---|---|
| `id` | Identity primary key |
| `name` | User name |
| `email` | User email address |
| `role` | User role; defaults to `member` |
| `created_at` | Creation timestamp |

## Trigger and Webhook

The PostgreSQL trigger is configured as an `AFTER INSERT` trigger on `public.users`. Its function sends an event payload containing the event type, table, schema, inserted record, and `old_record: null` to the n8n production webhook.

The old Database Webhooks interface was not available in the dashboard used for this project, so the integration uses a PostgreSQL trigger and the `pg_net` extension instead.

## Generated File

The workflow generates a file in the format:

`onboarding_<user-id>.txt`

The file contains the user's name, ID, email, role, and creation timestamp. The public URL follows this pattern:

`https://<supabase-project-ref>.supabase.co/storage/v1/object/public/assets/onboarding_<user-id>.txt`

## Security Notes

- Row-Level Security is enabled on `public.users`.
- The authenticated-only INSERT policy is intended to reject anonymous inserts.
- The workflow uses privileged credentials for server-side verification and storage uploads. **Never commit service-role keys, access tokens, database passwords, or other secrets to this repository.**
- Use environment variables or n8n credentials to store sensitive values.
- The `assets` bucket is public, so do not upload sensitive personal data to it.

## Test Status

The project was previously tested: inserting a user named Asha Rao created `onboarding_1.txt`, and the n8n execution succeeded. The linked Loom recording shows the previously configured workflow; it does not include a new live test performed during that recording. Run a fresh end-to-end test before claiming that a new execution has been verified.

## Technologies

- Supabase PostgreSQL
- Row-Level Security (RLS)
- PostgreSQL triggers
- `pg_net`
- n8n Cloud
- Supabase REST API
- Supabase Storage
- JavaScript

## Project Deliverables

- Loom demo: linked above
- Public GitHub repository: project documentation
- Supabase database and trigger configuration
- n8n workflow for verification, file generation, upload, and webhook response
