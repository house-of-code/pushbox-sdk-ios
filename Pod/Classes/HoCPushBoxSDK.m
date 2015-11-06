//
//  HoCPushBoxSDK.m
//  HoCPushBox-sdk-ios
//
//  Created by Gert Lavsen on 03/11/15.
//  Copyright © 2015 House of Code. All rights reserved.
//

#import "HoCPushBoxSDK.h"
#import "HoCPushBoxReachability.h"
#import "NSString+HMAC.h"


#pragma mark - string constants
#pragma mark notifcations
NSString * const HoCPushBoxSDKNotificationSuccess = @"HoCPushBoxSDK.successfull.note";
NSString * const HoCPushBoxSDKNotificationFailure = @"HoCPushBoxSDK.successfull.note";
NSString * const HoCPushBoxSDKNotificationFailureReasonKey = @"HoCPushBoxSDK.successfull.note.reason.key";
NSString * const HoCPushBoxSDKNotificationFailureCodeKey = @"HoCPushBoxSDK.successfull.note.code.key";
#pragma mark urls
NSString * const HoCPushBoxSDKApiUrl = @"https://api.pushboxsdk.com/v1/";
NSString * const HoCPushBoxSDKHost = @"api.pushboxsdk.com";
#pragma mark JSON keys
NSString * const HoCPushBoxSDKJSONKeyHMAC = @"hmac";
NSString * const HoCPushBoxSDKJSONKeyTS = @"ts";
NSString * const HoCPushBoxSDKJSONKeyApiKey = @"app_key";
NSString * const HoCPushBoxSDKJSONKeyToken = @"token";
NSString * const HoCPushBoxSDKJSONKeyUid = @"uid";
NSString * const HoCPushBoxSDKJSONKeyProfileId = @"profile_identifier";
NSString * const HoCPushBoxSDKJSONKeyPlatform = @"platform";
NSString * const HoCPushBoxSDKJSONKeyOccurenceTimestamp = @"timestamp";
NSString * const HoCPushBoxSDKJSONKeyAge = @"age";
NSString * const HoCPushBoxSDKJSONKeyBirthday = @"birthday";
NSString * const HoCPushBoxSDKJSONKeyGender = @"gender";
NSString * const HoCPushBoxSDKJSONKeyEvent = @"event";
NSString * const HoCPushBoxSDKJSONKeyChannels = @"channels";
NSString * const HoCPushBoxSDKJSONKeyLocationLatitude = @"latitude";
NSString * const HoCPushBoxSDKJSONKeyLocationLongitude = @"longitude";
NSString * const HoCPushBoxSDKJSONKeySuccess = @"success";
NSString * const HoCPushBoxSDKJSONKeyMessage = @"message";

#pragma mark api methods
NSString * const HoCPushBoxSDKMethodSetToken = @"set_token";
NSString * const HoCPushBoxSDKMethodSetAge = @"set_age";
NSString * const HoCPushBoxSDKMethodSetBirthday = @"set_birthday";
NSString * const HoCPushBoxSDKMethodLogEvent = @"log_event";
NSString * const HoCPushBoxSDKMethodLogLocation = @"log_location";
NSString * const HoCPushBoxSDKMethodSetGender = @"set_gender";
NSString * const HoCPushBoxSDKMethodSetChannels = @"set_channels";

#pragma mark JSON values
NSString * const HoCPushBoxSDKJSONValuePlatform = @"iOS";

#pragma mark user defaults
NSString * const HoCPushBoxSDKSuitName = @"HoCPushBoxSDK.suit.name";

#pragma mark User defaults keys
NSString * const HoCPushBoxSDKDefaultsUid = @"uid";
NSString * const HoCPushBoxSDKDefaultsQueue = @"queue";
NSString * const HoCPushBoxSDKDefaultsKeyMethod = @"method";
NSString * const HoCPushBoxSDKDefaultsKeyDict = @"dict";


#pragma mark - static variables
/** Holds the Api key */
static NSString *API_KEY;
/** Holds the Api secret */
static NSString *API_SECRET;


#pragma mark - properties definition
@interface HoCPushBoxSDK ()

#pragma mark profile identifier
@property (nonatomic, strong) NSString *profileIdentifier;

