//
//  NSString+HMAC.h
//  pushbox-sdk-ios
//
//  Created by Gert Lavsen on 03/11/15.
//  Copyright © 2015 House of Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(HMAC)
-(NSString *)hmacSha1WithSecret:(NSString *)secret;
@end
