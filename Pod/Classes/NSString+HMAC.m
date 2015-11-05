//
//  NSString+HMAC.m
//  pushbox-sdk-ios
//
//  Created by Gert Lavsen on 03/11/15.
//  Copyright © 2015 House of Code. All rights reserved.
//

#import "NSString+HMAC.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (HMAC)
-(NSString *)hmacSha1WithSecret:(NSString *)secret
{
    const char *key = [secret cStringUsingEncoding:NSUTF8StringEncoding];
    const char *data = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, key, strlen(key), data, strlen(data), cHMAC);
    NSData *resultData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    char *utf8;
    utf8 = (char *)[resultData bytes];
    NSMutableString *hex = [NSMutableString string];
    while ( *utf8 )
    {
        [hex appendFormat:@"%02X" , *utf8++ & 0x00FF];
    }
    return [NSString stringWithFormat:@"%@", hex];
}
@end
