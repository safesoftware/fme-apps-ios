/*============================================================================= 
 
   Name     : FMEServerNotificationManager.m
 
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

#import "FMEServerNotificationManager.h"
#import "NSMutableURLRequest+BasicAccessAuthentication.h"
#import "Reachability.h"

static NSString * const kServiceResponse  = @"serviceResponse";
static NSString * const kTopics           = @"topics";
static NSString * const kTopic            = @"topic";
static NSString * const kSubscriptions    = @"subscriptions";
static NSString * const kSubscription     = @"subscription";
static NSString * const kProperties       = @"properties";
static NSString * const kProperty         = @"property";

static NSString * const kRESTJSONFormat   = @"json";
static NSString * const kRESTXMLFormat    = @"xml";
static NSString * const kRESTHTMLFormat   = @"html";

static NSString * const kHTTPMethodGET    = @"GET";
static NSString * const kHTTPMethodPOST   = @"POST";
static NSString * const kHTTPMethodDELETE = @"DELETE";

static NSString * const kURIGetTopics                 = @"/fmerest/notifications/topics";
static NSString * const kURIGetSubscriptions          = @"/fmerest/notifications/subscriptions";
static NSString * const kURIPostTopic                 = @"/fmerest/notifications/notification/%@";

static NSString * const kRESTContentTypeKey   = @"Content-Type";
static NSString * const kRESTContentTypeValue = @"application/json";

// Subscription request queue
static NSString * const kDeviceToken      = @"device token";
static NSString * const kUnsubscription   = @"unsubscription";
static NSString * const kHost             = @"host";
static NSString * const kUsername         = @"username";
static NSString * const kPassword         = @"password";

// Subscription properties
static NSString * const kCategory               = @"category";
static NSString * const kName                   = @"name";
static NSString * const kValue                  = @"value";
static NSString * const kCategorySubscriberData = @"FMESUBSCRIBERDATA";
static NSString * const kNameDeviceTokens       = @"DEVICE_TOKENS";

// Time
static NSString * const kJSONTimeKey            = @"fns_sent";

// HTTP Status Codes
static const NSInteger kHTTPStatusBadRequest   = 400;
static const NSInteger kHTTPStatusUnauthorized = 401;
static const NSInteger kHTTPStatusForbidden    = 403;
static const NSInteger kHTTPStatusNotFound     = 404;

// HTTP Parameters
static NSString * const kHTTPFirstParameterFormat      = @"%@=%@";
static NSString * const kHTTPSubsequentParameterFormat = @"&%@=%@"; 

@interface FMEServerNotificationManager ()

- (void) getTopicsDidFinish:(NSArray *)topics;
- (void) getTopicsDidFail:(NSError *)error;

- (void) getSubscriptionsDidFinish:(NSArray *)subscriptions;
- (void) getSubscriptionsDidFail:(NSError *)error;

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

- (void)reportDidFinish:(NSString *)topic 
                   host:(NSString *)host
               username:(NSString *)username
               password:(NSString *)password
            deviceToken:(NSString *)deviceToken
               location:(CLLocation *) location
         userAttributes:(NSDictionary *)userAttributes;

- (void)reportDidFail:(NSString *)topic 
                 host:(NSString *)host
             username:(NSString *)username
             password:(NSString *)password
          deviceToken:(NSString *)deviceToken
             location:(CLLocation *) location
       userAttributes:(NSDictionary *)userAttributes
                error:(NSError *)error;

- (NSURLRequest *)createURLRequestWithTopic:(NSString *)topic
                                  operation:(NSString *)operation
                                       host:(NSString *)host
                                   username:(NSString *)username
                                   password:(NSString *)password
                                deviceToken:(NSString *)deviceToken
                                   location:(CLLocation *)location
                             userAttributes:(NSDictionary *)userAttributes;

- (NSString *)getHostWithProtocol:(NSString *)host;

- (NSMutableURLRequest *)createURLRequestWithURL:(NSString *)urlString
                                        username:(NSString *)username
                                        password:(NSString *)password;

- (NSString *)getURLStringFromHostWithProtocol:(NSString *)hostWithProtocol
                                           uri:(NSString *)uri
                                        format:(NSString *)format;

- (bool)isSuccessful:(NSInteger)statusCode;

- (void)reportOrUpdate:(NSString *)topic
                  host:(NSString *)host
              username:(NSString *)username
              password:(NSString *)password
           deviceToken:(NSString *)deviceToken
              location:(CLLocation *)location
        userAttributes:(NSDictionary *)userAttributes
                    op:(NSString *)op;

@end

@implementation FMEServerNotificationManager

@synthesize delegate = delegate_;

#pragma mark - Private functions

- (void)getTopicsDidFinish:(NSArray *)topics
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if (self.delegate && [self.delegate respondsToSelector:@selector(getTopicsDidFinish:)])
    {
        [self.delegate getTopicsDidFinish:topics];
    }
}

- (void)getTopicsDidFail:(NSError *)error
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if (self.delegate && [self.delegate respondsToSelector:@selector(getTopicsDidFail:)])
    {
        [self.delegate getTopicsDidFail:error];
    }
}

- (void)getSubscriptionsDidFinish:(NSArray *)subscriptions
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if (self.delegate && [self.delegate respondsToSelector:@selector(getSubscriptionsDidFinish:)])
    {
        [self.delegate getSubscriptionsDidFinish:subscriptions];
    }    
}

- (void)getSubscriptionsDidFail:(NSError *)error
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if (self.delegate && [self.delegate respondsToSelector:@selector(getSubscriptionsDidFail:)])
    {
        [self.delegate getSubscriptionsDidFail:error];
    }
}

- (void)subscribeDidFinish:(NSString *)topic 
                      host:(NSString *)host
                  username:(NSString *)username
                  password:(NSString *)password
               deviceToken:(NSString *)deviceToken
                  location:(CLLocation *) location
            userAttributes:(NSDictionary *)userAttributes
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if (self.delegate && 
        [self.delegate respondsToSelector:@selector(subscribeDidFinish:host:username:password:deviceToken:location:userAttributes:)])
    {
        [self.delegate subscribeDidFinish:topic
                                     host:host
                                 username:username
                                 password:password
                              deviceToken:deviceToken
                                 location:location
                           userAttributes:userAttributes];
    }
}

- (void)subscribeDidFail:(NSString *)topic 
                    host:(NSString *)host
                username:(NSString *)username
                password:(NSString *)password
             deviceToken:(NSString *)deviceToken
                location:(CLLocation *) location
          userAttributes:(NSDictionary *)userAttributes
                   error:(NSError *)error
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if ([self.delegate respondsToSelector:
         @selector(subscribeDidFail:host:username:password:deviceToken:location:userAttributes:error:)])
    {
        [self.delegate subscribeDidFail:topic
                                   host:host
                               username:username
                               password:password
                            deviceToken:deviceToken
                               location:location
                         userAttributes:userAttributes
                                  error:error];
    }
}

- (void)unsubscribeDidFinish:(NSString *)topic 
                        host:(NSString *)host
                    username:(NSString *)username
                    password:(NSString *)password
                 deviceToken:(NSString *)deviceToken
              userAttributes:(NSDictionary *)userAttributes
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if (self.delegate && 
        [self.delegate respondsToSelector:@selector(unsubscribeDidFinish:host:username:password:deviceToken:userAttributes:)])
    {
        [self.delegate unsubscribeDidFinish:topic
                                      host:host
                                  username:username
                                  password:password
                               deviceToken:deviceToken
                             userAttributes:userAttributes];
    }
}

- (void)unsubscribeDidFail:(NSString *)topic 
                      host:(NSString *)host
                  username:(NSString *)username
                  password:(NSString *)password
               deviceToken:(NSString *)deviceToken
            userAttributes:(NSDictionary *)userAttributes
                     error:(NSError *)error
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if (self.delegate && 
        [self.delegate respondsToSelector:@selector(unsubscribeDidFail:host:username:password:deviceToken:userAttributes:error:)])
    {
        [self.delegate unsubscribeDidFail:topic
                                     host:host
                                 username:username
                                 password:password
                              deviceToken:deviceToken
                           userAttributes:userAttributes
                                    error:error];
    }
}

- (void)reportDidFinish:(NSString *)topic 
                   host:(NSString *)host
               username:(NSString *)username
               password:(NSString *)password
            deviceToken:(NSString *)deviceToken
               location:(CLLocation *) location
         userAttributes:(NSDictionary *)userAttributes
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if (self.delegate && 
        [self.delegate respondsToSelector:@selector(reportDidFinish:host:username:password:deviceToken:location:userAttributes:)])
    {
        [self.delegate reportDidFinish:topic
                                  host:host
                              username:username
                              password:password
                           deviceToken:deviceToken
                              location:location
                        userAttributes:userAttributes];
    }
}

- (void)reportDidFail:(NSString *)topic 
                 host:(NSString *)host
             username:(NSString *)username
             password:(NSString *)password
          deviceToken:(NSString *)deviceToken
             location:(CLLocation *) location
       userAttributes:(NSDictionary *)userAttributes
                error:(NSError *)error
{
    // Check if the delegate implements the optional function. Calling a non-
    // existing function on a valid object will crash.
    if ([self.delegate respondsToSelector:
         @selector(reportDidFail:host:username:password:deviceToken:location:userAttributes:error:)])
    {
        [self.delegate reportDidFail:topic
                                host:host
                            username:username
                            password:password
                         deviceToken:deviceToken
                            location:location
                      userAttributes:userAttributes
                               error:error];
    }
}

- (bool)isSuccessful:(NSInteger)statusCode
{
    return ((statusCode / 100) == 2);   // HTTP status codes 2xx
}

#pragma mark - Object life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        delegate_ = nil;
    }
    
    return self;
}

#pragma mark - Public functions

// GET/fmerest/notifier/topics
- (void)getTopicsFromHost:(NSString *)host username:(NSString *)username password:(NSString*)password
{
    // Make a url
    NSString * urlString = [self getURLStringFromHostWithProtocol:[self getHostWithProtocol:host]
                                                              uri:kURIGetTopics
                                                           format:kRESTJSONFormat];
    NSMutableURLRequest * urlRequest = [self createURLRequestWithURL:urlString
                                                            username:username
                                                            password:password];
    [urlRequest setHTTPMethod:kHTTPMethodGET];

    NSLog(@"Getting Topics:");
    NSLog(@"    HOST     = %@", host);
    NSLog(@"    USERNAME = %@", username);
    NSLog(@"    PASSWORD = %@", password);
    NSLog(@"    URL      = %@", urlRequest.URL.absoluteString);
    NSLog(@"    HTTPBODY = %@", [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"    METHOD   = %@", urlRequest.HTTPMethod);

    // Make a url connection
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * response, NSData * data, NSError * error)
     {   
//         // If the activity alert has been dismissed, the request has been
//         // cancel. We can simply return without loading the topics
//         if (!self.activityAlert)
//         {
//             return;
//         }
//         
//         // Dismiss the activity alert with an invalid button index so that
//         // we know that the alert is not cancelled by the user
//         [self.activityAlert dismissWithClickedButtonIndex:kActivityAlertInvalidButtonIndex animated:YES];
         
         // If there is an error, return it now.
         if (error)
         {
             [self getTopicsDidFail:error];
             NSLog(@"Unable to get topics from host %@ with username %@ and password %@", host, username, password);
             NSLog(@"    Description: %@", [error localizedDescription]);
             NSLog(@"    Failure Reason: %@", [error localizedFailureReason]);
             NSLog(@"    Recovery Suggestion: %@", [error localizedRecoverySuggestion]);
             NSLog(@"    Recovery Options: %@", [error localizedRecoveryOptions]);
             return;
         }
         
         // If the response is not a NSHTTPURLResponse object, there will be
         // no json data and we can return an error.
         if (![response isKindOfClass:[NSHTTPURLResponse class]] ||
             !data)
         {
             [self getTopicsDidFail:nil];
             return;
         }
         
         // If the status code is not 200, there is an error.
         NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
         if (![self isSuccessful:httpResponse.statusCode])
         {
             [self getTopicsDidFail:nil];
             return;
         }
         
         NSError * jsonError;
         NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions 
                                                                 error:&jsonError];
         
         // Parsing error for JSON data
         if (jsonError)
         { 
             [self getTopicsDidFail:jsonError];
             return;
         }
         
         // Traverse to the lists of subscriptions
         NSDictionary * serviceResponse = (json) ? [json objectForKey:kServiceResponse] : nil;
         NSArray * topicArray = (serviceResponse) ? [serviceResponse objectForKey:kTopics] : nil;
         
// TODO: Sort topic names case-insensitively
         
         // See if we have a valid list of topics
         if (topicArray)
         {
             [self getTopicsDidFinish:topicArray];
         }
         else 
         {
             [self getTopicsDidFail:nil];
         }
     }];
}

- (void)getSubscriptionsFromHost:(NSString *)host username:(NSString *)username password:(NSString *)password
{    
    // Make a url
    NSString * urlString = [self getURLStringFromHostWithProtocol:[self getHostWithProtocol:host]
                                                              uri:kURIGetSubscriptions
                                                           format:kRESTJSONFormat];
    NSMutableURLRequest * urlRequest = [self createURLRequestWithURL:urlString
                                                            username:username
                                                            password:password];
    [urlRequest setHTTPMethod:kHTTPMethodGET];
    
    NSLog(@"Getting Subscriptions:");
    NSLog(@"    HOST     = %@", host);
    NSLog(@"    USERNAME = %@", username);
    NSLog(@"    PASSWORD = %@", password);
    NSLog(@"    URL      = %@", urlRequest.URL.absoluteString);
    NSLog(@"    HTTPBODY = %@", [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"    METHOD   = %@", urlRequest.HTTPMethod);

    // Make a url connection
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse * response, NSData * data, NSError * error)
     {
         // If there is an error, return it now.
         if (error)
         {
             [self getSubscriptionsDidFail:error];
             return;
         }
         
         // If the response is not a NSHTTPURLResponse object, there will be
         // no json data and we can return an error.
         if (![response isKindOfClass:[NSHTTPURLResponse class]] ||
             !data)
         {
             [self getSubscriptionsDidFail:nil];
             return;
         }
         
         // If the status code is not 200, there is an error.
         NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
         if (![self isSuccessful:httpResponse.statusCode])
         {
             [self getSubscriptionsDidFail:nil];
             return;
         }
         
         NSError * jsonError;
         NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions 
                                                                 error:&jsonError];
        
         // Parsing error for JSON data
         if (jsonError)
         { 
             [self getSubscriptionsDidFail:jsonError];
             return;
         }
        
         // Traverse to the lists of subscriptions
         NSDictionary * serviceResponse = (json) ? [json objectForKey:kServiceResponse] : nil;
         NSArray * subscriptionArray = (serviceResponse) ? [serviceResponse objectForKey:kSubscriptions] : nil;
        
         // See if we have a valid list of subscriptions
         if (subscriptionArray)
         {
             [self getSubscriptionsDidFinish:subscriptionArray];
         }
         else 
         {
             [self getSubscriptionsDidFail:nil];
         }
    }];     
}

// This function subscribes the iOS device token to the subscription
- (void)subscribe:(NSString *)topic 
             host:(NSString *)host
         username:(NSString *)username
         password:(NSString *)password
      deviceToken:(NSString *)deviceToken
         location:(CLLocation *)location
   userAttributes:(NSDictionary *)userAttributes
{
    if (!topic || !host || !username || !password) // || !deviceToken)
    {
        [self subscribeDidFail:topic
                          host:host
                      username:username
                      password:password
                   deviceToken:deviceToken
                      location:location
                userAttributes:userAttributes
                         error:nil];

        return;   // Invalid parameters
    }
    
    NSURLRequest * urlRequest = [self createURLRequestWithTopic:topic
                                                      operation:kJSONValueSubscribe
                                                           host:host
                                                       username:username
                                                       password:password
                                                    deviceToken:deviceToken
                                                       location:location
                                                 userAttributes:userAttributes];
    
    NSLog(@"Subscribing To Topic:");
    NSLog(@"    TOPIC    = %@", topic);
    NSLog(@"    HOST     = %@", host);
    NSLog(@"    USERNAME = %@", username);
    NSLog(@"    PASSWORD = %@", password);
    NSLog(@"    TOKEN    = %@", deviceToken);
    NSLog(@"    LOCATION = %@", location);
    NSLog(@"    URL      = %@", urlRequest.URL.absoluteString);
    NSLog(@"    HTTPBODY = %@", [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"    METHOD   = %@", urlRequest.HTTPMethod);
    [userAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        NSLog(@"    USER ATTRIBUTE: %@ = %@", key, obj);
    }];
    
    // Make a url connection
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse * response, NSData * data, NSError * error)
     {
         // If there is an error, return it now.
         if (error ||
             ![response isKindOfClass:[NSHTTPURLResponse class]] ||
             !data)
         {
             [self subscribeDidFail:topic
                               host:host
                           username:username
                           password:password
                        deviceToken:deviceToken
                           location:location
                     userAttributes:userAttributes
                              error:error];
             return;
         }
         
         // If the status code is not 202, there is an error.
         NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
         if (![self isSuccessful:httpResponse.statusCode])
         {
             [self subscribeDidFail:topic
                               host:host
                           username:username
                           password:password
                        deviceToken:deviceToken
                           location:location
                     userAttributes:userAttributes
                              error:error];
             return;
         }
         
         [self subscribeDidFinish:topic
                            host:host
                        username:username
                        password:password
                     deviceToken:deviceToken
                        location:location
                  userAttributes:userAttributes];
         
     }]; 
}

// This function unsubscribes the iOS device token from the subscription
- (void)unsubscribe:(NSString *)topic 
               host:(NSString *)host
           username:(NSString *)username
           password:(NSString *)password
        deviceToken:(NSString *)deviceToken
     userAttributes:(NSDictionary *)userAttributes
{
    if (!topic || !host || !username || !password || !deviceToken)
    {
        [self unsubscribeDidFail:topic
                            host:host
                        username:username
                        password:password
                     deviceToken:deviceToken
                  userAttributes:userAttributes
                           error:nil];

        return;   // Invalid parameters
    }

    NSURLRequest * urlRequest = [self createURLRequestWithTopic:topic
                                                      operation:kJSONValueUnsubscribe
                                                           host:host
                                                       username:username
                                                       password:password
                                                    deviceToken:deviceToken
                                                       location:nil
                                                 userAttributes:userAttributes];
    
    NSLog(@"Unsubscribing From Topic:");
    NSLog(@"    TOPIC    = %@", topic);
    NSLog(@"    HOST     = %@", host);
    NSLog(@"    USERNAME = %@", username);
    NSLog(@"    PASSWORD = %@", password);
    NSLog(@"    TOKEN    = %@", deviceToken);
    NSLog(@"    URL      = %@", urlRequest.URL.absoluteString);
    NSLog(@"    HTTPBODY = %@", [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"    METHOD   = %@", urlRequest.HTTPMethod);
    [userAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         NSLog(@"    USER ATTRIBUTE: %@ = %@", key, obj);
     }];

    // Make a url connection
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse * response, NSData * data, NSError * error)
     {
         // If there is an error, return it now.
         if (error ||
             ![response isKindOfClass:[NSHTTPURLResponse class]] ||
             !data)
         {
             [self unsubscribeDidFail:topic
                                 host:host
                             username:username
                             password:password
                          deviceToken:deviceToken
                       userAttributes:userAttributes
                                error:error];
             return;
         }         
         
         // If the status code is not 200, there is an error.
         NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
         if (![self isSuccessful:httpResponse.statusCode])
         {
             [self unsubscribeDidFail:topic
                                 host:host
                             username:username
                             password:password
                          deviceToken:deviceToken
                       userAttributes:userAttributes
                                error:error];
             return;
         }
         
         [self unsubscribeDidFinish:topic
                               host:host
                           username:username
                           password:password
                        deviceToken:deviceToken
                     userAttributes:userAttributes];

     }]; 
}

// This function report the location to the topic
- (void)report:(NSString *)topic
          host:(NSString *)host
      username:(NSString *)username
      password:(NSString *)password
   deviceToken:(NSString *)deviceToken
      location:(CLLocation *)location
userAttributes:userAttributes
{
    [self reportOrUpdate:topic
                    host:host
                username:username
                password:password
             deviceToken:deviceToken
                location:location
          userAttributes:userAttributes
                      op:kJSONValueReport];
}

// This function report the location to the topic
- (void)update:(NSString *)topic
          host:(NSString *)host
      username:(NSString *)username
      password:(NSString *)password
   deviceToken:(NSString *)deviceToken
      location:(CLLocation *)location
userAttributes:(NSDictionary *)userAttributes
{
    [self reportOrUpdate:topic
                    host:host
                username:username
                password:password
             deviceToken:deviceToken
                location:location
          userAttributes:userAttributes
                      op:kJSONValueUpdate];
}

// This function report the location to the topic
- (void)reportOrUpdate:(NSString *)topic
                  host:(NSString *)host
              username:(NSString *)username
              password:(NSString *)password
           deviceToken:(NSString *)deviceToken
              location:(CLLocation *)location
        userAttributes:(NSDictionary *)userAttributes
                    op:(NSString *)op
{
    if (!topic || !host || !username || !password || !location ||
        ![FMEServerNotificationManager isHostReachable:host])
    {
        [self reportDidFail:topic
                       host:host
                   username:username
                   password:password
                deviceToken:deviceToken
                   location:location
             userAttributes:userAttributes
                      error:nil];
    }
    
    NSURLRequest * urlRequest = [self createURLRequestWithTopic:topic
                                                      operation:op
                                                           host:host
                                                       username:username
                                                       password:password
                                                    deviceToken:deviceToken
                                                       location:location
                                                 userAttributes:userAttributes];
    
    NSLog(@"Reporting to Topic:");
    NSLog(@"    TOPIC    = %@", topic);
    NSLog(@"    HOST     = %@", host);
    NSLog(@"    USERNAME = %@", username);
    NSLog(@"    PASSWORD = %@", password);
    NSLog(@"    TOKEN    = %@", deviceToken);
    NSLog(@"    LOCATION = %@", location);
    NSLog(@"    URL      = %@", urlRequest.URL.absoluteString);
    NSLog(@"    HTTPBODY = %@", [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"    METHOD   = %@", urlRequest.HTTPMethod);
    NSLog(@"    OPERATION= %@", op);
    [userAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         NSLog(@"    USER ATTRIBUTE: %@ = %@", key, obj);
     }];
    
    // Make a url connection
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse * response, NSData * data, NSError * error)
     {
         // If there is an error, return it now.
         if (error || ![response isKindOfClass:[NSHTTPURLResponse class]] || !data)
         {
             [self reportDidFail:topic 
                            host:host
                        username:username
                        password:password
                     deviceToken:deviceToken
                        location:location
                  userAttributes:userAttributes
                           error:error];
             return;
         }
         
         // If the status code is not 202, there is an error.
         NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
         if (![self isSuccessful:httpResponse.statusCode])
         {
             [self reportDidFail:topic
                            host:host
                        username:username
                        password:password
                     deviceToken:deviceToken
                        location:location
                  userAttributes:userAttributes
                           error:error];
             return;
         }
         
         [self reportDidFinish:topic
                          host:host
                      username:username
                      password:password
                   deviceToken:deviceToken
                      location:location
                userAttributes:userAttributes];
     }]; 
}


- (NSString *)getHostWithProtocol:(NSString *)host
{
    if (!host || host.length == 0)
    {
        return nil;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*.+:\\/\\/"
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSArray * matches = [regex matchesInString:host options:0 range:NSMakeRange(0, host.length)];
    if (matches.count == 0)
    {
        return [NSString stringWithFormat:@"http://%@", host];
    }
    else 
    {
        return host;
    }
}

- (NSMutableURLRequest *)createURLRequestWithURL:(NSString *)urlString
                                        username:(NSString *)username
                                        password:(NSString *)password
{
    NSString * escapedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:escapedUrlString];
    
    // Make a url request
    forceLoadNSMutableURLRequestWithCategoryBasicAccessAuthentication();
    NSMutableURLRequest * urlRequest
    = [NSMutableURLRequest requestInBasicAccessAuthenticationWithUrl:url
                                                            username:username
                                                            password:password];
    urlRequest.timeoutInterval = 5;   // seconds
    return urlRequest;
}

- (NSString *)getURLStringFromHostWithProtocol:(NSString *)hostWithProtocol
                                           uri:(NSString *)uri
                                        format:(NSString *)format
{
    return [NSString stringWithFormat:@"%@%@.%@", hostWithProtocol, uri, format];
}

- (NSURLRequest *)createURLRequestWithTopic:(NSString *)topic
                                  operation:(NSString *)operation
                                       host:(NSString *)host
                                   username:(NSString *)username
                                   password:(NSString *)password
                                deviceToken:(NSString *)deviceToken
                                   location:(CLLocation *)location
                             userAttributes:(NSDictionary *)userAttributes
{
    // Make a url
    NSString * uri = [NSString stringWithFormat:kURIPostTopic, topic];    
    NSString * urlString = [self getURLStringFromHostWithProtocol:[self getHostWithProtocol:host]
                                                              uri:uri
                                                           format:kRESTJSONFormat];
    
    NSMutableURLRequest * urlRequest = [self createURLRequestWithURL:urlString
                                                            username:username
                                                            password:password];
    [urlRequest setHTTPMethod:kHTTPMethodPOST];
    [urlRequest setValue:kRESTContentTypeValue forHTTPHeaderField:kRESTContentTypeKey] ;

    NSMutableDictionary* params = [[NSMutableDictionary alloc] init] ;
    
    // fns_type
    [params setValue:kJSONValueiOS forKey:kJSONKeyType] ;
    
    // fns_version
    [params setValue:kJSONValueVersion1 forKey:kJSONKeyVersion] ;

    // fns_op
    [params setValue:operation forKey:kJSONKeyOperation] ;
    
    // fns_wkt_geom
    if (location)
    {
        NSString * userLocationString = [NSString stringWithFormat:@"POINT (%f %f)",
                                         location.coordinate.longitude,
                                         location.coordinate.latitude];
        [params setValue:userLocationString forKey:kJSONKeyLocation] ;
    }
//    else 
//    {
//        [httpBody appendFormat:kHTTPSubsequentParameterFormat, kJSONKeyLocation, @"text with space"];//@"中文"];
//    }
    
    // ios_token
    if (deviceToken)
    {
        [params setValue:deviceToken forKey:kJSONKeyDeviceToken] ;
    }
    
    // User Attributes
    [userAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        // We only set the parameter if it is not nil.
        if (obj)
        {
            [params setValue:obj forKey:key];
        }
    }];

    // RFC3339 Time Format
    NSDateFormatter * rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"];
    [params setValue:[rfc3339DateFormatter stringFromDate:[NSDate date]] forKey:kJSONTimeKey];
    
    NSError* error ;
    NSData* body = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error] ;
    if ( error )
    {
        return nil ;
    }
    
    [urlRequest setHTTPBody:body] ;

    return urlRequest;
}

#pragma mark - Class function

+ (BOOL)isHostReachable:(NSString *)host
{
    if (!host || host.length == 0)
    {
        return NO;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*(?:(?:https?):\\/\\/)?([^:]*):?.*\\s*$"
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSArray * matches = [regex matchesInString:host options:0 range:NSMakeRange(0, host.length)];
    if (matches.count == 1)
    {
        for (NSTextCheckingResult *match in matches)
        {
            if (match.numberOfRanges != 2)   // The first range is the overall matched range
            {
                return NO;  // The number of captured numbers is not 1 (host name)
            }
            
            NSString * hostName = [host substringWithRange:[match rangeAtIndex:1]];
            Reachability * reachability = [Reachability reachabilityWithHostName:hostName];
            return (reachability.currentReachabilityStatus != NotReachable);
        }
    }
    
    return NO;
}


@end
