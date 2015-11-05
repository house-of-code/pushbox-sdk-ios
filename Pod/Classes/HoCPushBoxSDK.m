//
//  PushBoxSDK.m
//  PushBox-sdk-ios
//
//  Created by Gert Lavsen on 03/11/15.
//  Copyright © 2015 House of Code. All rights reserved.
//

#import "HoCPushBoxSDK.h"
#import "HoCPushBoxReachability.h"
#import "NSString+HMAC.h"


#pragma mark - string constants
#pragma mark notifcations
NSString * const PushBoxSDKNotificationSuccess = @"PushBoxSDK.successfull.note";
NSString * const PushBoxSDKNotificationFailure = @"PushBoxSDK.successfull.note";
NSString * const PushBoxSDKNotificationFailureReasonKey = @"PushBoxSDK.successfull.note.reason.key";
NSString * const PushBoxSDKNotificationFailureCodeKey = @"PushBoxSDK.successfull.note.code.key";
#pragma mark urls
NSString * const PushBoxSDKApiUrl = @"http://api.pushboxsdk.com/v1/";
NSString * const PushBoxSDKHost = @"api.pushboxsdk.com";
#pragma mark JSON keys
NSString * const PushBoxSDKJSONKeyHMAC = @"hmac";
NSString * const PushBoxSDKJSONKeyTS = @"ts";
NSString * const PushBoxSDKJSONKeyApiKey = @"app_key";
NSString * const PushBoxSDKJSONKeyToken = @"token";
NSString * const PushBoxSDKJSONKeyUid = @"uid";
NSString * const PushBoxSDKJSONKeyProfileId = @"profile_identifier";
NSString * const PushBoxSDKJSONKeyPlatform = @"platform";
NSString * const PushBoxSDKJSONKeyOccurenceTimestamp = @"timestamp";
NSString * const PushBoxSDKJSONKeyAge = @"age";
NSString * const PushBoxSDKJSONKeyBirthday = @"birthday";
NSString * const PushBoxSDKJSONKeyGender = @"gender";
NSString * const PushBoxSDKJSONKeyEvent = @"event";
NSString * const PushBoxSDKJSONKeyChannels = @"channels";
NSString * const PushBoxSDKJSONKeyLocationLatitude = @"latitude";
NSString * const PushBoxSDKJSONKeyLocationLongitude = @"longitude";
NSString * const PushBoxSDKJSONKeySuccess = @"success";
NSString * const PushBoxSDKJSONKeyMessage = @"message";

#pragma mark api methods
NSString * const PushBoxSDKMethodSetToken = @"set_token";
NSString * const PushBoxSDKMethodSetAge = @"set_age";
NSString * const PushBoxSDKMethodSetBirthday = @"set_birthday";
NSString * const PushBoxSDKMethodLogEvent = @"log_event";
NSString * const PushBoxSDKMethodLogLocation = @"log_location";
NSString * const PushBoxSDKMethodSetGender = @"set_gender";
NSString * const PushBoxSDKMethodSetChannels = @"set_channels";

#pragma mark JSON values
NSString * const PushBoxSDKJSONValuePlatform = @"iOS";

#pragma mark user defaults
NSString * const PushBoxSDKSuitName = @"PushBoxSDK.suit.name";

#pragma mark User defaults keys
NSString * const PushBoxSDKDefaultsUid = @"uid";
NSString * const PushBoxSDKDefaultsQueue = @"queue";
NSString * const PushBoxSDKDefaultsKeyMethod = @"method";
NSString * const PushBoxSDKDefaultsKeyDict = @"dict";


#pragma mark - static variables
/** Holds the Api key */
static NSString *API_KEY;
/** Holds the Api secret */
static NSString *API_SECRET;


#pragma mark - properties definition
@interface PushBoxSDK ()

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
@property (nonatomic, strong) PushBoxReachability *netStatus;

#pragma mark timestamp
@property (nonatomic, readonly) long timestamp;

@end

@implementation PushBoxSDK
@synthesize uid = _uid;

