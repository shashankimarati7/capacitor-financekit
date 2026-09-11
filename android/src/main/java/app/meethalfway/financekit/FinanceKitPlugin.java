package app.meethalfway.financekit;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/**
 * FinanceKit is an Apple framework; there is nothing to read on Android.
 * Every method resolves as "unavailable" so shared app code can call it safely
 * and the Android build keeps compiling with this plugin installed.
 */
@CapacitorPlugin(name = "FinanceKit")
public class FinanceKitPlugin extends Plugin {

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("available", false);
        call.resolve(ret);
    }

    @PluginMethod
    public void authorizationStatus(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("status", "unavailable");
        call.resolve(ret);
    }

    @PluginMethod
    public void requestAuthorization(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("status", "unavailable");
        call.resolve(ret);
    }

    @PluginMethod
    public void getAccounts(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("accounts", new JSArray());
        call.resolve(ret);
    }

    @PluginMethod
    public void getBalances(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("balances", new JSArray());
        call.resolve(ret);
    }

    @PluginMethod
    public void getTransactionChanges(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("inserted", new JSArray());
        ret.put("updated", new JSArray());
        ret.put("deleted", new JSArray());
        ret.put("historyToken", null);
        call.resolve(ret);
    }
}
