//
//  PushBoxReachability.h
//  PushBox-sdk-ios
//
//  Created by Gert Lavsen on 04/11/15.
//  Copyright © 2015 House of Code. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PushBoxNetworkStatus)
{
    PushBoxNetworkStatusNotReachable = 0,
    PushBoxNetworkStatusReachableViaWifi = 1,
    PushBoxNetworkStatusReachableViaWWAN = 2
};

extern NSString * const PushBoxReachabilityChangedNotification;


@interface PushBoxReachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype) reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype) reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype) reachabilityForInternetConnection;

/*!
 * Checks whether a local WiFi connection is available.
 */
+ (instancetype) reachabilityForLocalWiFi;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL) startNotifier;
- (void) stopNotifier;

- (PushBoxNetworkStatus) currentReachabilityStatus;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL) connectionRequired;

@end
