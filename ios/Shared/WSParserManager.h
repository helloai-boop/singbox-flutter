//
//  YDVPNManager.h
//  VPNExtension
//
//  Created by helloc on 2023/1/15.
//  Copyright © 2023 RongVP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import <xpc/xpc.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^YDProviderManagerCompletion)(NETunnelProviderManager *_Nullable manager);

typedef void(^YDManagerCompletion)(BOOL);

@class YDItemInfo;

typedef enum : NSUInteger {
    YDVPNStatusIDLE = 0,
    YDVPNStatusConnecting,
    YDVPNStatusConnected,
    YDVPNStatusDisconnecting,
    YDVPNStatusDisconnected
} YDVPNStatus;




@interface WSParserManager : NSObject

/// Manager
+(instancetype)sharedManager;

@property (nonatomic, strong, readonly)NSUserDefaults *userDefaults;

@property (nonatomic, strong, readonly)NSURL *sharedDir;

@property (nonatomic, strong, readonly)NSURL *workingDir;

@property (nonatomic, strong, readonly)NSURL *cacheDir;


// 主进程调用，扩展进程不要调
-(void)setupVPNManager;

/// 完成
/// - Parameter completion: 完成回调
-(void)getVPNPermission:(YDManagerCompletion)completion;

/// mmdb 数据库
@property (nonatomic, strong, readonly, class, nullable)NSString *mmdb;

/// 代理共享
@property (nonatomic)BOOL shareable;


/// 当前连接状态
@property (nonatomic, readonly)YDVPNStatus status;

/// 当前连接节点
@property (nonatomic, strong, readonly)NSString *connectedURL;

/// 连接 VPN 的时间
@property (nonatomic, strong, readonly)NSDate *connectedDate;

/// 是否全局模式，启动 VPN 或者切换节点前设置有效
@property (nonatomic)BOOL isGlobalMode;

/// 用户名和密码信息
@property (nonatomic, strong)NSArray <NSDictionary *> *passwords;

/// 开始连接
/// - Parameter url: 节点 URL
-(void)connect:(NSString *)url;

/// 断开连接
-(void)disconnect;

/// 获取当前自定义 DNS
-(NSArray <NSString *> *)GetDNS;

/// 向扩展进程发送活跃检查，DEBU 时使用
-(void)echo;

-(NSString *)save:(NSString *)json;

-(NSString *)saveGlobalConfiguration:(NSString *)json;

@property (nonatomic, copy, readonly)NSString *logDir;


@end

// 下面节点是在扩展进程中调用的接口
@interface WSParserManager (Extension)

/// 扩展进程调用，主进程不要调
/// - Parameter ips: url 列表
/// - Parameter type: 0 ICMP, 1 TCP
-(void)ping:(NSArray *)ips type:(int)type;

/// 扩展进程调用，主进程不要调
-(void)setupExtenstionApplication;
@end


NS_ASSUME_NONNULL_END
