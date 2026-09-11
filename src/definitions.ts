/**
 * Apple FinanceKit for Capacitor, used by Halfway (meethalfway.app).
 *
 * iPhone only (iOS 17.4+), and only in apps Apple has granted the FinanceKit
 * managed entitlement. Everywhere else every method reports "unavailable"
 * rather than throwing, so the app can call it unconditionally.
 *
 * Data never leaves the device through this plugin: it returns what the user
 * chose to share, and the app decides what to do with it.
 */
export type FinanceKitAuthorizationStatus = 'authorized' | 'denied' | 'notDetermined' | 'unavailable';

export interface FinanceKitAccount {
  /** FinanceKit's stable account identifier (UUID string). */
  id: string;
  displayName: string;
  institutionName: string;
  accountDescription: string | null;
  currencyCode: string;
  /** "asset" for Apple Cash and Savings, "liability" for Apple Card. */
  kind: 'asset' | 'liability' | 'unknown';
}

export interface FinanceKitBalance {
  accountId: string;
  /** Decimal as a string, never a float, so cents are not rounded. */
  amount: string;
  currencyCode: string;
  creditDebitIndicator: string;
  asOfDate: string;
}

export interface FinanceKitTransaction {
  id: string;
  accountId: string;
  /** ISO 8601. */
  transactionDate: string;
  postedDate: string | null;
  description: string;
  merchantName: string | null;
  merchantCategoryCode: number | null;
  /** Decimal as a string. Always positive; direction is creditDebitIndicator. */
  amount: string;
  currencyCode: string;
  /** "credit" (money in) or "debit" (money out). */
  creditDebitIndicator: string;
  status: string;
  transactionType: string;
}

export interface FinanceKitTransactionChanges {
  inserted: FinanceKitTransaction[];
  updated: FinanceKitTransaction[];
  /** IDs of transactions that no longer exist. */
  deleted: string[];
  /**
   * Opaque token. Store it and pass it back next time to receive only what
   * changed since. Null only when nothing could be read.
   */
  historyToken: string | null;
}

export interface FinanceKitPlugin {
  /** True on an iPhone with iOS 17.4+ where FinanceKit data can exist. */
  isAvailable(): Promise<{ available: boolean }>;
  authorizationStatus(): Promise<{ status: FinanceKitAuthorizationStatus }>;
  /** Shows Apple's own permission sheet where the user picks accounts. */
  requestAuthorization(): Promise<{ status: FinanceKitAuthorizationStatus }>;
  getAccounts(): Promise<{ accounts: FinanceKitAccount[] }>;
  /** Most recent balance for each shared account. */
  getBalances(): Promise<{ balances: FinanceKitBalance[] }>;
  /**
   * Everything that changed on one account since the token (or all history the
   * user shared, when no token is given). Returns once caught up; it does not
   * keep listening.
   */
  getTransactionChanges(options: {
    accountId: string;
    historyToken?: string | null;
  }): Promise<FinanceKitTransactionChanges>;
}
