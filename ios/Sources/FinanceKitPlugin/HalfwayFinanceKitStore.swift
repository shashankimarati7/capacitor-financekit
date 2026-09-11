import Foundation
#if canImport(FinanceKit)
import FinanceKit
#endif

/**
 * Reads Apple FinanceKit data and turns it into plain dictionaries for the
 * JavaScript bridge.
 *
 * Named HalfwayFinanceKitStore, not FinanceKit, so it can never shadow Apple's
 * FinanceKit module.
 *
 * DEFENSIVE BY DESIGN. FinanceKit is iOS 17.4+ and only works in an app with
 * the managed entitlement, so every entry point checks availability first and
 * reports "unavailable" instead of crashing. Enum values (status, transaction
 * type, credit/debit) are passed through with String(describing:) so a new
 * case Apple adds later never breaks the build.
 *
 * API shapes follow Apple's FinanceKit documentation and the WWDC24 "Meet
 * FinanceKit" session: FinanceStore.shared, accounts(query:),
 * accountBalances(query:), transactionHistory(forAccountID:since:isMonitoring:)
 * with a Codable HistoryToken.
 */
@objc public class HalfwayFinanceKitStore: NSObject {
    static let unavailableStatus = "unavailable"

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static func iso(_ date: Date?) -> Any {
        guard let date = date else { return NSNull() }
        return isoFormatter.string(from: date)
    }

    static func decimalString(_ value: Decimal) -> String {
        return NSDecimalNumber(decimal: value).stringValue
    }

    /** Extracts the digits from any MCC representation, e.g. "5411". */
    static func digits(_ value: Any?) -> Any {
        guard let value = value else { return NSNull() }
        let text = String(describing: value).filter { $0.isNumber }
        if let number = Int(text) { return number }
        return NSNull()
    }

    public func isAvailable() -> Bool {
        #if canImport(FinanceKit)
        if #available(iOS 17.4, *) {
            return FinanceStore.isDataAvailable(.financialData)
        }
        #endif
        return false
    }

    #if canImport(FinanceKit)
    @available(iOS 17.4, *)
    static func statusName(_ status: AuthorizationStatus) -> String {
        switch status {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        @unknown default: return "denied"
        }
    }

    @available(iOS 17.4, *)
    public func authorizationStatus() async throws -> String {
        guard isAvailable() else { return Self.unavailableStatus }
        return Self.statusName(try await FinanceStore.shared.authorizationStatus())
    }

    @available(iOS 17.4, *)
    public func requestAuthorization() async throws -> String {
        guard isAvailable() else { return Self.unavailableStatus }
        return Self.statusName(try await FinanceStore.shared.requestAuthorization())
    }

    @available(iOS 17.4, *)
    public func accounts() async throws -> [[String: Any]] {
        guard isAvailable() else { return [] }
        let query = AccountQuery(
            sortDescriptors: [SortDescriptor(\Account.displayName)],
            predicate: nil
        )
        let accounts = try await FinanceStore.shared.accounts(query: query)
        return accounts.map { account in
            let kind: String
            switch account {
            case .asset: kind = "asset"
            case .liability: kind = "liability"
            @unknown default: kind = "unknown"
            }
            return [
                "id": account.id.uuidString,
                "displayName": account.displayName,
                "institutionName": account.institutionName,
                "accountDescription": (account.accountDescription as Any?) ?? NSNull(),
                "currencyCode": account.currencyCode,
                "kind": kind,
            ]
        }
    }

    @available(iOS 17.4, *)
    public func latestBalances() async throws -> [[String: Any]] {
        guard isAvailable() else { return [] }
        let query = AccountBalanceQuery(
            sortDescriptors: [SortDescriptor(\AccountBalance.asOfDate, order: .reverse)],
            predicate: nil
        )
        let balances = try await FinanceStore.shared.accountBalances(query: query)

        // Newest first, so the first balance seen per account is its latest.
        var seen = Set<UUID>()
        var result: [[String: Any]] = []
        for balance in balances {
            if seen.contains(balance.accountID) { continue }
            seen.insert(balance.accountID)

            let chosen: Balance
            switch balance.currentBalance {
            case .available(let value): chosen = value
            case .booked(let value): chosen = value
            case .availableAndBooked(_, let booked): chosen = booked
            @unknown default: continue
            }

            result.append([
                "accountId": balance.accountID.uuidString,
                "amount": Self.decimalString(chosen.amount.amount),
                "currencyCode": chosen.amount.currencyCode,
                "creditDebitIndicator": String(describing: chosen.creditDebitIndicator),
                "asOfDate": Self.iso(chosen.asOfDate),
            ])
        }
        return result
    }

    @available(iOS 17.4, *)
    static func transactionDictionary(_ tx: Transaction) -> [String: Any] {
        return [
            "id": tx.id.uuidString,
            "accountId": tx.accountID.uuidString,
            "transactionDate": iso(tx.transactionDate),
            "postedDate": iso(tx.postedDate),
            "description": tx.transactionDescription,
            "merchantName": (tx.merchantName as Any?) ?? NSNull(),
            "merchantCategoryCode": digits(tx.merchantCategoryCode),
            "amount": decimalString(tx.transactionAmount.amount),
            "currencyCode": tx.transactionAmount.currencyCode,
            "creditDebitIndicator": String(describing: tx.creditDebitIndicator),
            "status": String(describing: tx.status),
            "transactionType": String(describing: tx.transactionType),
        ]
    }

    /**
     * Collects every change since the token, then returns. isMonitoring is
     * false, so the sequence finishes once it has caught up instead of waiting
     * for future changes (Halfway syncs when the app opens).
     */
    @available(iOS 17.4, *)
    public func transactionChanges(accountId: String, historyToken: String?) async throws -> [String: Any] {
        guard isAvailable(), let accountUUID = UUID(uuidString: accountId) else {
            return ["inserted": [], "updated": [], "deleted": [], "historyToken": NSNull()]
        }

        var token: FinanceStore.HistoryToken? = nil
        if let encoded = historyToken, let data = Data(base64Encoded: encoded) {
            token = try? JSONDecoder().decode(FinanceStore.HistoryToken.self, from: data)
        }

        var inserted: [[String: Any]] = []
        var updated: [[String: Any]] = []
        var deleted: [String] = []
        var latestToken: FinanceStore.HistoryToken? = token

        let history = FinanceStore.shared.transactionHistory(
            forAccountID: accountUUID,
            since: token,
            isMonitoring: false
        )
        for try await change in history {
            inserted.append(contentsOf: change.inserted.map(Self.transactionDictionary))
            updated.append(contentsOf: change.updated.map(Self.transactionDictionary))
            deleted.append(contentsOf: change.deleted.map { $0.uuidString })
            latestToken = change.newToken
        }

        var encodedToken: Any = NSNull()
        if let latestToken = latestToken, let data = try? JSONEncoder().encode(latestToken) {
            encodedToken = data.base64EncodedString()
        }

        return [
            "inserted": inserted,
            "updated": updated,
            "deleted": deleted,
            "historyToken": encodedToken,
        ]
    }
    #endif
}