#pragma mark user defaults used internally in the sdk
@property (nonatomic, strong) NSUserDefaults *sdkDefaults;

#pragma mark boolean properties for queue
@property (nonatomic, readonly, getter = isReady) BOOL ready;
@property (nonatomic, assign, getter=isTokenSend) BOOL tokenSend;
@property (atomic, assign, getter = isWorking) BOOL working;
@property (nonatomic, readonly, getter= isInitialized) BOOL initialized;

#pragma mark default dictionary
@property (nonatomic, readonly) NSMutableDictionary *defaultDictionary;

#pragma mark device token and uid properties
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *uid;

#pragma mark reachability client
@property (nonatomic, strong) HoCPushBoxReachability *netStatus;

#pragma mark timestamp
@property (nonatomic, readonly) long timestamp;

@end

@implementation HoCPushBoxSDK
@synthesize uid = _uid;

#pragma mark - initialization
- (id) init
{
    self = [super init];
    if (self)
    {
        self.netStatus = [HoCPushBoxReachability reachabilityWithHostName:HoCPushBoxSDKHost];
        [self.netStatus startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:HoCPushBoxReachabilityChangedNotification object:nil];

    }
    return self;
}

#pragma singleton instance
+ (instancetype) sharedInstance
{
    assert(API_KEY != nil);
    assert(API_SECRET != nil);
    
    static HoCPushBoxSDK *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[HoCPushBoxSDK alloc] init];
                  });
    return sharedInstance;
}


#pragma mark - sdk setup

+ (void) setApiKey:(NSString *)apiKey andSecret:(NSString *)secret
{
    API_KEY = apiKey;
    API_SECRET = secret;
}

#pragma mark - set profile identifier
- (void) setProfileIdentifier:(NSString *)profileIdentifier
{
    self.profileIdentifier = profileIdentifier;
}

#pragma mark - handle device token

- (void) setDeviceToken:(NSData *)deviceToken
{
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    for (int i = 0; i < [deviceToken length]; i++)
    {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    self.token = token;
}


#pragma mark - send data

#pragma mark set age
- (void) setAge:(NSInteger) age
{
    NSMutableDictionary *dict = self.defaultDictionary;
    [dict setObject:[NSNumber numberWithInteger:age] forKey:HoCPushBoxSDKJSONKeyAge];
    [self addDictionary:dict toQueueForMethod:HoCPushBoxSDKMethodSetAge];
    
}

#pragma mark set birthday
- (void) setBirthday:(NSDate *) birthday
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *date = [formatter stringFromDate:birthday];
    NSMutableDictionary *dict = self.defaultDictionary;
    [dict setObject:date forKey:HoCPushBoxSDKJSONKeyBirthday];
    [self addDictionary:dict toQueueForMethod:HoCPushBoxSDKMethodSetBirthday];
}

#pragma mark set gender
- (void) setGender:(HoCPushBoxGenderType) gender
{
    NSMutableDictionary *dict = self.defaultDictionary;
    
    [dict setObject:[NSNumber numberWithInteger:gender] forKey:HoCPushBoxSDKJSONKeyGender];
    [self addDictionary:dict toQueueForMethod:HoCPushBoxSDKMethodSetGender];
}

#pragma mark log event
- (void) logEvent:(NSString *) event
{
    NSMutableDictionary *dict = self.defaultDictionary;
    [dict setObject:event forKey:HoCPushBoxSDKJSONKeyEvent];
    [self addDictionary:dict toQueueForMethod:HoCPushBoxSDKMethodLogEvent];
}

#pragma mark log location
- (void) logLocationWithLatitude:(double) latitude longitude:(double) longitude
{
    NSMutableDictionary *dict = self.defaultDictionary;
    [dict setObject:[NSNumber numberWithDouble:latitude] forKey:HoCPushBoxSDKJSONKeyLocationLatitude];
    [dict setObject:[NSNumber numberWithDouble:longitude] forKey:HoCPushBoxSDKJSONKeyLocationLongitude];
    [self addDictionary:dict toQueueForMethod:HoCPushBoxSDKMethodLogLocation];
}