#pragma mark - initialization
- (id) init
{
    self = [super init];
    if (self)
    {
        self.netStatus = [PushBoxReachability reachabilityWithHostName:PushBoxSDKHost];
        [self.netStatus startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:PushBoxReachabilityChangedNotification object:nil];

    }
    return self;
}

#pragma singleton instance
+ (instancetype) sharedInstance
{
    assert(API_KEY != nil);
    assert(API_SECRET != nil);
    
    static PushBoxSDK *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[PushBoxSDK alloc] init];
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
    [dict setObject:[NSNumber numberWithInteger:age] forKey:PushBoxSDKJSONKeyAge];
    [self addDictionary:dict toQueueForMethod:PushBoxSDKMethodSetAge];
    
}

#pragma mark set birthday
- (void) setBirthday:(NSDate *) birthday
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *date = [formatter stringFromDate:birthday];
    NSMutableDictionary *dict = self.defaultDictionary;
    [dict setObject:date forKey:PushBoxSDKJSONKeyBirthday];
    [self addDictionary:dict toQueueForMethod:PushBoxSDKMethodSetBirthday];
}

#pragma mark set gender
- (void) setGender:(PushBoxGenderType) gender
{
    NSMutableDictionary *dict = self.defaultDictionary;
    
    [dict setObject:[NSNumber numberWithInteger:gender] forKey:PushBoxSDKJSONKeyGender];
    [self addDictionary:dict toQueueForMethod:PushBoxSDKMethodSetGender];
}

#pragma mark log event
- (void) logEvent:(NSString *) event
{
    NSMutableDictionary *dict = self.defaultDictionary;
    [dict setObject:event forKey:PushBoxSDKJSONKeyEvent];
    [self addDictionary:dict toQueueForMethod:PushBoxSDKMethodLogEvent];
}

#pragma mark log location
- (void) logLocationWithLatitude:(double) latitude longitude:(double) longitude
{
    NSMutableDictionary *dict = self.defaultDictionary;
    [dict setObject:[NSNumber numberWithDouble:latitude] forKey:PushBoxSDKJSONKeyLocationLatitude];
    [dict setObject:[NSNumber numberWithDouble:longitude] forKey:PushBoxSDKJSONKeyLocationLongitude];
    [self addDictionary:dict toQueueForMethod:PushBoxSDKMethodLogLocation];
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
    [dict setObject:channels forKey:PushBoxSDKJSONKeyChannels];
    [self addDictionary:dict toQueueForMethod:PushBoxSDKMethodSetChannels];
}

#pragma mark - private properties

#pragma mark uid - get stored uid
- (NSString *) uid
{
    if (!_uid)
    {
        _uid = [self.sdkDefaults valueForKey:PushBoxSDKDefaultsUid];
    }
    return _uid;
}

#pragma mark uid - store uid
- (void) setUid:(NSString *) uid
{
    _uid = uid;
    [self.sdkDefaults setObject:_uid forKey:PushBoxSDKDefaultsUid];
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
        _sdkDefaults = [[NSUserDefaults alloc] initWithSuiteName:PushBoxSDKSuitName];
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

    if ([self.netStatus currentReachabilityStatus] == PushBoxNetworkStatusNotReachable)
    {
        return NO;
    }
    return YES;
}

#pragma mark prefilled dictionary for json requests
- (NSMutableDictionary *) defaultDictionary
{
    NSDate *now = [NSDate date];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{PushBoxSDKJSONKeyApiKey : API_KEY, PushBoxSDKJSONKeyPlatform : PushBoxSDKJSONValuePlatform, PushBoxSDKJSONKeyOccurenceTimestamp : [NSNumber numberWithLong:[now timeIntervalSinceNow]]}];
    if (self.profileIdentifier)
    {
        [dict setObject:self.token forKey:PushBoxSDKJSONKeyProfileId];
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
    PushBoxReachability *reachability = [note object];
    PushBoxNetworkStatus status = [reachability currentReachabilityStatus];
    if (status != PushBoxNetworkStatusNotReachable)
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
    [dict setObject:ts forKey:PushBoxSDKJSONKeyTS];
    [dict setObject:hmac forKey:PushBoxSDKJSONKeyHMAC];
    
    // Adds uid to dictionary
    if (self.uid)
    {
        [dict setObject:self.uid forKey:PushBoxSDKJSONKeyUid];
    }
    
    return dict;
}

