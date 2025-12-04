import Foundation
import Libbox
import NetworkExtension

open class PacketTunnelProvider: NEPacketTunnelProvider {
    
    public var username: String? = nil
    private var commandServer: LibboxCommandServer!
    private var boxService: LibboxBoxService!
    private var systemProxyAvailable = false
    private var systemProxyEnabled = false
    private var platformInterface: ExtensionPlatformInterface!
    private var commandClient:LibboxCommandClient?;
    
    open override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping ((any Error)?) -> Void) {
        WSParserManager.shared().setupExtenstionApplication();
        LibboxClearServiceError()
        let options = LibboxSetupOptions()
        options.basePath = WSParserManager.shared().sharedDir.relativePath
        options.workingPath = WSParserManager.shared().workingDir.relativePath
        options.tempPath = WSParserManager.shared().cacheDir.relativePath
        var error: NSError?
        #if os(tvOS)
            options.isTVOS = true
        #endif
        if let username {
            options.username = username
        }
        LibboxSetup(options, &error)
        if let error {
            completionHandler(error);
            writeFatalError("(packet-tunnel) error: setup service: \(error.localizedDescription)")
            return
        }

        LibboxRedirectStderr(WSParserManager.shared().cacheDir.appendingPathComponent("stderr.log").relativePath, &error)
        if let error {
            completionHandler(error);
            writeFatalError("(packet-tunnel) redirect stderr error: \(error.localizedDescription)")
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
            completionHandler(error);
            writeFatalError("(packet-tunnel): log server start error: \(error.localizedDescription)")
            return
        }
        writeMessage("(packet-tunnel): Here I stand")
        Task {
            await startService()
        }
    }


    func writeMessage(_ message: String) {
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
        cancelTunnelWithError(NSError(domain: message, code: 0))
    }

    private func startService() async {
        guard let configContent: String = WSParserManager.shared().userDefaults.string(forKey: "kApplicationConfiguration") else {
            writeFatalError("(packet-tunnel) error: Invalid application URL");
            return;
        }
        if !configContent.contains("outbounds") {
            writeFatalError("(packet-tunnel) error: Invalid application");
            return;
        }
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
        #if os(macOS)
            await SharedPreferences.startedByUser.set(true)
        #endif
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
        reasserting = true
        defer {
            reasserting = false
        }
        stopService()
        commandServer.resetLog()
        await startService()
    }

    func postServiceClose() {
        boxService = nil
    }

    override open func stopTunnel(with reason: NEProviderStopReason) async {
        writeMessage("(packet-tunnel) stopping, reason: \(reason)")
        stopService()
        if let server = commandServer {
            try? await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
            try? server.close()
            commandServer = nil
        }
        #if os(macOS)
            if reason == .userInitiated {
                await SharedPreferences.startedByUser.set(reason == .userInitiated)
            }
        #endif
    }

    override open func handleAppMessage(_ messageData: Data) async -> Data? {
//        do {
//            guard let app = try JSONSerialization.jsonObject(with: messageData) as? Dictionary<String, Any> else {
//                return messageData;
//            }
//            guard let type = app["type"] as? Int else {
//                return messageData;
//            }
//            
//            if type == 4 {
//                let rsp = ["downloadlink":download, "uploadlink":upload, "mdownloadlink":downloadTotal, "muploadlink":uploadTotal];
//                let dd = try JSONSerialization.data(withJSONObject: rsp, options: .prettyPrinted);
//                return dd;
//            }
//            
//            guard let ips = app["urls"] as? [Any] else { return messageData }
//            WSParserManager.shared().ping(ips, type: Int32(type))
//        }
//        catch(let exception) {
//            NSLog("exception: \(exception)")
//        }
        
        return messageData
    }

    override open func sleep() async {
        if let boxService {
            boxService.pause()
        }
    }

    override open func wake() {
        if let boxService {
            boxService.wake()
        }
    }
}
