package com.hello.x.xnetwork;
import android.content.Context;
import androidx.annotation.NonNull;
import java.util.Map;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * VpnPlugin
 */
@SuppressWarnings("unchecked")
public class XnetworkPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    final String TAG = "xyz";
    private Context applicationContext;

    public static Parser parser;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "xnetwork");
        channel.setMethodCallHandler(this);
        applicationContext = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {

            case "getPlatformVersion": {
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            }

            case "getVPNPermission": {
                parser.getPermission(new Callback() {
                    @Override
                    public void ok(boolean ok) {
                        result.success(ok);
                    }
                });
                break;
            }

            case "start": {
                Map<String, Object> arguments = (Map<String, Object>) call.arguments;
                String url = (String) arguments.get("url");
                Boolean isGlobal = (Boolean) arguments.get("global");
                assert isGlobal != null;
                Boolean ok = parser.start(url, isGlobal.booleanValue());
                result.success(ok);
                break;
            }
            case "parse": {
                Map<String, Object> arguments = (Map<String, Object>) call.arguments;
                String url = (String) arguments.get("url");
                String ok = parser.parse(url);
                result.success(ok);
                break;
            }
            case "stop": {
                parser.stop();
                result.success(true);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}

