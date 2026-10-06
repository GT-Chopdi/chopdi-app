/**
 * The keys two copies of the same person are matched on.
 *
 * Mirrors the app's own duplicate check (add_new_customer_screen.dart): same
 * name and same phone is the same person, same name and both phones empty is
 * the same person, anything else is not. The server needs it because the app
 * can only check its own device — two phones offline at once each see no
 * "Ravi" and each create one.
 *
 * Must stay identical to the backfill SQL in the party_merge migration and in
 * scripts/merge-duplicate-parties.mjs: rows written by any of them are
 * compared with each other, and by the unique index.
 */
export interface PartyKeys {
  nameKey: string;
  phoneKey: string;
}

export function partyKeys(name: string, phone: string | null): PartyKeys {
  return {
    nameKey: name.trim().replace(/\s+/g, ' ').toLowerCase(),
    // Last 10 digits: "+91 98765 43210", "098765 43210" and "9876543210" are
    // one number. Phones are stored as typed, so this is the only place they
    // become comparable.
    phoneKey: (phone ?? '').replace(/[^0-9]/g, '').slice(-10),
  };
}