#pragma mark set channels
- (void) setChannels:(NSArray *) channels
{
    for (id channel in channels)
    {
        // Check the class of the individual channels
        assert([channel isKindOfClass:[NSString class]]);
    }
    
    NSMutableDictionary *dict = self.defaultDictionary;
    [dict setObject:channels forKey:HoCPushBoxSDKJSONKeyChannels];
    [self addDictionary:dict toQueueForMethod:HoCPushBoxSDKMethodSetChannels];
}

#pragma mark - push opens etc

- (void) handleRemoteNotification:(NSDictionary*)userInfo
{
  // TODO
}

- (void) handleLaunchingWithOptions:(NSDictionary*)launchOptions
{
  // TODO
}

- (void) registerPayloadHandler:(void (^)(id payload))payloadHandler
{
  // TODO
}

#pragma mark - stored messages

- (NSArray*) storedMessages
{
  // TODO
  return [NSArray new]; 
}

#pragma mark - private properties

#pragma mark uid - get stored uid
- (NSString *) uid
{
    if (!_uid)
    {
        _uid = [self.sdkDefaults valueForKey:HoCPushBoxSDKDefaultsUid];
    }
    return _uid;
}

#pragma mark uid - store uid
- (void) setUid:(NSString *) uid
{
    _uid = uid;
    [self.sdkDefaults setObject:_uid forKey:HoCPushBoxSDKDefaultsUid];
    [self.sdkDefaults synchronize];
}

#pragma mark set device token as string and takes next job in queue
- (void) setToken:(NSString *)token
{
    _token = token;
    [self takeNext];
}

#pragma mark user defaults
- (NSUserDefaults *) sdkDefaults
{
    if (!_sdkDefaults)
    {
        _sdkDefaults = [[NSUserDefaults alloc] initWithSuiteName:HoCPushBoxSDKSuitName];
    }
    return _sdkDefaults;
}

#pragma mark check that the sdk is initialized
- (BOOL) isInitialized
{
    return (API_SECRET != nil && API_SECRET != nil);
}

#pragma mark check if the sdk is initialized and the token is set and finally if there is a internet connection
- (BOOL) isReady
{
    
    if (!self.isInitialized || !self.token)
    {
        return NO;
    }

    if ([self.netStatus currentReachabilityStatus] == HoCPushBoxNetworkStatusNotReachable)
    {
        return NO;
    }
    return YES;
}

#pragma mark prefilled dictionary for json requests
- (NSMutableDictionary *) defaultDictionary
{
    NSDate *now = [NSDate date];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{HoCPushBoxSDKJSONKeyApiKey : API_KEY, HoCPushBoxSDKJSONKeyPlatform : HoCPushBoxSDKJSONValuePlatform, HoCPushBoxSDKJSONKeyOccurenceTimestamp : [NSNumber numberWithLong:[now timeIntervalSinceNow]]}];
    if (self.profileIdentifier)
    {
        [dict setObject:self.token forKey:HoCPushBoxSDKJSONKeyProfileId];
    }
    return dict;
}

#pragma mark timestamp used for authentication
- (long) timestamp
{
    return (long)[[NSDate date] timeIntervalSince1970];
}


#pragma mark - private selectors

#pragma mark observer selector for reachability
/**
 * Selector called when network status change
 * @param note notification from NSNotificationCenter with the reachability client as object
 **/
- (void) reachabilityChanged:(NSNotification *)note
{
    HoCPushBoxReachability *reachability = [note object];
    HoCPushBoxNetworkStatus status = [reachability currentReachabilityStatus];
    if (status != HoCPushBoxNetworkStatusNotReachable)
    {
        // Net available
        [self takeNext];
    }
}

#pragma mark hmac generation
/**
 * Generates hmac signing for api
 * Uses the current time - as unix time the api key and the secret to generate the hmac
 **/
- (NSString *) hmacForTimestamp:(long) timestamp
{
    return [[[NSString stringWithFormat:@"%@:%ld", API_KEY, timestamp] hmacSha1WithSecret:API_SECRET] lowercaseString];
}


#pragma mark finalizing json dict
/**
 * Finalize a json dictionary before sending it.
 * Adds authentication stuff
 * @param dictionary the json dictionary to finalize
 * @return finalized json dictionary to use in requests
 **/
