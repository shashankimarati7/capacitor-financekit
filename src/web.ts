import { WebPlugin } from '@capacitor/core';

import type {
  FinanceKitPlugin,
  FinanceKitAccount,
  FinanceKitAuthorizationStatus,
  FinanceKitBalance,
  FinanceKitTransactionChanges,
} from './definitions';

/** FinanceKit exists only on iPhone. On the web everything is unavailable. */
export class FinanceKitWeb extends WebPlugin implements FinanceKitPlugin {
  async isAvailable(): Promise<{ available: boolean }> {
    return { available: false };
  }
  async authorizationStatus(): Promise<{ status: FinanceKitAuthorizationStatus }> {
    return { status: 'unavailable' };
  }
  async requestAuthorization(): Promise<{ status: FinanceKitAuthorizationStatus }> {
    return { status: 'unavailable' };
  }
  async getAccounts(): Promise<{ accounts: FinanceKitAccount[] }> {
    return { accounts: [] };
  }
  async getBalances(): Promise<{ balances: FinanceKitBalance[] }> {
    return { balances: [] };
  }
  async getTransactionChanges(): Promise<FinanceKitTransactionChanges> {
    return { inserted: [], updated: [], deleted: [], historyToken: null };
  }
}
