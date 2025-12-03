//
//  YDVPNManager.m
//  VPNExtension
//
//  Created by helloc on 2023/1/15.
//  Copyright © 2023 RongVP. All rights reserved.
//

#import "WSParserManager.h"
#import <CommonCrypto/CommonCrypto.h>
#import "WSParser.h"
#import <resolv.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <sys/utsname.h>
#import <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <netinet/in.h>

static NSString *__apple_vpn_server_address__ = @"com.helloc.vpn.x.work";
static NSString *__apple_vpn_localized_description__ = @"Z Proxy";
static NSString *__apple_ground_container_identifier__ = @"group.net.hello.x.ios";

typedef void(^YHSetupCompletion)(NETunnelProviderManager *manager);

@interface WSParserManager ()

@end

@interface WSParserManager ()
@property (nonatomic)BOOL isExtension;
@property (nonatomic)NSInteger notifier;
@property (nonatomic, strong)NSMutableDictionary *info;
@end


@implementation WSParserManager
{
    NETunnelProviderManager *_providerManager;
    NSTimer *_durationTimer;
    NSTimer *_pingTimer;
    NSMutableArray *_dns;
    dispatch_queue_t _worker;
    NSURL *_containerURL;
    NSURL *_workingURL;
    NSURL *_cacheURL;
    
    NSMutableDictionary *_callbackInvoked;
    
}
+(instancetype)sharedManager{
    static WSParserManager *__manager__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager__ = [[self alloc] init];
        [__manager__ configure];
    });
    return __manager__;
}

-(NSURL *)workingDir {
    return _workingURL;
}


-(NSURL *)cacheDir {
    return _cacheURL;
}

-(NSURL *)getDefaultURL {
    NSURL *url = [NSURL URLWithString:@"https://gz-z.s3.ap-southeast-1.amazonaws.com/GeoLite2-Country.mmdb"];
    return url;
}

+(NSString *)mmdb {
    NSURL *url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:__apple_ground_container_identifier__];
    url = [url URLByAppendingPathComponent:@"Library/mmdb"];
    NSString *dest = [NSString stringWithFormat:@"%@/country.mmdb", url.path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dest]) {
        return dest;
    }
    return nil;
}


+(void)setVPNServerAddress:(NSString *)address {
    __apple_vpn_server_address__ = address;
}

+(void)setVPNLocalizedDescription:(NSString *)description {
    __apple_vpn_localized_description__ = description;
}

+(void)setGroupID:(NSString *)groupId {
    __apple_ground_container_identifier__ = groupId;
}

-(void)deleteDnsServer:(NSString *)dns {
    [_dns removeObject:dns];
    [_userDefaults setObject:_dns forKey:@"dns"];
    [_userDefaults synchronize];
}


-(void)addDnsServer:(NSString *)dns {
    [_dns addObject:dns];
    [_userDefaults setObject:_dns forKey:@"dns"];
    [_userDefaults synchronize];
}

-(NSArray <NSString *> *)GetDNS {
    return [_dns copy];
}

-(void)configure {
    _dns = [@[@"8.8.4.4", @"8.8.8.8"] mutableCopy];
    _passwords = @[];
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__apple_ground_container_identifier__];
    NSArray *dns = [_userDefaults objectForKey:@"dns"];
    if (dns) {
        _dns = [dns mutableCopy];
        [_userDefaults setObject:dns forKey:@"dns"];
    }
    _callbackInvoked = @{}.mutableCopy;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatusDidChangeNotification:) name:NEVPNStatusDidChangeNotification object:nil];
    [_userDefaults addObserver:self forKeyPath:@"notifier" options:(NSKeyValueObservingOptionNew) context:nil];
    _worker = dispatch_queue_create("com.helloc.pinger.queue", DISPATCH_QUEUE_CONCURRENT);
    
    _containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:__apple_ground_container_identifier__];
    
    _containerURL = [_containerURL URLByAppendingPathComponent:@"Library" isDirectory:true];
    _cacheURL = [_containerURL URLByAppendingPathComponent:@"Caches" isDirectory:true];
    _workingURL = [_cacheURL URLByAppendingPathComponent:@"Working" isDirectory:true];
    [[NSFileManager defaultManager] createDirectoryAtURL:_workingURL withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    NSDictionary <NSString *, NSNumber *>*vinfo = [_userDefaults objectForKey:@"vinfo"];
//    if (_rsp) {
//        [vinfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
//            if (_callbackInvoked[key]) {
//                return;
//            }
//            _callbackInvoked[key] = @(true);
//            _rsp(key, obj.intValue);
//        }];
//    }
}

