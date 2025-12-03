package com.example.ext_vpn.singbox;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.core.content.ContextCompat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;

import go.Seq;
import io.nekohasekai.libbox.Libbox;

public class WSParserManager {
    public final static String ApplicationPackageName = "com.example.ext_vpn";
    private String currentURI = "";
    private static final String TAG = "VPNService";
    private int currentStatus = 0;
    private Context applicationContext = null;
    private Callback callback = null;
    private static volatile WSParserManager g_instance = null;
    private Handler uiHander;
    public static WSParserManager sharedManager() {
        if (g_instance == null) {
            synchronized (WSParserManager.class) {
                if (g_instance == null) {
                    g_instance = new WSParserManager();
                    g_instance.uiHander = new Handler(Looper.getMainLooper());
                }
            }
        }
        return g_instance;
    }

    public void setVPNConectionStatusCallback(Callback callback) {
        this.callback = callback;
    }


    private void invokeCallback(int status) {
        currentStatus = status;
        if (callback != null) {
            callback.connectionStatusDidChange(status);
        }
    }
    public void setApplicationContext(Context context) {
        if (applicationContext != null) return;
        applicationContext = context;
        BroadcastReceiver mMsgReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                Bundle bundle = intent.getExtras();
                assert bundle != null;
                int action = bundle.getInt("action");
                // 连接状态变化
                if (action == 0) {
                    invokeCallback(Callback.K_Connected);
                    Log.i(TAG, "currentStatus:" + currentStatus);
                }
            }
        };
        Seq.setContext(applicationContext);
        Libbox.setLocale(Locale.getDefault().toLanguageTag().replace("-", "_"));
        IntentFilter filter = new IntentFilter("vpn_app");
        ContextCompat.registerReceiver(applicationContext, mMsgReceiver, filter, ContextCompat.RECEIVER_NOT_EXPORTED);
        getConnectionStatus();
    }

    private void getConnectionStatus(){
        Intent intent = new Intent();
        intent.setAction(Action.SERVICE_ECHO).setPackage(ApplicationPackageName).putExtra("action", 2);
        applicationContext.sendBroadcast(intent);
    }

    public String save(String json, boolean global) throws JSONException {

        JSONObject proxy = new JSONObject(json);
        String type = proxy.getString("type");
        if (type.equals("shadowsocks")) {

            if (proxy.has("uot")) {
                proxy.put("uot", proxy.getString("uot"));
            }
            else {
                proxy.put("uot", true);
            }
        }
        String p = readJsonFromAssets(applicationContext, global ? "global.json" : "ai.json");

        JSONObject configuration = new JSONObject(p);
        JSONArray outbounds = configuration.getJSONArray("outbounds");
        outbounds.put(0, proxy);
        configuration.put("outbounds", outbounds);
        return  configuration.toString();
    }

    public static String readJsonFromAssets(Context context, String fileName) {
        String jsonString = null;
        try {
            InputStream inputStream = context.getAssets().open(fileName);
            int size = inputStream.available();
            byte[] buffer = new byte[size];
            inputStream.read(buffer);
            inputStream.close();
            jsonString = new String(buffer, "UTF-8");
        } catch (IOException e) {
            e.printStackTrace();
        }
        return jsonString;
    }


    public boolean startTunnel(String uri){
        if (applicationContext == null) return false;
        if (currentStatus == Callback.K_Connected || currentStatus == Callback.K_Connecting)
            return true;
        Intent intent = new Intent(applicationContext, VPNService.class);
        intent.putExtra("uri", uri);
        invokeCallback(Callback.K_Connecting);
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N_MR1) {
            applicationContext.startForegroundService(intent);
        } else {
            applicationContext.startService(intent);
        }
        currentURI = uri;
        return true;
    }

    public boolean stopTunnel(){
        if (applicationContext == null) return false;
        Intent intent = new Intent();
        intent.setAction(Action.SERVICE_CLOSE).setPackage(ApplicationPackageName);
        applicationContext.sendBroadcast(intent);
        currentURI = "";
        currentStatus = Callback.K_Disconnected;
        return true;
    }


}
