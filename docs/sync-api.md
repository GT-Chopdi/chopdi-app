# Sync API — integration guide (Flutter)

This is the contract between the app and `apps/api` for syncing
**I Gave** (customers), **I Took** (lenders), books (chopdis), and their
transactions, and for restoring them when a user signs in on a device.

Base URL: `https://chopdi-app.vercel.app/api` (see `ApiConfig.baseUrl`).
Every request below needs the headers the app already sends:

```
Authorization: Bearer <accessToken>
X-Device-Id: <deviceId from sign-in>
```

The user comes from the access token. Never send `userId`: the server rejects
any request that contains it.

---

## 1. What changed on the server

| Local Isar table | Wire `entity` | Neon table |
|---|---|---|
| `customers` (I Gave) | `customer` | `customer` |
| `lenders` (I Took) | `lender` | `lender` (**new**) |
| `chopdis` | `chopdi` | `chopdi` (**new**) |
| `transactions` | `ledger_entry` | `ledger_entry` (now has `lender_id`) |

Before this change the server only accepted `customer` and `ledger_entry`.
Every `lender` operation the app queues today makes `/v1/sync/push` reject the
**whole batch** with a 400, so nothing else in that batch syncs either. Once
this is deployed, those queued lender operations go through with no app
change.

---

## 2. `GET /v1/sync/pull` — restore and catch up (new)

This endpoint returns every change to the signed-in account after `cursor`,
oldest first. Each change carries the **full row** as it is now on the server,
so the app applies a change by replacing its local copy.

- **On sign-in** (or with an empty database), call it with `cursor=0` to get
  everything back.
- **Afterwards**, call it with the saved cursor to pick up changes made on other
  devices.

### Request

```
GET /v1/sync/pull?cursor=0&limit=200
```

| Param | Required | Rules |
|---|---|---|
| `cursor` | no (default `0`) | A decimal string: `0`, or digits without leading zeros, at most 2^63−1. Send `SyncMeta.cursor`. |
| `limit` | no (default `200`) | An integer of 1 or more. The server caps it at `SYNC_MAX_PULL_LIMIT` (500) and returns a smaller page rather than an error. |

Any other query parameter is rejected with a 400.

### Response `200`

```json
{
  "changes": [
    {
      "seq": "41",
      "entity": "lender",
      "entityId": "0199a3c2-…",
      "opType": "create",
      "data": { "id": "0199a3c2-…", "chopdiId": null, "name": "Suresh", "phone": "+919876500002",
                "notes": "", "version": 1, "createdAt": "…", "updatedAt": "…", "deletedAt": null }
    }
  ],
  "nextCursor": "41",
  "hasMore": true,
  "serverCursor": "57"
}
```

- `seq`, `nextCursor` and `serverCursor` are **strings**, because they are 64-bit
  values. Parse them with `int.parse`, which is exact in Dart.
- `opType` is one of `create`, `update` or `void`. On a `void`, `data.deletedAt`
  (for a party or book) or `data.voidedAt` (for an entry) is set.
- If `hasMore` is true, request again straight away with `cursor=nextCursor`.
- **Save `nextCursor` only after the page is applied**, ideally in the same Isar
  write transaction. If you save it first and the app dies mid-page, that page
  is lost for good.
- Changes are in `seq` order and parents always come first (book → customer or
  lender → entry), so applying them in order never meets an entry whose parent
  is missing.
- Your own pushes come back too. If the incoming `data.version` is less than or
  equal to the local row's `version`, skip the change. That is an echo, not a
  conflict.
- Ignore any `entity` value you don't recognise, so that a newer server can't
  break an installed app.

### `data` shape per entity

| entity | fields |
|---|---|
| `chopdi` | `id, name, description, version, createdAt, updatedAt, deletedAt` |
| `customer` / `lender` | `id, chopdiId (uuid or null), name, phone (or null), notes, version, createdAt, updatedAt, deletedAt` |
| `ledger_entry` | `id, customerId, lenderId` (exactly one is set), `amountPaise` (**string**), `direction` (`gave`/`received`), `ledgerSide` (`lent`/`borrowed`), `interestRateBp, interestType` (`none`/`simple`/`compound`), `interestFrequency` (`daily`/`weekly`/`monthly`/`yearly`), `entryDate` (`YYYY-MM-DD`), `description, paymentMode, version, createdAt, updatedAt, voidedAt, voidedReason` |

- Rebuild the local `TransactionType` with
  `SyncPayload.toType(direction, ledgerSide)`.
- A `customer` becomes a `Customer` row with `loanType = 'gave'`. A `lender`
  becomes a `Lender` row with `loanType = 'took'`.
- `chopdiId` is null for rows synced before books were synced. Put those in
  the active book.

### Errors

