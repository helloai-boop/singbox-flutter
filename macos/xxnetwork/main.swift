//
//  main.m
//  xxnetwork
//
//  Created by x on 2025/11/23.
//

import Foundation
import Libbox

// 获取所有参数
let arguments = CommandLine.arguments

// 获取特定位置的参数
if arguments.count < 4 {
    exit(0)
}
var url = arguments[1];
guard let global = Int(arguments[2]) else {
    exit(0)
}
var workingDir = arguments[3];
let json = LibboxParse(url)
if json.count == 0 {
    exit(0)
}
WSParserManager.shared().workingDir = URL(fileURLWithPath: workingDir);
WSParserManager.shared().isGlobalMode = global == 1;
var xjson = WSParserManager.shared().save(json);
var provider = ExtensionProvider()

NSLog("xjson:\(xjson)")

Task {
    do {
        try await provider.startTunnel(worker: workingDir, configuration: xjson);
    }
    catch(let exception) {
        NSLog("exception:\(exception)")
    }
}

RunLoop.current.run();



