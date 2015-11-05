//
//  HoCPushBoxSDK.h
//  HoCPushBox-sdk-ios
//
//  Created by Gert Lavsen on 03/11/15.
//  Copyright © 2015 House of Code. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Notications send by the sdk
/** Notification name when data send successfully */
extern NSString * const HoCPushBoxSDKNotificationSuccess;
/** Notification name when data sending failed */
extern NSString * const HoCPushBoxSDKNotificationFailure;
/** Key for notification userinfo object for getting the reason to the failure */
extern NSString * const HoCPushBoxSDKNotificationFailureReasonKey;
/** Key for notification userinfo object for getting the code for the failure */
extern NSString * const HoCPushBoxSDKNotificationFailureCodeKey;


#pragma mark - Error codes
typedef NS_ENUM(NSUInteger, HoCPushBoxErrorCode)
{
    /** Unknown error */
    HoCPushBoxErrorCodeUnknown = 10001,
    /** Internal error */
    HoCPushBoxErrorCodeInternalError = 10002,
    /** authorization error */
    HoCPushBoxErrorCodeAuthorizationError = 10003,
    /** network error */
    HoCPushBoxErrorCodeNetworkError = 10004,
    /** error returned from the api */
    HoCPushBoxErrorCodeApiError = 10005
};


#pragma mark - Gender types
typedef NS_ENUM(NSUInteger, HoCPushBoxGenderType)
{
    /** Unknown gender type - default value */
    HoCPushBoxGenderTypeUnknown = 0,
    /** Female */
    HoCPushBoxGenderTypeFemale = 1,
    /** Male */
    HoCPushBoxGenderTypeMale = 2
};

@interface HoCPushBoxSDK : NSObject

#pragma mark - initialization of the sdk
/** 
 * Sets the the api key and api secret for authenticating
 * Must be called before getting the shared instance - eg. before any other calls to the sdk.
 * 
 * Call this instance method as soon as possible.
 * Eg. in the App Delegate application:didFinishLaunchingWithOptions: method
 * @param apiKey api key
 * @param secret secret
 **/
+ (void) setApiKey:(NSString *) apiKey andSecret:(NSString *) secret;


#pragma mark - shared instance
/**
 * Return a singleton instance of the sdk.
 * make sure to call setApiKey: andSecret: before this call
 * @return shared instance of the sdk
 */
+ (instancetype) sharedInstance;


#pragma mark - set profile identifier
/**
 * Sets profile identifer for the user
 * @param profile identifer
 **/
- (void) setProfileIdentifier:(NSString *) profileIdentifier;

#pragma mark - handle device token
/**
 * Sets the device token
 * Call this method from application: didRegisterForRemoteNotificationsWithDeviceToken: in your App Delegate implementation
 * @param token - token as nsdata
 */
- (void) setDeviceToken:(NSData *) token;


#pragma mark - send data

/** 
 * Sets the age of the user
 * @param age
 **/
- (void) setAge:(NSInteger) age;
/**
 * Set the birthday of the user
 * @param birthday date of birth - only the date part is used
 **/
- (void) setBirthday:(NSDate *) birthday;
/**
 * Set the gender of the user
 * @param gender the gender of the user
 **/
- (void) setGender:(HoCPushBoxGenderType) gender;
/**
 * Logs an event
 * @param event the event to log
 **/
- (void) logEvent:(NSString *) event;

/**
 * Logs location
 * @param latitude the latitude of the user
 * @param longitude the longitude of the user
 **/
- (void) logLocationWithLatitude:(double) latitude longitude:(double) longitude;
/**
 * Sets the channels for the user
 * @param channels array of strings with channel names
 **/
- (void) setChannels:(NSArray *) channels;

@end
