# singbox

A new Flutter singbox project.

## Getting Started

Many developers today are building VPN solutions on top of **sing-box (singbox)**. As a highly popular and extremely performant VPN framework, sing-box offers exceptional flexibility and power. However, its client-side usage can be complex, and managing full configuration files often becomes a burden for both developers and end-users.

To address this, I’ve created a **fully cross-platform Flutter VPN client** built on top of sing-box. It runs smoothly on **iOS, macOS, Windows, and Android**, providing a clean, consistent, and modern interface across all platforms. The primary goal is simplicity: instead of dealing with complete sing-box configuration files, you only need to provide **one single URL**, and the app will automatically handle initialization, parsing, and connection management.

This approach makes the client ideal for developers who want a quick integration path, as well as for everyday users who just want a straightforward and reliable VPN experience without technical overhead.

Additionally, on **Windows**, the application must be launched with **administrator privileges**, as this is required to enable and operate in **TUN mode**. Without admin rights, the VPN tunnel cannot be properly established.

Whether you're distributing VPN services, testing sing-box deployments, or building your own VPN product, this Flutter-based client offers a lightweight, convenient, and highly portable solution powered by the performance and reliability of sing-box.


just 3 interface

```dart

static Future<bool> getVPNPermission() async;

static Future<bool> start(
    String url,
    bool isGlobalMode, {
    Map<String, dynamic> parameters = const {},
});


static Future<bool> stop() async

```


## Contact
yhelloai@gmail.com



## Demo
https://github.com/helloai-boop/singbox-flutter