- (NSDictionary *) finalizeDictionary:(NSDictionary *) dictionary
{
    
    // Authentication stuff
    long timestamp = self.timestamp;
    NSString *hmac = [self hmacForTimestamp:timestamp];
    NSNumber *ts = [NSNumber numberWithLong:timestamp];

    NSMutableDictionary *dict = [dictionary mutableCopy];
    [dict setObject:ts forKey:HoCPushBoxSDKJSONKeyTS];
    [dict setObject:hmac forKey:HoCPushBoxSDKJSONKeyHMAC];
    
    // Adds uid to dictionary
    if (self.uid)
    {
        [dict setObject:self.uid forKey:HoCPushBoxSDKJSONKeyUid];
    }
    
    return dict;
}

#pragma mark error sending
/**
 * Post notification with error message
 * @param code the code to set
 * @param reason the reason to the error
 */
- (void) postErrorNotificationWithCode:(HoCPushBoxErrorCode) code andReason:(NSString *) reason
{
    NSDictionary *dictionary = @{HoCPushBoxSDKNotificationFailureCodeKey : [NSNumber numberWithInteger:code], HoCPushBoxSDKNotificationFailureReasonKey : reason};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HoCPushBoxSDKNotificationFailure object:nil userInfo:dictionary];
}

#pragma mark request creation
/**
 * Generates a request for sending data to a given method
 * @param postData data to send
 * @param method where to send it
 * @return mutable request
 */
- (NSMutableURLRequest *) requestWithPostData:(NSData *) postData andMethod:(NSString *) method
{
    
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", HoCPushBoxSDKApiUrl, method]]];
    NSString *argString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    
    [rq setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[argString length]] forHTTPHeaderField:@"Content-length"];
    [rq setHTTPBody:[argString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [rq setHTTPMethod:@"POST"];
    
    [rq setHTTPBody:postData];
    
    [rq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [rq setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    return rq;
}

#pragma mark - queue part

#pragma mark add job to queue
/**
 * Add a call to the sdk request queue.
 * When added next task in the queue will be selected if the queue is not working and is ready
 * @param dictionary dictionary to send
 * @param method where to send it
 **/
- (void) addDictionary:(NSDictionary *) dictionary toQueueForMethod:(NSString *) method
{
    NSDictionary *dict = @{HoCPushBoxSDKDefaultsKeyMethod : method, HoCPushBoxSDKDefaultsKeyDict : dictionary};
    NSMutableArray *queue = [([self.sdkDefaults arrayForKey:HoCPushBoxSDKDefaultsQueue] ?:@[]) mutableCopy];
    
    [queue addObject:dict];
    
    [self.sdkDefaults setObject:queue forKey:HoCPushBoxSDKDefaultsQueue];
    [self.sdkDefaults synchronize];
    [self takeNext];
}



#pragma mark peeking and popping queue
/**
 * Peeks at the top of the queue
 * @return the element with higest priority from the queue without removing it
 **/
- (NSDictionary *) peekQueue
{
    return [[self.sdkDefaults arrayForKey:HoCPushBoxSDKDefaultsQueue] ?: @[] firstObject];
}

/**
 * Pops the top of the queue
 * @return the element with higest priority from the queue and removes it
 **/
- (NSDictionary *) popQueue
{
    NSMutableArray *queue = [([self.sdkDefaults arrayForKey:HoCPushBoxSDKDefaultsQueue] ?:@[]) mutableCopy];
    NSDictionary *dict = [queue firstObject];
    [queue removeObjectAtIndex:0];
    [self.sdkDefaults setObject:queue forKey:HoCPushBoxSDKDefaultsQueue];
    [self.sdkDefaults synchronize];
    
    return dict;
}


#pragma mark job control
/**
 * Tries to execute at call to the api.
 **/
- (void) takeNext
{
    // Make sure constraints for sending data is met
    if (!self.isReady)
    {
        return;
    }
    // Check lock
    if (self.isWorking)
    {
        return;
    }
    // Lock
    self.working = YES;

    // Check if token is send to the api
    if (!self.isTokenSend)
    {
        // The device token is not send to the api yet - do it before taking any jobs from the queue
        NSMutableDictionary *requestDict = self.defaultDictionary;
        [requestDict setValue:self.token forKey:HoCPushBoxSDKJSONKeyToken];
        [self handleRequestForMethod:HoCPushBoxSDKMethodSetToken withDictionary:requestDict];
    }
    else
    {
        // Takes the top most element from the queue and send it to the api.
        NSDictionary *dict = [self peekQueue];
        if (dict)
        {
            NSString *method = [dict valueForKey:HoCPushBoxSDKDefaultsKeyMethod];
            NSDictionary *jsonDict = [dict valueForKey:HoCPushBoxSDKDefaultsKeyDict];
            if (self.uid)
            {
                // Only send if uid is set
                [self handleRequestForMethod:method withDictionary:jsonDict];
            }
        }
    }
}

#pragma mark job execution
/**
 * Send the request to the api
 * @param method the job to execute
 * @param dictionary the data to send
 */
- (void) handleRequestForMethod:(NSString *) method withDictionary:(NSDictionary *) dictionary
{
    // Finalize and serialize the data for sending
    NSError *serializationError;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:[self finalizeDictionary:dictionary] options:0 error:&serializationError];
    if (serializationError != nil)
    {
        [self postErrorNotificationWithCode:HoCPushBoxErrorCodeInternalError andReason:@"Could not build request"];
        return;
    }

    // Setup the network task
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[self requestWithPostData:postData andMethod:method] completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (connectionError)
        {
            // Error connecting - send error message
            [self handleConnectionError:connectionError forMethod:method];
        }
        else
        {
            // Connection whent fine - check result
            if ([data length] > 0)
            {
                // Data returned from api - parse it
                NSError *parseError = nil;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                if (!parseError)
                {
                    // Parsing went fine - handle the result
                    [self handleResult:dictionary code:code forMethod:method];
                }
                else
                {
                    // Parsing failed - send notification
                    [self postErrorNotificationWithCode:HoCPushBoxErrorCodeInternalError andReason:@"Could not parse result"];
                }
                
            }
        }
        // Remove lock
        self.working = NO;
        // Takes next job if possible
        [self takeNext];
    }];
    
    // Start the task.
    [task resume];

}


