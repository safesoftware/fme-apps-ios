/*============================================================================= 
 
   Name     : FMEServerNotificationManager.h
 
   System   : FMEServer
 
   Language : Objective-C 
 
   Purpose  : TBD
 
         Copyright (c) 2013 - 2014, Safe Software Inc. All rights reserved. 
 
   Redistribution and use of this sample code in source and binary forms, with  
   or without modification, are permitted provided that the following  
   conditions are met: 
   * Redistributions of source code must retain the above copyright notice,  
     this list of conditions and the following disclaimer. 
   * Redistributions in binary form must reproduce the above copyright notice,  
     this list of conditions and the following disclaimer in the documentation  
     and/or other materials provided with the distribution. 
 
   THIS SAMPLE CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  
   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR  
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR  
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,  
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,  
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;  
   OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,  
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  
   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SAMPLE CODE, EVEN IF  
   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
=============================================================================*/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// JSON keys
static NSString * const kJSONKeyDeviceToken   = @"ios_token";
static NSString * const kJSONKeyType          = @"fns_type";
static NSString * const kJSONKeyLocation      = @"fns_wkt_geom";
static NSString * const kJSONKeyTimestamp     = @"fns_sent";
static NSString * const kJSONKeyOperation     = @"fns_op";
static NSString * const kJSONKeyVersion       = @"fns_version";
static NSString * const kJSONValueVersion1    = @"1.0";
static NSString * const kJSONValueiOS         = @"ios";
static NSString * const kJSONValueSubscribe   = @"subscribe";
static NSString * const kJSONValueUnsubscribe = @"unsubscribe";
static NSString * const kJSONValueReport      = @"report";
static NSString * const kJSONValueUpdate      = @"update";
static NSString * const kJSONServiceRequest   = @"serviceRequest";
static NSString * const kJSONParams           = @"params";

@class FMEServerNotificationManager;

@protocol FMEServerNotificationManagerDelegate <NSObject>
@optional

// GET/fmerest/notifier/topics.json
- (void)getTopicsDidFinish:(NSArray *)topics;
- (void)getTopicsDidFail:(NSError *)error;

// GET/fmerest/notifier/subcriptions.json
- (void)getSubscriptionsDidFinish:(NSArray *)subscriptions;
- (void)getSubscriptionsDidFail:(NSError *)error;

// POST/fmerest/notifier/topics/<topic>/publish.json
- (void)subscribeDidFinish:(NSString *)topic 
                      host:(NSString *)host
                  username:(NSString *)username
                  password:(NSString *)password
               deviceToken:(NSString *)deviceToken
                  location:(CLLocation *) location
            userAttributes:(NSDictionary *)userAttributes;
- (void)subscribeDidFail:(NSString *)topic 
                    host:(NSString *)host
                username:(NSString *)username
                password:(NSString *)password
             deviceToken:(NSString *)deviceToken
                location:(CLLocation *) location
          userAttributes:(NSDictionary *)userAttributes
                   error:(NSError *)error;

// POST/fmerest/notifier/topics/<topic>/publish.json
- (void)unsubscribeDidFinish:(NSString *)topic 
                        host:(NSString *)host
                    username:(NSString *)username
                    password:(NSString *)password
                 deviceToken:(NSString *)deviceToken
              userAttributes:(NSDictionary *)userAttributes;
- (void)unsubscribeDidFail:(NSString *)topic 
                      host:(NSString *)host
                  username:(NSString *)username
                  password:(NSString *)password
               deviceToken:(NSString *)deviceToken
            userAttributes:(NSDictionary *)userAttributes
                     error:(NSError *)error;

// POST/fmerest/notifier/topics/<topic>/publish.json
- (void)reportDidFinish:(NSString *)topic
                   host:(NSString *)host
               username:(NSString *)username
               password:(NSString *)password
            deviceToken:(NSString *)deviceToken
               location:(CLLocation *)location
         userAttributes:(NSDictionary *)userAttributes;
- (void)reportDidFail:(NSString *)topic
                 host:(NSString *)host
             username:(NSString *)username
             password:(NSString *)password
          deviceToken:(NSString *)deviceToken
             location:(CLLocation *)location
       userAttributes:(NSDictionary *)userAttributes
                error:(NSError *)error;

@end


@interface FMEServerNotificationManager : NSObject

@property (nonatomic, retain) id<FMEServerNotificationManagerDelegate> delegate;

+ (BOOL)isHostReachable:(NSString *)host;

// GET/fmerest/notifier/topics
- (void)getTopicsFromHost:(NSString *)host
                 username:(NSString *)username
                 password:(NSString*)password;

// GET/fmerest/notifier/subcriptions
- (void)getSubscriptionsFromHost:(NSString *)host
                        username:(NSString *)username
                        password:(NSString *)password;

// This function subscribes the iOS device token to the topic
- (void)subscribe:(NSString *)topic 
             host:(NSString *)host
         username:(NSString *)username
         password:(NSString *)password
      deviceToken:(NSString *)deviceToken
         location:(CLLocation *)location
   userAttributes:(NSDictionary *)userAttributes;

// This function unsubscribes the iOS device token from the topic
- (void)unsubscribe:(NSString *)topic 
               host:(NSString *)host
           username:(NSString *)username
           password:(NSString *)password
        deviceToken:(NSString *)deviceToken
     userAttributes:(NSDictionary *)userAttributes;

// This function report the location to the topic
- (void)report:(NSString *)topic
          host:(NSString *)host
      username:(NSString *)username
      password:(NSString *)password
   deviceToken:(NSString *)deviceToken
      location:(CLLocation *)location
userAttributes:(NSDictionary *)userAttributes;

// This function report the location to the topic
- (void)update:(NSString *)topic
          host:(NSString *)host
      username:(NSString *)username
      password:(NSString *)password
   deviceToken:(NSString *)deviceToken
      location:(CLLocation *)location
userAttributes:(NSDictionary *)userAttributes;


@end
