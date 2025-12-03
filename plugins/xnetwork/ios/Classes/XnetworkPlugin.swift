import Flutter
import UIKit

public protocol Parser {
    func start(url:String, global:Bool, parameters:[String:AnyHashable]) -> Bool;
    func stop();
    func getVPNPermission(completion: @escaping (Bool) -> Void);
}

public class XnetworkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "xnetwork", binaryMessenger: registrar.messenger())
        let instance = XnetworkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    static var _parser:Parser?;
    
    static var parser:Parser {
        return _parser!;
    }
    
    
    public static func register(parser: Parser) {
        _parser = parser;
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "stop":
            Self.parser.stop();
            result(true);
            
        case "getVPNPermission":
            Self.parser.getVPNPermission(completion: result);
            
        case "start":
            guard let dict = call.arguments as? [String:AnyHashable] else { return result(false); }
            guard let url = dict["url"] as? String else { return result(false); }
            guard let parameters = dict["parameters"] as? [String:AnyHashable] else { return result(false); }
            guard let global = dict["global"] as? Bool else { return result(false); }
            let ok = Self.parser.start(url: url, global: global, parameters: parameters);
            result(ok);
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