#pragma result handling
/** 
 * Send notification with connection error
 * @param connectionError - error
 * @param method method that failed
 **/
- (void) handleConnectionError:(NSError *) connectionError forMethod:(NSString *) method
{
    NSString *msg = @"Error connecting";
    [self postErrorNotificationWithCode:HoCPushBoxErrorCodeNetworkError andReason:msg];
    
}

/**
 * Check the result from the api
 * @param jsonResult the result from the api
 * @param code the returned http status code
 * @param the method to used
 **/
- (void) handleResult:(NSDictionary *) jsonResult code:(NSInteger) code forMethod:(NSString *) method
{
    // Check if the result was successful
    if ([[jsonResult valueForKey:HoCPushBoxSDKJSONKeySuccess] boolValue])
    {
        // Success - notify
        [[NSNotificationCenter defaultCenter] postNotificationName:HoCPushBoxSDKNotificationSuccess object:nil];
        
        // Set token is the only request that returns data and it is not part of the queue, so handle this as a special case
        if ([method isEqualToString:HoCPushBoxSDKMethodSetToken])
        {
            // set uid returned
            self.uid = [jsonResult valueForKey:HoCPushBoxSDKJSONKeyUid];
            // set token send
            self.tokenSend = YES;
        }
        else
        {
            // pop the top element from the queue
            [self popQueue];
        }
    }
    else
    {
        // Some kind of error with the request
        
        // Default error message
        NSString *msg = @"Unknown error";
        
        // Parse message if possible
        msg = [jsonResult valueForKey:HoCPushBoxSDKJSONKeyMessage] ?:msg;
        // Check the http status code
        if (code == 401)
        {
            // 401 is authorization error - send notification
            [self postErrorNotificationWithCode:HoCPushBoxErrorCodeAuthorizationError andReason:msg];
        }
        else
        {
            // Some other kind of error - send notification
            [self postErrorNotificationWithCode:HoCPushBoxErrorCodeApiError andReason:msg];
        }
    }
}



@end
