# @meethalfway/capacitor-financekit

Apple FinanceKit (Apple Card, Apple Cash, Savings) for Capacitor, used by Halfway

## Install

To use npm

```bash
npm install @meethalfway/capacitor-financekit
````

To use yarn

```bash
yarn add @meethalfway/capacitor-financekit
```

Sync native files

```bash
npx cap sync
```

## API

<docgen-index>

* [`isAvailable()`](#isavailable)
* [`authorizationStatus()`](#authorizationstatus)
* [`requestAuthorization()`](#requestauthorization)
* [`getAccounts()`](#getaccounts)
* [`getBalances()`](#getbalances)
* [`getTransactionChanges(...)`](#gettransactionchanges)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### isAvailable()

```typescript
isAvailable() => Promise<{ available: boolean; }>
```

True on an iPhone with iOS 17.4+ where FinanceKit data can exist.

**Returns:** <code>Promise&lt;{ available: boolean; }&gt;</code>

--------------------


### authorizationStatus()

```typescript
authorizationStatus() => Promise<{ status: FinanceKitAuthorizationStatus; }>
```

**Returns:** <code>Promise&lt;{ status: <a href="#financekitauthorizationstatus">FinanceKitAuthorizationStatus</a>; }&gt;</code>

--------------------


### requestAuthorization()

```typescript
requestAuthorization() => Promise<{ status: FinanceKitAuthorizationStatus; }>
```

Shows Apple's own permission sheet where the user picks accounts.

**Returns:** <code>Promise&lt;{ status: <a href="#financekitauthorizationstatus">FinanceKitAuthorizationStatus</a>; }&gt;</code>

--------------------


### getAccounts()

```typescript
getAccounts() => Promise<{ accounts: FinanceKitAccount[]; }>
```

**Returns:** <code>Promise&lt;{ accounts: FinanceKitAccount[]; }&gt;</code>

--------------------


### getBalances()

```typescript
getBalances() => Promise<{ balances: FinanceKitBalance[]; }>
```

Most recent balance for each shared account.

**Returns:** <code>Promise&lt;{ balances: FinanceKitBalance[]; }&gt;</code>

--------------------


### getTransactionChanges(...)

```typescript
getTransactionChanges(options: { accountId: string; historyToken?: string | null; }) => Promise<FinanceKitTransactionChanges>
```

Everything that changed on one account since the token (or all history the
user shared, when no token is given). Returns once caught up; it does not
keep listening.

| Param         | Type                                                               |
| ------------- | ------------------------------------------------------------------ |
| **`options`** | <code>{ accountId: string; historyToken?: string \| null; }</code> |

**Returns:** <code>Promise&lt;<a href="#financekittransactionchanges">FinanceKitTransactionChanges</a>&gt;</code>

--------------------


### Interfaces


#### FinanceKitAccount

| Prop                     | Type                                             | Description                                                     |
| ------------------------ | ------------------------------------------------ | --------------------------------------------------------------- |
| **`id`**                 | <code>string</code>                              | FinanceKit's stable account identifier (UUID string).           |
| **`displayName`**        | <code>string</code>                              |                                                                 |
| **`institutionName`**    | <code>string</code>                              |                                                                 |
| **`accountDescription`** | <code>string \| null</code>                      |                                                                 |
| **`currencyCode`**       | <code>string</code>                              |                                                                 |
| **`kind`**               | <code>'asset' \| 'liability' \| 'unknown'</code> | "asset" for Apple Cash and Savings, "liability" for Apple Card. |


#### FinanceKitBalance

| Prop                       | Type                | Description                                                   |
| -------------------------- | ------------------- | ------------------------------------------------------------- |
| **`accountId`**            | <code>string</code> |                                                               |
| **`amount`**               | <code>string</code> | Decimal as a string, never a float, so cents are not rounded. |
| **`currencyCode`**         | <code>string</code> |                                                               |
| **`creditDebitIndicator`** | <code>string</code> |                                                               |
| **`asOfDate`**             | <code>string</code> |                                                               |


#### FinanceKitTransactionChanges

| Prop               | Type                                 | Description                                                                                                                 |
| ------------------ | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| **`inserted`**     | <code>FinanceKitTransaction[]</code> |                                                                                                                             |
| **`updated`**      | <code>FinanceKitTransaction[]</code> |                                                                                                                             |
| **`deleted`**      | <code>string[]</code>                | IDs of transactions that no longer exist.                                                                                   |
| **`historyToken`** | <code>string \| null</code>          | Opaque token. Store it and pass it back next time to receive only what changed since. Null only when nothing could be read. |


#### FinanceKitTransaction

| Prop                       | Type                        | Description                                                              |
| -------------------------- | --------------------------- | ------------------------------------------------------------------------ |
| **`id`**                   | <code>string</code>         |                                                                          |
| **`accountId`**            | <code>string</code>         |                                                                          |
| **`transactionDate`**      | <code>string</code>         | ISO 8601.                                                                |
| **`postedDate`**           | <code>string \| null</code> |                                                                          |
| **`description`**          | <code>string</code>         |                                                                          |
| **`merchantName`**         | <code>string \| null</code> |                                                                          |
| **`merchantCategoryCode`** | <code>number \| null</code> |                                                                          |
| **`amount`**               | <code>string</code>         | Decimal as a string. Always positive; direction is creditDebitIndicator. |
| **`currencyCode`**         | <code>string</code>         |                                                                          |
| **`creditDebitIndicator`** | <code>string</code>         | "credit" (money in) or "debit" (money out).                              |
| **`status`**               | <code>string</code>         |                                                                          |
| **`transactionType`**      | <code>string</code>         |                                                                          |


### Type Aliases


#### FinanceKitAuthorizationStatus

Apple FinanceKit for Capacitor, used by Halfway (meethalfway.app).

iPhone only (iOS 17.4+), and only in apps Apple has granted the FinanceKit
managed entitlement. Everywhere else every method reports "unavailable"
rather than throwing, so the app can call it unconditionally.

Data never leaves the device through this plugin: it returns what the user
chose to share, and the app decides what to do with it.

<code>'authorized' | 'denied' | 'notDetermined' | 'unavailable'</code>

</docgen-api>