| Status | `error.code` | Meaning / what to do |
|---|---|---|
| 400 | `VALIDATION_FAILED` | Bad `cursor` or `limit`, or an unknown parameter. This is an app bug. |
| 401 | `UNAUTHENTICATED` / `DEVICE_REVOKED` … | Same handling as every other endpoint. |
| 409 | `CURSOR_AHEAD` (permanent) | The saved cursor is beyond anything this account has written, because the local sync state belongs to another account or database. **Reset the cursor to 0 and pull again.** |

`CURSOR_AHEAD` is a new error code. Add it to
`lib/data/remote/error_code.dart` (both the constant and the `known` set), or
`test/error_code_contract_test.dart` will fail.

The response has `Cache-Control: no-store`.

---

## 3. `POST /v1/sync/push` — what the app sends (changed)

The envelope is unchanged: `{ operations: [{ opId, entity, entityId, opType, expectedVersion?, payload }], syncSessionId? }`,
with at most 200 operations per request and one result per operation.
`entity` can now be `chopdi`, `customer`, `lender` or `ledger_entry`.

### Payloads

| entity | `create` / `update` payload |
|---|---|
| `customer` | `{ name, phone \| null, notes, chopdiId? }` (unchanged; `chopdiId` optional) |
| `lender` | `{ name, phone \| null, notes, chopdiId? }` (what `LenderRepository` already sends) |
| `chopdi` | `{ name, description? }` |
| `ledger_entry` | Same fields as today, with **exactly one** parent: `customerId` for I Gave, `lenderId` for I Took |

- `void` payloads are `{ reason }` for every entity. `update` and `void` need
  `expectedVersion`, as before.
- `chopdiId` is the book's **uuid**, not the local Isar id. It is optional:
  leave it out and the row still syncs, just without a book.
- If the book in a `chopdiId` hasn't reached the server yet, the operation gets
  `PARENT_NOT_FOUND` (`permanent: false`) and is retried. Books are applied
  before parties in the same batch.

### I Took entries: `customerId` still works

The app currently sends I Took entries as `customerId: <lender uuid>`. The
server looks that id up in `lender` when no customer matches, so entries
already frozen in device outboxes sync correctly. New code should send
`lenderId` instead. Sending both fields is rejected as `VALIDATION_FAILED`.

### Converting a legacy "took" customer into a lender

Builds before `7ab7a63` saved lenders as `Customer` rows with
`loanType: "took"`, and those rows were synced as `customer`. To move one:

1. Move it into the local `lenders` table **keeping the same uuid**.
2. Enqueue `lender/create` with that uuid.

The server then converts the row in one transaction. It creates the lender,
moves that customer's entries over to it, and soft-deletes the customer. The
change log records all three steps, so other devices see the move on their
next pull.

---

## 4. App-side work this contract needs

The backend no longer blocks any of this. These are the changes for the
Flutter side:

1. **Pull on sign-in.** After `verifyOtp`, call `pull(cursor: 0)` and page
   until `hasMore` is false before opening `MainScreen`, so the user sees their
   data. After that, pull on the regular sync timer.
2. **Mark lenders synced.** `SyncEngine._markRowSynced` and `_markRowStatus`
   only handle `customer`. Add `lender` (and `chopdi`, if books are synced), or
   lender rows stay pending at version 0 and their next edit conflicts.
3. **Send lender deletes.** `took_loan_customer_details_screen.dart` hard-deletes
   the lender and its transactions without enqueuing anything, so the server
   never hears about it and a restore brings it back. Soft-delete it and enqueue
   `lender/void`, plus `ledger_entry/void` for each of its entries.
4. **Match transactions by uuid, not local id.** Customer ids and lender ids
   are separate autoincrement sequences, so customer #1 and lender #1 both
   exist. After a restore this is certain, not just possible. Screens that
   filter with `customerIdEqualTo(x.id)` then show one party's entries under
   the other: `customer_card`, `customer_details_screen`, `customers_screen`,
   `took_loan_customer_card`, `took_loan_customers_screen`, and
   `CustomerRepository.softDeleteWithEntries`. Use
   `customerUuidEqualTo(x.uuid)` instead.
5. **Books (optional).** To restore books, give `Chopdi` a `uuid`, `version`
   and `syncStatus`, enqueue `chopdi` operations, and send `chopdiId` (the uuid)
   on customers and lenders.
6. **Add `CURSOR_AHEAD`** to `error_code.dart` (see section 2).

---

## 5. Deploying

1. Apply the migrations to Neon:
   `20260930120000_add_chopdi_and_lender` and
   `20260930120100_chopdi_lender_checks` (`npm run prisma:deploy`). Both only
   add to the schema: existing rows and the columns old clients use are
   unchanged.
2. Deploy the API.
3. Only then ship an app build that relies on the pull endpoint or sends
   `lenderId` or `chopdi`.

Verification against a running server with a scratch database:
`API_BASE=… DEV_KEY=… node test/verify-pull.mjs` (52 checks) and
`test/verify-sync.mjs` (the existing 38 checks, as a regression test).