-(NSURL *)sharedDir {
    return _containerURL;
}

-(NSString *)saveGlobalConfiguration:(NSString *)json {
    NSMutableDictionary *proxy = [[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    if (!proxy) {
        return nil;
    }
    [_userDefaults setObject:json forKey:@"kApplicationConfiguration"];
    return json;
}

-(NSString *)save:(NSString *)json {
    
    NSMutableDictionary *proxy = [[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    NSString *type = [NSString stringWithFormat:@"%@", proxy[@"type"]];
    if ([type isEqualToString:@"shadowsocks"]) {
        if (proxy[@"uot"]) {
            proxy[@"udp_over_tcp"] = proxy[@"uot"];
        }
        else {
            proxy[@"udp_over_tcp"] = [NSNumber numberWithBool:true];
        }
    }
    NSString *ai = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:self.isGlobalMode ? @"global":@"ai" withExtension:@"json"] encoding:NSUTF8StringEncoding error:nil];
    if (ai.length == 0) {
        return @"";
    }
    NSData *aiBody = [ai dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *configuration = [[NSJSONSerialization JSONObjectWithData:aiBody options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    NSMutableArray *outbounds = [configuration[@"outbounds"] mutableCopy];
    
    outbounds[0] = proxy;
    configuration[@"outbounds"] = outbounds;
    
    NSData *cfgData = [NSJSONSerialization dataWithJSONObject:configuration options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonx = [[NSString alloc] initWithData:cfgData encoding:NSUTF8StringEncoding];
    [_userDefaults setObject:jsonx forKey:@"kApplicationConfiguration"];
    return jsonx;
}

-(NSString *)saveForWebView:(NSString *)json {
    
    NSMutableDictionary *proxy = [[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    BOOL isGlobalMode = self.isGlobalMode;
    NSString *type = [NSString stringWithFormat:@"%@", proxy[@"type"]];
    if ([type isEqualToString:@"shadowsocks"]) {
        if (proxy[@"uot"]) {
            proxy[@"udp_over_tcp"] = proxy[@"uot"];
        }
        else {
            proxy[@"udp_over_tcp"] = [NSNumber numberWithBool:true];
        }
    }
    
    NSString *ai = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:isGlobalMode ? @"global_webview":@"ai_webview" withExtension:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSData *aiBody = [ai dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *configuration = [[NSJSONSerialization JSONObjectWithData:aiBody options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    
    NSMutableArray *outbounds = [configuration[@"outbounds"] mutableCopy];
    
    outbounds[0] = proxy;
    configuration[@"outbounds"] = outbounds;
    
    NSData *cfgData = [NSJSONSerialization dataWithJSONObject:configuration options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonx = [[NSString alloc] initWithData:cfgData encoding:NSUTF8StringEncoding];
    [_userDefaults setObject:jsonx forKey:@"kApplicationConfiguration"];
    return jsonx;
}

-(void)setupVPNManager:(YHSetupCompletion)completion {
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if (managers.count == 0) {
            [self createVPNConfiguration:completion];
            if (error) {
                NSLog(@"loadAllFromPreferencesWithCompletionHandler: %@", error);
            }
            return;
        }
        [self handlePreferences:managers completion:completion];
    }];
    
}

-(void)getVPNPermission:(YDManagerCompletion)completion {
    if (_providerManager) {
        return completion(true);
    }
    [self setupVPNManager:^(NETunnelProviderManager *manager) {
        completion(manager != nil);
    }];
}

-(void)setupVPNManager {
    [self setupVPNManager:^(NETunnelProviderManager *manager) { [self setupConnection:manager]; }];
}

-(void)setupConnection:(NETunnelProviderManager *)manager {
    _providerManager = manager;
    NEVPNConnection *connection = manager.connection;
    if (connection.status == NEVPNStatusConnected) {
        _status = YDVPNStatusConnected;
        NETunnelProviderProtocol *protocolConfiguration = (NETunnelProviderProtocol *)_providerManager.protocolConfiguration;
        NSDictionary *copy = protocolConfiguration.providerConfiguration;
        NSDictionary *configuration = copy[@"configuration"];
        _connectedURL = configuration[@"uri"];
        _connectedDate = [_userDefaults objectForKey:@"connectedDate"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kApplicationVPNStatusDidChangeNotification" object:nil];
    }
}

-(void)setupExtenstionApplication {
    _isExtension = YES;
    _info = [NSMutableDictionary new];
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__apple_ground_container_identifier__];
    [_userDefaults setObject:NSDate.date forKey:@"connectedDate"];
    
    _containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:__apple_ground_container_identifier__];
    NSURL *lib = [_containerURL URLByAppendingPathComponent:@"Library" isDirectory:true];
    _cacheURL = [lib URLByAppendingPathComponent:@"Caches" isDirectory:true];
    _workingURL = [_cacheURL URLByAppendingPathComponent:@"Working" isDirectory:true];
    [[NSFileManager defaultManager] createDirectoryAtURL:_workingURL withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)reenableManager:(YHSetupCompletion)complection {
    if (_providerManager) {
        if(_providerManager.enabled == NO) {
            NSLog(@"providerManager is disabled, so reenable");
            _providerManager.enabled = YES;
            [_providerManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"saveToPreferencesWithCompletionHandler:%@", error);
                }
            }];
        }
        complection(_providerManager);
    }
    else {
        [self setupVPNManager:^(NETunnelProviderManager *manager) {
            [self setupConnection:manager];
            complection(manager);
        }];
    }
}

-(void)connect:(NSString *)url {
    NSAssert(url.length > 0, @"url can not empty");
    _connectedURL = url;
    [self reenableManager:^(NETunnelProviderManager *manager) {
        if (!manager){
            return;
        }
        [self connectInternal:0 open:YES];
    }];

}

-(void)setIsGlobalMode:(BOOL)isGlobalMode {
    if (_isGlobalMode == isGlobalMode) return;
    _isGlobalMode = isGlobalMode;
    if (self.status != YDVPNStatusConnected) return;
    [self reenableManager:^(NETunnelProviderManager *manager) {
        if (!manager){
            return;
        }
        [self connectInternal:5 open:NO];
    }];
}
-(void)changeURL:(NSString *)uri {
    [self changeURL:uri force:NO];
}

-(void)setShareable:(BOOL)shareable {
    _shareable = shareable;
    if (_connectedURL == nil) {
        return;
    }
    if (self.status != YDVPNStatusConnected) {
        return;
    }
    [self reenableManager:^(NETunnelProviderManager *manager) {
        if (!manager){
            return;
        }
        [self connectInternal:7 open:NO];
    }];
}

-(void)changeURL:(NSString *)uri force:(BOOL)force{
    if ([uri isEqualToString:_connectedURL] && force == NO) {
        return;
    }
    if (self.status != YDVPNStatusConnected) {
        return;
    }
    [self reenableManager:^(NETunnelProviderManager *manager) {
        if (!manager){
            return;
        }
        self->_connectedURL = uri;
        [self connectInternal:2 open:NO];
    }];
}

-(NSString *)logDir {
    return [_workingURL URLByAppendingPathComponent:@"box.log"].path;
}

-(void)connectInternal:(NSInteger)action open:(BOOL)open{
    NSString *uri = _connectedURL;
    NETunnelProviderSession *connection = (NETunnelProviderSession *)_providerManager.connection;
    NSMutableDictionary *providerConfiguration = @{@"type":@(action), @"uri":uri, @"global":@(self.isGlobalMode)}.mutableCopy;
    NETunnelProviderProtocol *protocolConfiguration = (NETunnelProviderProtocol *)_providerManager.protocolConfiguration;
    NSMutableDictionary *copy = protocolConfiguration.providerConfiguration.mutableCopy;
    copy[@"configuration"] = providerConfiguration;
    NSLog(@"Connect using: %@", providerConfiguration);
    protocolConfiguration.providerConfiguration = copy;
    [_providerManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"saveToPreferencesWithCompletionHandler:%@", error);
        }
    }];
    NSError *error = nil;
    if (open) {
        [connection startVPNTunnelWithOptions:providerConfiguration andReturnError:&error];
    }
    else {
        [connection sendProviderMessage:[NSJSONSerialization dataWithJSONObject:providerConfiguration options:(NSJSONWritingPrettyPrinted) error:nil] returnError:&error responseHandler:^(NSData * _Nullable responseData) {
            NSString *x = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"sendProviderMessage=>%@", x);
        }];
    }
    if (error) {
        NSLog(@"VPN extension return error:%@, open:%d", error, open);
    }
}

-(void)disconnect {
    _status = YDVPNStatusDisconnecting;
    NETunnelProviderSession *session = (NETunnelProviderSession *)_providerManager.connection;
    [session stopVPNTunnel];
    NSLog(@"disconnect");
}

-(void)connectionStatusDidChangeNotification:(NSNotification *)notification {
    NEVPNConnection *connection = _providerManager.connection;
    switch (connection.status) {
        case NEVPNStatusInvalid:
            _status = YDVPNStatusDisconnected;
            break;
            
        case NEVPNStatusConnected:{
            _status = YDVPNStatusConnected;
            _connectedDate = NSDate.date;
        }
            break;
            
        case NEVPNStatusConnecting: {
            _status = YDVPNStatusConnecting;
        }
            break;
            
        case NEVPNStatusDisconnected:{
            _status = YDVPNStatusDisconnected;
        }
            break;
            
        case NEVPNStatusReasserting:{
            _status = YDVPNStatusDisconnected;
        }
            break;
        case NEVPNStatusDisconnecting: {
            _status = YDVPNStatusDisconnecting;
        }
            break;
            
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kApplicationVPNStatusDidChangeNotification" object:nil];
}

- (void)handlePreferences:(NSArray<NETunnelProviderManager *> * _Nullable)managers completion:(YDProviderManagerCompletion)completion{
    NETunnelProviderManager *manager;
    for (NETunnelProviderManager *item in managers) {
        if ([item.localizedDescription isEqualToString:__apple_vpn_localized_description__]) {
            manager = item;
            break;
        }
    }
    if (manager.enabled == NO) {
        manager.enabled = YES;
        [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            completion(manager);
        }];
    }
    else {
        completion(manager);
    }
}

- (void)createVPNConfiguration:(YDProviderManagerCompletion)completion {
        
    NETunnelProviderManager *manager = [NETunnelProviderManager new];
    NETunnelProviderProtocol *protocolConfiguration = [NETunnelProviderProtocol new];
    
    protocolConfiguration.serverAddress = __apple_vpn_server_address__;
    
    // providerConfiguration 可以自定义进行存储
    protocolConfiguration.providerConfiguration = @{};
    manager.protocolConfiguration = protocolConfiguration;

    manager.localizedDescription = __apple_vpn_localized_description__;
    manager.enabled = YES;
    [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"saveToPreferencesWithCompletionHandler:%@", error);
            completion(nil);
            return;
        }
        [manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"loadFromPreferencesWithCompletionHandler:%@", error);
                completion(nil);
            }
            else {
                completion(manager);
            }
        }];
    }];
}

-(void)echo {
    NETunnelProviderSession *connection = (NETunnelProviderSession *)_providerManager.connection;
    if (!connection) return;
    NSDictionary *echo = @{@"type":@1};
    NSError *error;
    [connection sendProviderMessage:[NSJSONSerialization dataWithJSONObject:echo options:(NSJSONWritingPrettyPrinted) error:nil] returnError:&error responseHandler:^(NSData * _Nullable responseData) {
        NSString *x = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", x);
    }];
    if (error) {
        NSLog(@"echo sendProviderMessage: %@", error);
    }
}
@end
