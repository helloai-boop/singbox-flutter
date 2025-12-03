import Cocoa
import FlutterMacOS

public protocol Parser {
    func getVPNPermission(completion: @escaping (Bool) -> Void);
}

public class XnetworkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "xnetwork", binaryMessenger: registrar.messenger)
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
            result("macOS " + "1.0.0")
        case "getVPNPermission":
            Self.parser.getVPNPermission(completion: result);
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
