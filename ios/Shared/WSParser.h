//
//  WSXProtocolParser.h
//  xVPN
//
//  Created by LinkV on 2022/11/1.
//

#import <Foundation/Foundation.h>


@interface WSBase64 : NSObject
+(NSString *)decode:(NSString *)base64EncodedString;
+(NSString *)encode:(NSString *)raw;
@end

typedef enum : NSUInteger {
    WSXProtocolUnknown = 0,
    WSXProtocolVmess,
    WSXProtocolVless,
    WSXProtocolSocks,
    WSXProtocolHttp
} WSXProtocol;


NS_ASSUME_NONNULL_BEGIN

@interface WSParser : NSObject

+(nullable NSDictionary *)parse:(NSString *)uri protocol:(NSString *)protocol;

+(nullable NSDictionary *)parse:(NSString *)url;

+(nullable NSArray<NSDictionary *> *)parseJSON:(NSString *)json;

+(nullable NSString *)changeToURL:(NSDictionary *)xray;
@end

NS_ASSUME_NONNULL_END
