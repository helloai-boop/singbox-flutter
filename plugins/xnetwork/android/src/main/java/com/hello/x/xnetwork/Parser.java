package com.hello.x.xnetwork;

public interface Parser {

    boolean start(String url, boolean global);
    boolean stop();
    void getPermission(Callback callback);
}
