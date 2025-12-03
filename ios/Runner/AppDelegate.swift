import Flutter
import UIKit
import xnetwork
import Libtech

@main
@objc class AppDelegate: FlutterAppDelegate, Parser {
    func start(url: String, global: Bool, parameters: [String : AnyHashable]) -> Bool {
        WSParserManager.shared().isGlobalMode = global;
        let json = LibtechParse(url)
        if json.count == 0 {
            return false;
        }
        WSParserManager.shared().save(json);
        WSParserManager.shared().connect(url);
        return true;
    }
    
    func stop() {
        WSParserManager.shared().disconnect();
    }
    
    func getVPNPermission(completion: @escaping (Bool) -> Void) {
        WSParserManager.shared().getVPNPermission(completion)
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        XnetworkPlugin.register(parser: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
