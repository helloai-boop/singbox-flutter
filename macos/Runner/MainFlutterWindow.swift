import Cocoa
import FlutterMacOS
import xnetwork

class MainFlutterWindow: NSWindow, Parser {
    
    let driverPath = "/Library/Application Support/xxnetwork/xxnetwork";
   
    func getVPNPermission(completion: @escaping (Bool) -> Void) {
        completion(InstallDriver())
    }
    
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        XnetworkPlugin.register(parser: self);
        super.awakeFromNib()
        
    }
    func InstallDriver() -> Bool {
        guard let shellPath = Bundle.main.path(forResource: "install", ofType: "sh") else {
            return false;
        }
        guard let path = Bundle.main.builtInPlugInsPath else {
            return false;
        }
        let drivePath = path + "/" + "xxnetwork"
        let installAlert = NSAlert();
        installAlert.addButton(withTitle: "Install");
        installAlert.addButton(withTitle: "Quit");
        installAlert.messageText = "xsing-box-exec needs to install a tool to /Library/Application Support/xxnetwork/ with administrator privileges to set system proxy quickly.\nOtherwise you need to type in the administrator password every time you change system proxy through xFuture."
        if installAlert.runModal() == .alertFirstButtonReturn {
            let script = "do shell script \"bash \(shellPath) \(drivePath)\" with administrator privileges";
            var error:NSDictionary?;
            let appleScript = NSAppleScript(source: script);
            appleScript?.executeAndReturnError(&error)
            if error != nil {
                NSLog("installation failure:\(String(describing: error))");
                return false;
            }
            NSLog("Successfully");
            return true;
        }
        return false;
    }
    
}
