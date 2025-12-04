package com.example.ext_vpn

import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import androidx.annotation.RequiresApi
import com.example.ext_vpn.singbox.WSParserManager
import com.hello.x.xnetwork.Callback
import com.hello.x.xnetwork.Parser
import com.hello.x.xnetwork.XnetworkPlugin
import io.flutter.embedding.android.FlutterActivity
import io.nekohasekai.libbox.Libbox

class MainActivity : FlutterActivity(), Parser {
    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        XnetworkPlugin.parser = this;
        WSParserManager.sharedManager().setApplicationContext(applicationContext)
        Log.i("vApp", "MainActivity")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        XnetworkPlugin.parser = this;
        WSParserManager.sharedManager().setApplicationContext(applicationContext)
        Log.i("vApp", "MainActivity")
    }

    override fun start(url: String?, global: Boolean): Boolean {
        val json = Libbox.parse(url, false)
        if (json.isEmpty()) {
            return false;
        }
        val xjson = WSParserManager.sharedManager().save(json, global)
        WSParserManager.sharedManager().startTunnel(xjson)
        return true;
    }

    override fun parse(url: String): String {
        val json = Libbox.parse(url, true)
        return json;
    }

    override fun stop(): Boolean {
        WSParserManager.sharedManager().stopTunnel();
        return true;
    }

    var mCallback: Callback? = null

    override fun getPermission(callback: Callback?) {
        val intent = VpnService.prepare(this)
        if (intent == null) {
            // 已经获取到 VPN 权限，直接开始
            callback?.ok(true)
        } else {
            mCallback = callback
            try {
                startActivityForResult(Intent.createChooser(intent, "获取VPN权限"), 202)
            } catch (e: Exception) {
                Log.i("vApp", e.toString())
            }
        }
    }

    override fun onActivityReenter(resultCode: Int, data: Intent?) {
        super.onActivityReenter(resultCode, data)
        if (resultCode == 202) {
            mCallback?.ok(true)
        }
    }
}
