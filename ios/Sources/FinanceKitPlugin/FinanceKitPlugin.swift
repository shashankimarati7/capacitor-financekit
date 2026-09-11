import Foundation
import Capacitor

/**
 * JavaScript bridge for HalfwayFinanceKitStore. See src/definitions.ts for the
 * API. Every method resolves; none rejects for "not available", so the app
 * can call it on any device. Real FinanceKit errors reject with a plain
 * message and are logged.
 */
@objc(FinanceKitPlugin)
public class FinanceKitPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "FinanceKitPlugin"
    public let jsName = "FinanceKit"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "isAvailable", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "authorizationStatus", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestAuthorization", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAccounts", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getBalances", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getTransactionChanges", returnType: CAPPluginReturnPromise),
    ]
    private let store = HalfwayFinanceKitStore()

    private func fail(_ call: CAPPluginCall, _ error: Error) {
        CAPLog.print("[FinanceKit] \(error)")
        call.reject("Could not read Wallet data.", nil, error)
    }

    @objc func isAvailable(_ call: CAPPluginCall) {
        call.resolve(["available": store.isAvailable()])
    }

    @objc func authorizationStatus(_ call: CAPPluginCall) {
        #if canImport(FinanceKit)
        if #available(iOS 17.4, *) {
            Task {
                do { call.resolve(["status": try await store.authorizationStatus()]) }
                catch { fail(call, error) }
            }
            return
        }
        #endif
        call.resolve(["status": HalfwayFinanceKitStore.unavailableStatus])
    }

    @objc func requestAuthorization(_ call: CAPPluginCall) {
        #if canImport(FinanceKit)
        if #available(iOS 17.4, *) {
            Task {
                do { call.resolve(["status": try await store.requestAuthorization()]) }
                catch { fail(call, error) }
            }
            return
        }
        #endif
        call.resolve(["status": HalfwayFinanceKitStore.unavailableStatus])
    }

    @objc func getAccounts(_ call: CAPPluginCall) {
        #if canImport(FinanceKit)
        if #available(iOS 17.4, *) {
            Task {
                do { call.resolve(["accounts": try await store.accounts()]) }
                catch { fail(call, error) }
            }
            return
        }
        #endif
        call.resolve(["accounts": []])
    }

    @objc func getBalances(_ call: CAPPluginCall) {
        #if canImport(FinanceKit)
        if #available(iOS 17.4, *) {
            Task {
                do { call.resolve(["balances": try await store.latestBalances()]) }
                catch { fail(call, error) }
            }
            return
        }
        #endif
        call.resolve(["balances": []])
    }

    @objc func getTransactionChanges(_ call: CAPPluginCall) {
        guard let accountId = call.getString("accountId") else {
            call.reject("accountId is required")
            return
        }
        let historyToken = call.getString("historyToken")
        #if canImport(FinanceKit)
        if #available(iOS 17.4, *) {
            Task {
                do { call.resolve(try await store.transactionChanges(accountId: accountId, historyToken: historyToken)) }
                catch { fail(call, error) }
            }
            return
        }
        #endif
        call.resolve(["inserted": [], "updated": [], "deleted": [], "historyToken": NSNull()])
    }
}
