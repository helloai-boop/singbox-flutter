import Foundation
import Libbox
import NetworkExtension

@objc open class ExtensionProvider: NSObject {
    public var username: String? = nil
    private var commandServer: LibboxCommandServer!
    private var boxService: LibboxBoxService!
    private var systemProxyAvailable = false
    private var systemProxyEnabled = false
    private var platformInterface: ExtensionPlatformInterface!
    private var commandClient:LibboxCommandClient?;
    
    private var configuration:String = "";
    
    @objc open func startTunnel(worker:String, configuration:String) async throws {
        
        self.configuration = configuration;
        
        LibboxClearServiceError()
        let options = LibboxSetupOptions()
        options.basePath = worker
        options.workingPath = worker
        options.tempPath = worker
        var error: NSError?
        if let username {
            options.username = username
        }
        LibboxSetup(options, &error)
        if let error {
            writeFatalError("(packet-tunnel) error: setup service: \(error.localizedDescription)")
            return
        }
        LibboxSetMemoryLimit(false)
        
        if platformInterface == nil {
            platformInterface = ExtensionPlatformInterface(self)
        }
        commandServer = LibboxNewCommandServer(platformInterface, Int32(300))
        do {
            try commandServer.start()
        } catch {
            writeFatalError("(packet-tunnel): log server start error: \(error.localizedDescription)")
            return
        }
        writeMessage("(packet-tunnel): Here I stand")
        await startService()
    }
    
    func writeMessage(_ message: String) {
        NSLog("message:\(message)")
        if let commandServer {
            commandServer.writeMessage(message)
        }
    }
    
    public func writeFatalError(_ message: String) {
#if DEBUG
        NSLog(message)
#endif
        writeMessage(message)
        var error: NSError?
        LibboxWriteServiceError(message, &error)
    }
    
    private func startService() async {
        let configContent = self.configuration;
        if !configContent.contains("inbounds") {
            writeFatalError("(packet-tunnel) error: Invalid application");
            return;
        }
        var error: NSError?
        let service = LibboxNewService(configContent, platformInterface, &error)
        if let error {
            writeFatalError("(packet-tunnel) error: create service: \(error.localizedDescription)")
            return
        }
        guard let service else {
            return
        }
        do {
            try service.start()
        } catch {
            writeFatalError("(packet-tunnel) error: start service: \(error.localizedDescription)")
            return
        }
        commandServer.setService(service)
        boxService = service
    }
    
    private func stopService() {
        if let service = boxService {
            do {
                try service.close()
            } catch {
                writeMessage("(packet-tunnel) error: stop service: \(error.localizedDescription)")
            }
            boxService = nil
            commandServer.setService(nil)
        }
        if let platformInterface {
            platformInterface.reset()
        }
    }
    
    func reloadService() async {
        writeMessage("(packet-tunnel) reloading service")
        stopService()
        commandServer.resetLog()
        await startService()
    }
    
    func postServiceClose() {
        boxService = nil
    }
    
    @objc open func stopTunnel(with reason: NEProviderStopReason) async {
        writeMessage("(packet-tunnel) stopping, reason: \(reason)")
        stopService()
        if let server = commandServer {
            try? await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
            try? server.close()
            commandServer = nil
        }
    }
}
