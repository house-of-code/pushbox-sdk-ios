//
//  HoCPushMessage.m
//  
//
//  Created by Gert Lavsen on 08/11/15.
//
//

#import "HoCPushMessage.h"

NSString * const HoCPushMessageTitleKey = @"push.message.title";
NSString * const HoCPushMessageMessageKey = @"push.message.message";
NSString * const HoCPushMessageReceivedDateKey = @"push.message.date.received";
NSString * const HoCPushMessageExpirationDateKey = @"push.message.date.expiration";
NSString * const HoCPushMessageInteractionDateKey = @"push.message.date.interacted";
NSString * const HoCPushMessagePayloadKey = @"push.message.payload";
NSString * const HoCPushMessagePushIdKey = @"push.message.push.id";

NSString * const HoCPushJsonKeyDeliverDateTime = @"deliver_datetime";
NSString * const HoCPushJsonKeyExpirationDate = @"expiration_date";
NSString * const HoCPushJsonKeyMessageId = @"id";
NSString * const HoCPushJsonKeyMessage = @"message";
NSString * const HoCPushJsonKeyPayload = @"payload";
NSString * const HoCPushJsonKeyReadDateTime = @"read_datetime";
NSString * const HoCPushJsonKeyTitle = @"title";

@implementation HoCPushMessage


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:HoCPushMessageTitleKey];
    [coder encodeObject:self.message forKey:HoCPushMessageMessageKey];
    [coder encodeObject:self.receiveDate forKey:HoCPushMessageReceivedDateKey];
    [coder encodeObject:self.interactionDate forKey:HoCPushMessageInteractionDateKey];
    [coder encodeObject:self.payload forKey:HoCPushMessagePayloadKey];
    [coder encodeInteger:self.pushId forKey:HoCPushMessagePushIdKey];
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self)
    {
        self.title = [coder decodeObjectForKey:HoCPushMessageTitleKey];
        self.message = [coder decodeObjectForKey:HoCPushMessageMessageKey];
        self.receiveDate = [coder decodeObjectForKey:HoCPushMessageReceivedDateKey];
        self.interactionDate = [coder decodeObjectForKey:HoCPushMessageInteractionDateKey];
        self.payload = [coder decodeObjectForKey:HoCPushMessagePayloadKey];
        self.pushId = [coder decodeIntegerForKey:HoCPushMessagePushIdKey];
    }
    return self;
}

- (id) initWithJson:(NSDictionary *) json
{
    self = [self init];
    if (self)
    {
        self.title = [json valueForKey:HoCPushJsonKeyTitle];
        if ([self.title isKindOfClass:[NSNull class]])
        {
            self.title = nil;
        }
        self.message = [json valueForKey:HoCPushJsonKeyMessage];
        if ([self.message isKindOfClass:[NSNull class]])
        {
            self.message = nil;
        }

        self.payload = [json valueForKey:HoCPushJsonKeyPayload];
        
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm.ss.SSSZZZZ"];
        NSString *date = [json valueForKey:HoCPushJsonKeyReadDateTime];
        if ([date isKindOfClass:[NSNull class]])
        {
            date = nil;
        }
        self.interactionDate = [df dateFromString:date];
        date = [json valueForKey:HoCPushJsonKeyExpirationDate];
        if ([date isKindOfClass:[NSNull class]])
        {
            date = nil;
        }
        self.expirationDate = [df dateFromString:date];
        date = [json valueForKey:HoCPushJsonKeyDeliverDateTime];
        if ([date isKindOfClass:[NSNull class]])
        {
            date = nil;
        }
        self.receiveDate = [df dateFromString:date];
        
        self.pushId = [[json valueForKey:HoCPushJsonKeyMessageId] integerValue];
        
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%ld:'%@'. Recived: %@. Interaction date: %@. Expiration date: %@. Message: '%@'. Payload: %@",
            (long)self.pushId,
            self.title,
            self.receiveDate,
            self.interactionDate,
            self.expirationDate,
            self.message,
            self.payload];
}

@end
