package com.example.ext_vpn.singbox;

public interface Callback {

    int K_IDEL = 0;

    int K_Connecting = 1;

    int K_Connected = 2;

    int K_Disconnected = 3;

    // 0 IDEL, 1 Connecting, 2 Connected, 3 Disconnected
    void connectionStatusDidChange(int status);

    void onPingResponse(int rtt, String uri);
}
