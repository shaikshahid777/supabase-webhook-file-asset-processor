# n8n workflow: User Onboarding Processor

Runs in **n8n Cloud** and must be **published** so the production URL `https://<your-instance>.app.n8n.cloud/webhook/new-user` accepts calls.

## The five nodes

| # | Node | Type | Configuration |
|---|---|---|---|
| 1 | Webhook | Webhook | Method `POST`, path `new-user`, Respond = "Using Respond to Webhook node", authentication none |
| 2 | Verify User | HTTP Request | `GET https://<PROJECT_REF>.supabase.co/rest/v1/users?id=eq.{{ $json.body.record.id }}&select=*` with `apikey` and `Authorization` headers. **Always Output Data** is on |
| 3 | Code | Code (JavaScript) | Reads the first user object, throws if not found, builds the onboarding text, returns `filename` and `content` |
| 4 | Upload File | HTTP Request | `POST https://<PROJECT_REF>.supabase.co/storage/v1/object/assets/{{ $json.filename }}`, headers `apikey`, `Authorization`, `Content-Type: text/plain`, `x-upsert: true`, raw `text/plain` body `{{ $json.content }}` |
| 5 | Respond to Webhook | Respond to Webhook | Status 200, body `{"status":"ok","file":"{{ $('Code').item.json.filename }}"}` |

## Header values

Use placeholders in anything you commit:

```json
{
  "apikey": "<SUPABASE_SERVICE_ROLE_KEY>",
  "Authorization": "Bearer <SUPABASE_SERVICE_ROLE_KEY>"
}
```

There must be exactly one space after `Bearer` and **no trailing space or line break** after the key.

## Not-found guard (Code node)

This guard was added at the top of the Code node:

```javascript
const u = $input.all()[0].json;
if (!u || u.id === undefined) {
  throw new Error('User not found in Supabase for id ' + $('Webhook').first().json.body.record.id);
}
```

The rest of the Code node (building `filename` as `onboarding_<id>.txt` and the personalized `content` text) is in the live workflow. It is not reproduced here because the exact deployed code has not been exported into this repository.

The workflow was built with n8n's AI assistant and then reviewed. Two review fixes were applied: removing a trailing newline from the key headers, and adding the not-found handling above.

## Exporting the real workflow (`n8n/workflow.json`) — MISSING, do this manually

No workflow export is included yet, and none was fabricated.

1. In n8n open **User Onboarding Processor**.
2. Click the **...** menu (top right) -> **Download**.
3. Save the file as `n8n/workflow.json`.
4. **Remove secrets before committing.** The service-role key is stored in the HTTP Request node headers, so the export will contain it. Open the file and replace every key with the placeholder `<SUPABASE_SERVICE_ROLE_KEY>` and your project ref with `<PROJECT_REF>`. Then search for leftovers:

   ```bash
   grep -n "eyJ" n8n/workflow.json      # must print nothing
   grep -n "supabase.co" n8n/workflow.json  # check no real project ref remains
   ```

5. Importing a scrubbed export requires you to re-enter the real values in n8n. Do not claim it is import-ready until you have actually imported and run it.

## Safer alternative (recommended)

Create an n8n **Header Auth** credential for Supabase and reference it in the two HTTP Request nodes, so exports never contain the key.
