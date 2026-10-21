# LMS Submission Description — Lesson 5: Supabase Integration

**Project:** Database Webhook-Driven File Asset Processor  
**GitHub Repository:** https://github.com/shaikshahid777/supabase-webhook-file-asset-processor  
**Loom Demo:** https://www.loom.com/share/249aa23c99e342879157a28312eec379

## Description

This project demonstrates an event-driven integration between Supabase and n8n Cloud. When a new record is inserted into the `public.users` table, a PostgreSQL trigger uses the `pg_net` extension to send a JSON POST event to an n8n production webhook. The workflow verifies the inserted user through the Supabase REST API, generates a personalized onboarding text file, uploads that file to the public `assets` Storage bucket, and returns a JSON response containing the status and filename.

The project also demonstrates Row-Level Security (RLS) policies for read and insert access. Public SELECT is allowed by policy, while INSERT is restricted to authenticated users.

## Key Features

- Supabase `public.users` table and schema
- Row-Level Security and table policies
- PostgreSQL `AFTER INSERT` trigger and `pg_net` webhook call
- n8n Cloud workflow with five processing stages
- Supabase REST API record verification
- Personalized onboarding text generation
- Supabase Storage upload and public file URL pattern
- Webhook response with status and generated filename

## Demo and Testing Note

The Loom video demonstrates the previously configured project. A new live test was not performed during this recording. The workflow had been tested previously with the user Asha Rao, which generated `onboarding_1.txt` and a successful n8n execution. Please treat the video as a walkthrough of the configured setup, not as evidence of a new live test.

## Deliverables

- **Loom demo:** https://www.loom.com/share/249aa23c99e342879157a28312eec379
- **Public GitHub repository:** https://github.com/shaikshahid777/supabase-webhook-file-asset-processor
- **Documentation:** README.md and this LMS description
