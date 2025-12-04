//
//  WSXProtocolParser.m
//  xVPN
//
//  Created by LinkV on 2022/11/1.
//

#import "WSParser.h"

@implementation WSParser

+(nullable NSDictionary *)parse:(NSString *)uri protocol:(nonnull NSString *)protocol{
    return [self parse:[NSString stringWithFormat:@"%@://%@", protocol, uri]];
}

+(nullable NSDictionary *)parse:(NSString *)uri {
    NSData *p = [uri dataUsingEncoding:NSUTF8StringEncoding];
    if (!p) {
        return nil;
    }
    NSDictionary *js = [NSJSONSerialization JSONObjectWithData:p options:NSJSONReadingMutableContainers error:nil];
    if (js) {
        uri = [self changeToURL:js];
    }
    NSURL *url = [NSURL URLWithString:uri];
    if (url.scheme.length == 0) {
        return nil;
    }
    NSArray *nodes = [uri componentsSeparatedByString:@"#"];
    NSString *remark = nodes.count >= 2 ? nodes.lastObject : url.scheme;
    
    NSString *username = url.user;
    NSString *password = url.password;
    NSMutableDictionary *body = @{}.mutableCopy;
    
    if (!username && !password && !url.port && url.host) {
        if (url.host) {
            NSString *info = [WSBase64 decode:url.host];
            // 先判断一下此处是否是一个 JSON，如果是则按 JSON 方式进行解析
            NSData *jsonBytes = [info dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonBytes options:NSJSONReadingMutableContainers error:nil];
            if (json) {
                body[@"xx"] = url.scheme;
                if (json[@"add"]) {
                    body[@"address"] = json[@"add"];
                }
                if (json[@"port"]) {
                    body[@"port"] = @([json[@"port"] integerValue]);
                }
                if (json[@"ps"]) {
                    body[@"remark"] = json[@"ps"];
                }
                if (json[@"id"]) {
                    body[@"username"] = json[@"id"];
                }
                NSString *remark = body[@"remark"];
                remark = [remark stringByRemovingPercentEncoding];
                body[@"remark"] = remark ? remark : url.scheme;
                [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    body[key] = obj;
                }];
                if (body[@"address"] && body[@"port"] && body[@"username"]) {
                    return body;
                }
                return nil;
            }
            NSMutableCharacterSet *set = [NSMutableCharacterSet new];
            [set formUnionWithCharacterSet:NSCharacterSet.alphanumericCharacterSet];
            [set addCharactersInString:@"-:._~@"];
            info = [info stringByAddingPercentEncodingWithAllowedCharacters:set];
            if (info) {
                info = [url.scheme stringByAppendingFormat:@"://%@", info];
            }
            if (url.fragment) {
                info = [info stringByAppendingFormat:@"#%@", url.fragment];
            }
            url = [NSURL URLWithString:info];
        }
    }
    NSArray <NSString *>*parameters = [url.query componentsSeparatedByString:@"&"];
    username = url.user;
    password = url.password;
    
    if (password == nil && username != nil) {
        NSArray <NSString *>*up = [[WSBase64 decode:username] componentsSeparatedByString:@":"];
        if (up.count == 2) {
            username = up[0];
            password = up[1];
        }
        else if (up.count == 1 && up[0].length > 0) {
            username = up[0];
        }
        username = [username stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        password = [password stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    if (password) {
        password = [password stringByRemovingPercentEncoding];
        body[@"password"] = password;
    }
    if (username) {
        username = [username stringByRemovingPercentEncoding];
        body[@"username"] = username;
    }
    if (url.port) {
        body[@"port"] = url.port;
    }
    if (url.host) {
        body[@"address"] = url.host;
    }
    if (url.scheme) {
        body[@"xx"] = url.scheme;
    }
    remark = [remark stringByRemovingPercentEncoding];
    body[@"remark"] = remark ? remark : url.scheme;
    [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray <NSString *>*t = [obj componentsSeparatedByString:@"="];
        if (t.count == 2) {
            body[t[0]] = [t[1] stringByRemovingPercentEncoding];
        }
    }];
    return body;
}

@end

@implementation WSBase64
+(NSString *)decode:(NSString *)base64EncodedString {
    NSInteger pp = base64EncodedString.length % 4;
    if (pp == 3) {
        base64EncodedString = [base64EncodedString stringByAppendingString:@"="];
    }
    else if (pp == 2) {
        base64EncodedString = [base64EncodedString stringByAppendingString:@"=="];
    }
    else if (pp == 1) {
        base64EncodedString = [base64EncodedString stringByAppendingString:@"==="];
    }
    NSData *payload = [[NSData alloc] initWithBase64EncodedString:base64EncodedString options:0];
    NSString *prefix = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
    return prefix;
}


+ (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth raw:(NSData *)raw
{
    if (![raw length]) return nil;
    
    NSString *encoded = nil;
    {
        switch (wrapWidth)
        {
            case 64:
            {
                return [raw base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            }
            case 76:
            {
                return [raw base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
            }
            default:
            {
                encoded = [raw base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
            }
        }
    }
    
    if (!wrapWidth || wrapWidth >= [encoded length])
    {
        return encoded;
    }
    
    wrapWidth = (wrapWidth / 4) * 4;
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [encoded length]; i+= wrapWidth)
    {
        if (i + wrapWidth >= [encoded length])
        {
            [result appendString:[encoded substringFromIndex:i]];
            break;
        }
        [result appendString:[encoded substringWithRange:NSMakeRange(i, wrapWidth)]];
        [result appendString:@"\r\n"];
    }
    
    return result;
}

+(NSString *)encode:(NSString *)raw {
    
    NSData *data = [raw dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [self base64EncodedStringWithWrapWidth:0 raw:data];
    
}
@end
