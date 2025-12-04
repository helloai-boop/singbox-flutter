package com.hello.x.xnetwork;

public interface Parser {

    boolean start(String url, boolean global);
    String parse(String url);
    boolean stop();
    void getPermission(Callback callback);
}
