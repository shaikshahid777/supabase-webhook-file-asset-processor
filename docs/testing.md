# Testing

> **Important:** No new live end-to-end test was performed during the Loom recording. The recording shows the previously configured project and workflow. Nothing below has been invented; items not verified are marked clearly.

## Verified (earlier test, observed during setup)

| Check | Result observed |
|---|---|
| Insert user `Asha Rao` (`asha@example.com`, role `developer`) in Supabase SQL Editor | SQL Editor reported `Success. No rows returned` |
| n8n workflow `User Onboarding Processor` triggered | Execution **#93** shown as `Succeeded in 3.232s` in the Executions tab |
| Upload File node output | `Key: assets/onboarding_1.txt` |
| Respond to Webhook output | `{"status":"ok","file":"onboarding_1.txt"}` |
| File present in Storage | `onboarding_1.txt`, `text/plain`, 427 bytes, shown in `assets` bucket |
| Public URL | Browser displayed the personalized text beginning `Welcome to the team, Asha Rao!` with user ID, name, email, role, and created-at |
| Header fix | Trailing newline in `apikey` / `Authorization` header values removed in Verify User and Upload File, then the test above succeeded |

## Not verified

| Item | Status |
|---|---|
| Second user insert (e.g. `Ravi Kumar`, `onboarding_2.txt`) | Not confirmed in this repository |
| Anonymous `POST /rest/v1/users` being rejected (RLS) | Intended behaviour; no result recorded here |
| Anonymous `GET /rest/v1/users` returning 200 | Intended behaviour; no result recorded here |
| "User not found" branch of the Code node | Fix applied; never triggered in a live run |
| Webhook endpoint offline while inserting (async resilience) | Not tested |
| Fresh deployment from `docs/setup-guide.md` | Not performed |
| Security audit | Not performed |
| New live test during the Loom recording | **Not performed** |

## Manual test steps (to run yourself)

1. **Happy path**

   ```sql
   insert into public.users (name, email, role)
   values ('Test User', 'test@example.com', 'tester');
   ```

   Expect: succeeded n8n execution, new `onboarding_<id>.txt` in `assets`, readable at the public URL.

2. **RLS check (Postman, anon key only)**
   - `POST https://<project-ref>.supabase.co/rest/v1/users` with headers `apikey` and `Authorization: Bearer` set to the **anon** key, JSON body `{"name":"x","email":"x@example.com"}`. Expect a 401/403 style RLS error.
   - `GET` the same URL with the anon key. Expect HTTP 200 and a JSON array.

3. **Async resilience:** unpublish the n8n workflow, insert a row, and confirm the row still exists in `public.users`.

Record your own results here after running them, with the date.
