import { registerPlugin } from '@capacitor/core';

import type { FinanceKitPlugin } from './definitions';

const FinanceKit = registerPlugin<FinanceKitPlugin>('FinanceKit', {
  web: () => import('./web').then((m) => new m.FinanceKitWeb()),
});

export * from './definitions';
export { FinanceKit };