#pragma mark error sending
/**
 * Post notification with error message
 * @param code the code to set
 * @param reason the reason to the error
 */
- (void) postErrorNotificationWithCode:(PushBoxErrorCode) code andReason:(NSString *) reason
{
    NSDictionary *dictionary = @{PushBoxSDKNotificationFailureCodeKey : [NSNumber numberWithInteger:code], PushBoxSDKNotificationFailureReasonKey : reason};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PushBoxSDKNotificationFailure object:nil userInfo:dictionary];
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
    
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", PushBoxSDKApiUrl, method]]];
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
    NSDictionary *dict = @{PushBoxSDKDefaultsKeyMethod : method, PushBoxSDKDefaultsKeyDict : dictionary};
    NSMutableArray *queue = [([self.sdkDefaults arrayForKey:PushBoxSDKDefaultsQueue] ?:@[]) mutableCopy];
    
    [queue addObject:dict];
    
    [self.sdkDefaults setObject:queue forKey:PushBoxSDKDefaultsQueue];
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
    return [[self.sdkDefaults arrayForKey:PushBoxSDKDefaultsQueue] ?: @[] firstObject];
}

/**
 * Pops the top of the queue
 * @return the element with higest priority from the queue and removes it
 **/
- (NSDictionary *) popQueue
{
    NSMutableArray *queue = [([self.sdkDefaults arrayForKey:PushBoxSDKDefaultsQueue] ?:@[]) mutableCopy];
    NSDictionary *dict = [queue firstObject];
    [queue removeObjectAtIndex:0];
    [self.sdkDefaults setObject:queue forKey:PushBoxSDKDefaultsQueue];
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
        [requestDict setValue:self.token forKey:PushBoxSDKJSONKeyToken];
        [self handleRequestForMethod:PushBoxSDKMethodSetToken withDictionary:requestDict];
    }
    else
    {
        // Takes the top most element from the queue and send it to the api.
        NSDictionary *dict = [self peekQueue];
        if (dict)
        {
            NSString *method = [dict valueForKey:PushBoxSDKDefaultsKeyMethod];
            NSDictionary *jsonDict = [dict valueForKey:PushBoxSDKDefaultsKeyDict];
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
        [self postErrorNotificationWithCode:PushBoxErrorCodeInternalError andReason:@"Could not build request"];
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
                    [self postErrorNotificationWithCode:PushBoxErrorCodeInternalError andReason:@"Could not parse result"];
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
    [self postErrorNotificationWithCode:PushBoxErrorCodeNetworkError andReason:msg];
    
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
    if ([[jsonResult valueForKey:PushBoxSDKJSONKeySuccess] boolValue])
    {
        // Success - notify
        [[NSNotificationCenter defaultCenter] postNotificationName:PushBoxSDKNotificationSuccess object:nil];
        
        // Set token is the only request that returns data and it is not part of the queue, so handle this as a special case
        if ([method isEqualToString:PushBoxSDKMethodSetToken])
        {
            // set uid returned
            self.uid = [jsonResult valueForKey:PushBoxSDKJSONKeyUid];
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
        msg = [jsonResult valueForKey:PushBoxSDKJSONKeyMessage] ?:msg;
        // Check the http status code
        if (code == 401)
        {
            // 401 is authorization error - send notification
            [self postErrorNotificationWithCode:PushBoxErrorCodeAuthorizationError andReason:msg];
        }
        else
        {
            // Some other kind of error - send notification
            [self postErrorNotificationWithCode:PushBoxErrorCodeApiError andReason:msg];
        }
    }
}



@end
