//
//  HoCPushMessage.h
//  
//
//  Created by Gert Lavsen on 08/11/15.
//
//

#import <Foundation/Foundation.h>

@interface HoCPushMessage : NSObject<NSCoding>
@property (nonatomic, assign) NSInteger pushId; // id
@property (nonatomic, strong) NSString *title; // title
@property (nonatomic, strong) NSString *message; // message
@property (nonatomic, strong) NSDate *interactionDate; // read_datetime
@property (nonatomic, strong) NSDate *handledDate; // handled_time
@property (nonatomic, strong) NSDate *expirationDate; // expiration_datatime
@property (nonatomic, strong) NSDate *receiveDate; // deliver_datetime
@property (nonatomic, strong) id<NSCoding> payload; // payload

- (id) initWithJson:(NSDictionary *) json;
@end
