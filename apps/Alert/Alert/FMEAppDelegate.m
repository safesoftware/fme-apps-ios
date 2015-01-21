/*============================================================================= 
 
   Name     : FMEAppDelegate.m
 
   System   : FME Alerts
 
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

#import "FMEAppDelegate.h"
#import "FMEMessagesTableViewController.h"
#import "FMEServerAccountViewController.h"
#import "FMEMapViewController.h"
#import "FMEServerNotificationManager.h"
#import "Reachability.h"

// User Defaults Look-Up Keys
static NSString * kUserDefaultsKeyHost                     = @"Host";
static NSString * kUserDefaultsKeyUsername                 = @"Username";
static NSString * kUserDefaultsKeyPassword                 = @"Password";
static NSString * kUserDefaultsKeySubscribedTopicNames     = @"Subscribed Topic Names";
static NSString * kUserDefaultsKeyTrackedTopicNames        = @"Tracked Topic Names";
static NSString * kUserDefaultsKeyReportLocationToTopicsOn = @"Report Location To Topics On";
static NSString * kUserDefaultsKeyHighPrecisionEnabled     = @"High Precision Enabled";
static NSString * kUserDefaultsKeyTimeIntervalInSecond     = @"Time Interval In Second";
static NSString * kUserDefaultsKeyDistanceFilterInMeter    = @"Distance Filter In Meter";
static NSString * kUserDefaultsKeyDeviceToken              = @"Device Token";
static NSString * kUserDefaultsKeyUserAttributes           = @"UserAttributes";

static NSString * const kJSONFristNameKey                  = @"msg_first_name";
static NSString * const kJSONLastNameKey                   = @"msg_last_name";
static NSString * const kJSONEmailKey                      = @"msg_from";
static NSString * const kJSONSubjectKey                    = @"msg_subject";
static NSString * const kJSONWebAddressKey                 = @"msg_url";
static NSString * const kJSONDetailsKey                    = @"msg_content";
static NSString * const kJSONDetailsTypeKey                = @"msg_content_type";


static const NSTimeInterval     kDefaultTimeInterval             = 60;   // secs
static const CLLocationDistance kDefaultDistanceFilter           = 500;  // meters
static const BOOL               kDefaultReportLocationToTopicsOn = YES;
static const BOOL               kDefaultHighPrecisionEnabled     = NO;

// APN
static NSString * kApnKeyAlert       = @"alert";
static NSString * kApnKeyAps         = @"aps";
static NSString * kApnKeyTitle       = @"title";
static NSString * kApnKeyLocation    = @"location";

FMEAppDelegate * appDelegate = nil;

@interface FMEAppDelegate ()
@property (copy  , nonatomic) NSString            * deviceToken;
@property (retain, nonatomic) NSMutableDictionary * userAttributesMutable;
- (void)initUserDefaults;
- (void)initLocationManager;
- (void)handleRemoteNotification:(UIApplication *)application data:(NSDictionary*)data;
- (void)saveObject:(NSObject *)string forKey:(NSString *)key;
- (void)saveHost:(NSString *)host;
- (NSString *)restoreHost;
- (void)saveUsername:(NSString *)username;
- (NSString *)restoreUsername;
- (void)savePassword:(NSString *)password;
- (NSString *)restorePassword;
- (void)saveSubscribedTopicNames:(NSArray *)subscribedTopicNames;
- (NSArray *)restoreSubscribedTopicNames;
- (void)saveTrackedTopicNames:(NSArray *)trackedTopicNames;
- (NSArray *)restoreTrackedTopicNames;
- (void)saveReportLocationToTopicsOn:(BOOL)on;
- (BOOL)restoreReportLocationToTopicsOn;
- (void)saveHighPrecisionUsed:(BOOL)used;
- (BOOL)restoreHighPrecisionUsed;
- (void)saveTimerIntervalInSecond:(NSInteger)seconds;
- (NSInteger)restoreTimerIntervalInSecond;
- (void)saveDistanceFilterInMeter:(double)meters;
- (double)restoreDistanceFilterInMeter;
- (void)saveDeviceToken:(NSString *)deviceToken;
- (NSString *)restoreDeviceToken;
- (BOOL)convertFromWKT:(NSString *)pointWKT toCoordinate:(CLLocationCoordinate2D *)coordinate;
- (NSDictionary *)restoreDictionaryForKey:(NSString *)key;
@end


@implementation FMEAppDelegate

@synthesize window                   = window_;
@synthesize deviceToken              = deviceToken_;
@synthesize locationManager          = locationManager_;
@synthesize notificationManager      = notificationManager_;
@synthesize host                     = host_;
@synthesize username                 = username_;
@synthesize password                 = password_;
@synthesize subscribedTopicNames     = subscribedTopicNames_;
@synthesize trackedTopicNames        = trackedTopicNames_;
@synthesize reportLocationToTopicsOn = reportLocationToTopicsOn_;
@synthesize highPrecisionUsed        = highPrecisionUsed_;
@synthesize timeIntervalInSecond     = timeIntervalInSecond_;
@synthesize distanceFilterInMeter    = distanceFilterInMeter_;
@synthesize firstNameKey             = firstNameKey_;
@synthesize lastNameKey              = lastNameKey_;
@synthesize emailKey                 = emailKey_;
@synthesize subjectKey               = subjectKey_;
@synthesize webAddressKey            = webAddressKey_;
@synthesize detailsKey               = detailsKey_;
@synthesize detailsTypeKey           = detailsTypeKey_;
@synthesize userAttributesMutable    = userAttributesMutable_;

#pragma mark - User Defaults

- (void)saveObject:(NSObject *)object forKey:(NSString *)key
{
    if (object) {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveHost:(NSString *)host {
    [self saveObject:host forKey:kUserDefaultsKeyHost];
}

- (NSString *)restoreHost {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsKeyHost];
}

- (void)saveUsername:(NSString *)username {
    [self saveObject:username forKey:kUserDefaultsKeyUsername];
}

- (NSString *)restoreUsername {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsKeyUsername];
}

- (void)savePassword:(NSString *)password {
    [self saveObject:password forKey:kUserDefaultsKeyPassword];
}

- (NSString *)restorePassword {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsKeyPassword];
}

- (void)saveSubscribedTopicNames:(NSArray *)subscribedTopicNames {
    [self saveObject:subscribedTopicNames forKey:kUserDefaultsKeySubscribedTopicNames];
}

- (NSArray *)restoreSubscribedTopicNames {
    return [[NSUserDefaults standardUserDefaults] stringArrayForKey:kUserDefaultsKeySubscribedTopicNames];
}

- (void)saveTrackedTopicNames:(NSArray *)trackedTopicNames {
    [self saveObject:trackedTopicNames forKey:kUserDefaultsKeyTrackedTopicNames];
}

- (NSArray *)restoreTrackedTopicNames {
    return [[NSUserDefaults standardUserDefaults] stringArrayForKey:kUserDefaultsKeyTrackedTopicNames];
}

- (void)saveReportLocationToTopicsOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultsKeyReportLocationToTopicsOn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)restoreReportLocationToTopicsOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyReportLocationToTopicsOn];
}

- (void)saveHighPrecisionUsed:(BOOL)used {
    [[NSUserDefaults standardUserDefaults] setBool:used forKey:kUserDefaultsKeyHighPrecisionEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)restoreHighPrecisionUsed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyHighPrecisionEnabled];
}

- (void)saveTimerIntervalInSecond:(NSInteger)seconds {
    [[NSUserDefaults standardUserDefaults] setInteger:seconds forKey:kUserDefaultsKeyTimeIntervalInSecond];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)restoreTimerIntervalInSecond {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultsKeyTimeIntervalInSecond];
}

- (void)saveDistanceFilterInMeter:(double)meters {
    [[NSUserDefaults standardUserDefaults] setDouble:meters forKey:kUserDefaultsKeyDistanceFilterInMeter];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (double)restoreDistanceFilterInMeter {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsKeyDistanceFilterInMeter];
}

- (void)saveDeviceToken:(NSString *)deviceToken {
    [self saveObject:deviceToken forKey:kUserDefaultsKeyDeviceToken];
}

- (NSString *)restoreDeviceToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsKeyDeviceToken];
}

- (void)initUserDefaults
{
    self.firstNameKey   = kJSONFristNameKey;
    self.lastNameKey    = kJSONLastNameKey;
    self.emailKey       = kJSONEmailKey;
    self.subjectKey     = kJSONSubjectKey;
    self.webAddressKey  = kJSONWebAddressKey;
    self.detailsKey     = kJSONDetailsKey;
    self.detailsTypeKey = kJSONDetailsTypeKey;

    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithBool:kDefaultReportLocationToTopicsOn], kUserDefaultsKeyReportLocationToTopicsOn,
                                                             [NSNumber numberWithBool:kDefaultHighPrecisionEnabled], kUserDefaultsKeyHighPrecisionEnabled,
                                                             kDefaultTimeInterval,         kUserDefaultsKeyTimeIntervalInSecond,
                                                             kDefaultDistanceFilter,       kUserDefaultsKeyDistanceFilterInMeter,
                                                             nil]];

    self.host                     = [self restoreHost];
    self.username                 = [self restoreUsername];
    self.password                 = [self restorePassword];
    self.subscribedTopicNames     = [self restoreSubscribedTopicNames];
    self.reportLocationToTopicsOn = [self restoreReportLocationToTopicsOn];
    self.highPrecisionUsed        = [self restoreHighPrecisionUsed];
    self.timeIntervalInSecond     = [self restoreTimerIntervalInSecond];
    self.distanceFilterInMeter    = [self restoreDistanceFilterInMeter];
    self.deviceToken              = [self restoreDeviceToken];
    self.userAttributesMutable    = [[NSMutableDictionary alloc] initWithDictionary:
                                     [self restoreDictionaryForKey:kUserDefaultsKeyUserAttributes]];
    
    // If both the time interval and the distance filter are zero, we will set
    // the distance filter to the default.
    if (self.timeIntervalInSecond <= 0 &&
        (self.distanceFilterInMeter == 0 || self.distanceFilterInMeter == kCLDistanceFilterNone))
    {
        self.distanceFilterInMeter = self.defaultDistanceFilter;
    }
    
    // The tracked topics are the same as the subscribed topics now
    self.trackedTopicNames        = self.subscribedTopicNames;
}

- (void)initLocationManager
{
    self.locationManager.delegate              = self;
    self.locationManager.highPrecisionEnabled = self.highPrecisionUsed; 
    self.locationManager.timeIntervalInSec     = self.timeIntervalInSecond;
    self.locationManager.distanceFilterInMeter = self.distanceFilterInMeter;
    
    // Request the current location so that we can include an initial location
    // when the user subscribes to a topic
    [self.locationManager requestLocation];
    
    // If we have tracked topics, start the location tracking now
    NSArray * trackedTopics = [self restoreTrackedTopicNames];
    if (trackedTopics && trackedTopics.count > 0 && self.reportLocationToTopicsOn)
    {
        [self.locationManager startLocationTracking];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register the device for Apple Push Notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeAlert)];

    // Initialize variables
    appDelegate      = self;
    deviceToken_     = nil;
    locationManager_ = nil;
    [self initUserDefaults];
    [self initLocationManager];
    
    // Get any data from remote notification and handle it
    NSDictionary * data = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (data)
    {
       [self handleRemoteNotification:application data:data];
    }
//    else
//    {
//       NSMutableDictionary * data = [NSMutableDictionary dictionaryWithObject:@"Empty - in launch" forKey:kApnKeyTitle];
//       [self handleRemoteNotification:application data:data];
//    }

// NOTE: Uncomment this to test the table view cell layout
//    // TEMP: Adding a message manually for testing
//    UINavigationController * rootViewController = (UINavigationController *)self.window.rootViewController;    
//    FMEMessagesTableViewController * messagesTableViewController 
//        = (FMEMessagesTableViewController *)[[rootViewController viewControllers] objectAtIndex:0];
//    if (messagesTableViewController)
//    {
//        [messagesTableViewController addMessageWithTitle:@"" details:@"" date:nil];
//        
//        //[messagesTableViewController clearAllMessages];
//        [messagesTableViewController addMessageWithTitle:@"Message Title - fjaio fwajif woif wafjoiwa jfowai ∫" 
//                                                 details:@"The details about this message sjaf owja fowajf wajfo wafow foawif woafj awofjwa ofjawfo waoif wajofo wajfoaw fjwaof wf9i jafoi awjfoijwa fwaof jof wajofia w"
//                                                    date:[NSDate date]
//                                                location:CLLocationCoordinate2DMake(42.0, -80)];
//
//        [messagesTableViewController addMessageWithTitle:@"Message Title - fjaio fwajif woif wafjoiwa jfowai ∫" 
//                                                 details:@"The details about this message sjaf owja fowajf wajfo wafow foawif woafj awofjwa ofjawfo waoif wajofo wajfoaw fjwaof wf9i jafoi awjfoijwa fwaof jof wajofia w"
//                                                    date:[NSDate date]
//                                                location:CLLocationCoordinate2DMake(42.0, -90)];
//
//        [messagesTableViewController addMessageWithTitle:@"Message Title - fjaio fwajif woif wafjoiwa jfowai ∫" 
//                                                 details:@"The details about this message sjaf owja fowajf wajfo wafow foawif woafj awofjwa ofjawfo waoif wajofo wajfoaw fjwaof wf9i jafoi awjfoijwa fwaof jof wajofia w"
//                                                    date:[NSDate date]
//                                                location:CLLocationCoordinate2DMake(42.0, -70)];
//
//        [messagesTableViewController addMessageWithTitle:@"Message with no location"
//                                                 details:@"The details about this message do not have anything meaningful here."
//                                                    date:[NSDate date]];
//        
//        [messagesTableViewController addMessageWithTitle:@"Message with no location"
//                                                 details:@"The details about this message do not have anything meaningful here. dfaj fowa fawofj waofj awofaw jfoiawjf awofj awofi awjfoiaw fjoiawf ajwiof awfoihaw fhawuf awhoiwaf oawijf awjfiaw fjf ajaw ef8awf89a f8a9f a289fa 289a fjwa9f jawf jwaf9 awfjaw9f jaw89f awjfa89f aj89f ajf89a fj89awfj a89f ajf89a fja892 faj28f9 ajf89a 2f8a9f ja892fj a289f a2jf899a 2fj8a29f ja89f ajf89 a2jf89a 2fj89af ja89f a89f aj8fa f8a29f j8a9f a89f ajf89a 2fj89aw fa89gh89agh a89gh98 vrhaw9vh 98vha9h a8h 2a9ga3g 89ahg89wa 8hg a9gh9a 8ga"
//                                                    date:[NSDate date]];
//
//    }

// NOTE: Uncomment this to test the handling code of Apple Push Notification payload
//    NSMutableDictionary * description = [NSMutableDictionary dictionaryWithObject:@"Let it snow! Let it snow! Let it snow!" forKey:kApnKeyAlert];
//    NSArray * testDataValues = [NSArray arrayWithObjects:@"White Christmas", description, @"    POINT   ( -122.857232 +49.138905   )    ", nil];
//    NSArray * testDataKeys   = [NSArray arrayWithObjects:kApnKeyTitle, kApnKeyAps, kApnKeyLocation, nil];
//    NSMutableDictionary * testData = [NSMutableDictionary dictionaryWithObjects:testDataValues forKeys:testDataKeys];
//    [self handleRemoteNotification:(UIApplication *)application data:(NSDictionary*)testData];
   
    // If the host is set, we should warn the user if the host is unreachable
    if (self.host && self.host.length > 0 && ![FMEServerNotificationManager isHostReachable:self.host])
    {
        [FMESettingsViewController showHostUnreachableAlertView];
    }
    
    return YES;
}

- (BOOL)convertFromWKT:(NSString *)pointWKT toCoordinate:(CLLocationCoordinate2D *)coordinate
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*POINT\\s*\\(\\s*([-+]?[0-9]*\\.?[0-9]+)\\s+([-+]?[0-9]*\\.?[0-9]+)\\s*\\)\\s*$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray * matches = [regex matchesInString:pointWKT
                                       options:0
                                         range:NSMakeRange(0, pointWKT.length)];
    if (matches.count == 1)
    {
        for (NSTextCheckingResult *match in matches)
        {
            if (match.numberOfRanges != 3)   // The first range is the overall matched range
            {
                return NO;  // The number of captured numbers are not two (for lat and long)
            }
            
            double longitude = [[pointWKT substringWithRange:[match rangeAtIndex:1]] doubleValue];
            double latitude  = [[pointWKT substringWithRange:[match rangeAtIndex:2]] doubleValue];
            if (latitude  && (- 90.0 <= latitude  && latitude  <=  90.0) &&
                longitude && (-180.0 <= longitude && longitude <= 180.0))
            {
                (*coordinate).latitude = latitude;
                (*coordinate).longitude = longitude;
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }

    return NO;
}

- (NSDictionary *)restoreDictionaryForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
}

- (void)handleRemoteNotification:(UIApplication *)application data:(NSDictionary*)data
{
    if (!data)
    {
        return;
    }
    
    NSLog(@"Remote Notification Data: %@", data);
    
    // Reset the badge number to 0 since we don't use it.
    application.applicationIconBadgeNumber = 0;
    
    id titleData       = [data valueForKey:kApnKeyTitle];
    id descriptionData = [[data valueForKey:kApnKeyAps] valueForKey:kApnKeyAlert];
    id locationData    = [data valueForKey:kApnKeyLocation];
    
    NSString * title       = ([titleData isKindOfClass:[NSString class]]) ? (NSString *)titleData : @"";
    NSString * description = ([descriptionData isKindOfClass:[NSString class]]) ? (NSString *)descriptionData : @"";
    NSString * location    = ([locationData isKindOfClass:[NSString class]]) ? (NSString *)locationData : nil;
    
    NSDate * date = [NSDate date];
        
    BOOL hasLocation = NO;
    CLLocationCoordinate2D coordinate;
    if (location)
    {
        hasLocation = [self convertFromWKT:location toCoordinate:&coordinate];
    }
    
    FMEMessagesTableViewController * messagesTableViewController = nil;
    UINavigationController * rootViewController = (UINavigationController *)self.window.rootViewController;    
    messagesTableViewController 
        = (FMEMessagesTableViewController *)[[rootViewController viewControllers] objectAtIndex:0];        

    if (messagesTableViewController)
    {
        if (hasLocation)
        {
            [messagesTableViewController addMessageWithTitle:title 
                                                     details:description
                                                        date:date
                                                    location:coordinate];
        }
        else 
        {
            [messagesTableViewController addMessageWithTitle:title
                                                     details:description
                                                        date:date];
        }
    }
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Set the device token in the message table view controller
    NSString * deviceTokenWithAngleBracket = [NSString stringWithFormat:@"%@", deviceToken];
    NSCharacterSet * characterSet = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    NSString * token = [deviceTokenWithAngleBracket stringByTrimmingCharactersInSet:characterSet];  // Remove < and >
    self.deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];            // Remove space
    
    [self saveDeviceToken:self.deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err 
{
   NSLog(@"Failed to register for remote notification");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
   NSLog(@"Did receive remote notification with completion handler");
   if (userInfo)
   {
//      NSMutableDictionary * data = [NSMutableDictionary dictionaryWithObject:@"NOT Empty - in completion handler" forKey:kApnKeyTitle];
//      [self handleRemoteNotification:application data:data];
   
      [self handleRemoteNotification:application data:userInfo];
   }
//   else
//   {
//      NSMutableDictionary * data = [NSMutableDictionary dictionaryWithObject:@"Empty - in completion handler" forKey:kApnKeyTitle];
//      [self handleRemoteNotification:application data:data];
//   }

//   UILocalNotification *notification = [[UILocalNotification alloc] init];
//   notification.alertBody =  @"Looks like i got a notification - fetch thingy";
//   [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
   
   handler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
   NSLog(@"Did receive remote notificadtion");
   [self handleRemoteNotification:application data:userInfo];
}

                            
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (self.locationManager.trackingLocation) {
        [self.locationManager stopLocationTracking];
    }
}

#pragma mark - UISplitViewControllerDelegate protocol implementation

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{   
    return YES;
}

#pragma mark - Public properties

- (NSDictionary *)userAttributes
{
    return self.userAttributesMutable;
}

- (void)setUserAttribute:(NSObject *)value forName:(NSString *)name
{
    if (value)
    {
        [self.userAttributesMutable setObject:value forKey:name];
    }
    else
    {
        [self.userAttributesMutable removeObjectForKey:name];
    }
    
    [self saveObject:self.userAttributesMutable forKey:kUserDefaultsKeyUserAttributes];
}

- (void)setHost:(NSString *)host
{
    host_ = host;
    [self saveHost:host];
}

- (void)setUsername:(NSString *)username
{
    username_ = username;
    [self saveUsername:username];
}

- (void)setPassword:(NSString *)password
{
    password_ = password;
    [self savePassword:password];
}

- (void)setSubscribedTopicNames:(NSArray *)subscribedTopicNames
{
    subscribedTopicNames_ = subscribedTopicNames;
    [self saveSubscribedTopicNames:subscribedTopicNames];
}

- (void)setTrackedTopicNames:(NSArray *)trackedTopicNames
{
    trackedTopicNames_ = trackedTopicNames;
    [self saveTrackedTopicNames:trackedTopicNames];
    
    // We need to start location tracking if there are topics now, or
    // we need to stop location tracking if there are no topics now.
    if (trackedTopicNames && trackedTopicNames.count > 0) {
        if (locationManager_ && !self.locationManager.trackingLocation && self.reportLocationToTopicsOn) {
            [self.locationManager startLocationTracking];
        }
    }
    else {
        if (locationManager_ && self.locationManager.trackingLocation) {
            [self.locationManager stopLocationTracking];
        }
    }
}

- (void)setReportLocationToTopicsOn:(BOOL)reportLocationToTopicsOn
{
    reportLocationToTopicsOn_ = reportLocationToTopicsOn;
    [self saveReportLocationToTopicsOn:reportLocationToTopicsOn];
    
    if (locationManager_) {
        if (reportLocationToTopicsOn && !self.locationManager.trackingLocation &&
            self.trackedTopicNames && self.trackedTopicNames.count > 0) {
            [self.locationManager startLocationTracking];
        }
        else if (!reportLocationToTopicsOn && self.locationManager.trackingLocation) {
            [self.locationManager stopLocationTracking];
        }
    }
}

- (void)setHighPrecisionUsed:(BOOL)highPrecisionUsed
{
    highPrecisionUsed_ = highPrecisionUsed;
    [self saveHighPrecisionUsed:highPrecisionUsed];
    
    if (locationManager_) {
        self.locationManager.highPrecisionEnabled = highPrecisionUsed;
    }
}

- (void)setTimeIntervalInSecond:(NSTimeInterval)timeIntervalInSecond
{
    timeIntervalInSecond_ = timeIntervalInSecond;
    [self saveTimerIntervalInSecond:timeIntervalInSecond];
    
    if (locationManager_) {
        self.locationManager.timeIntervalInSec = timeIntervalInSecond;
    }
}

- (void)setDistanceFilterInMeter:(CLLocationDistance)distanceFilterInMeter
{
    distanceFilterInMeter_ = distanceFilterInMeter;
    [self saveDistanceFilterInMeter:distanceFilterInMeter];
    
    if (locationManager_) {
        self.locationManager.distanceFilterInMeter = distanceFilterInMeter;
    }
}

- (FMELocationManager *)locationManager
{
    if (!locationManager_)
    {
        locationManager_ = [[FMELocationManager alloc] init];
    }
    
    return locationManager_;
}

- (FMEServerNotificationManager *)notificationManager
{
    if (!notificationManager_)
    {
        notificationManager_ = [[FMEServerNotificationManager alloc] init];
    }
    
    return notificationManager_;
}

#pragma mark - Public functions

- (NSTimeInterval)defaultTimeInterval
{
    return kDefaultTimeInterval;
}

- (CLLocationDistance)defaultDistanceFilter
{
    return kDefaultDistanceFilter;
}

- (BOOL)defaultHighPrecisionEnabled
{
    return kDefaultHighPrecisionEnabled;
}

#pragma mark - FMELocationManagerDelegate

- (void)fmeLocationManager:(FMELocationManager *)locationManager
       didUpdateToLocation:(CLLocation *)newLocation
{
    // Update all the tracked topics with the new location
    NSEnumerator * enumerator = [self.trackedTopicNames objectEnumerator];
    if (enumerator)
    {
        NSString * topicName;
        while (topicName = [enumerator nextObject])
        {
            NSLog(@"Updating Topic '%@'", topicName);
            
            [self.notificationManager update:topicName
                                        host:self.host
                                    username:self.username
                                    password:self.password
                                 deviceToken:self.deviceToken
                                    location:newLocation
                              userAttributes:self.userAttributes];
        }
    }
}

#pragma mark - FMESettingsViewControllerDelegate implementation

- (void)settingsViewControllerHostDidChange:(FMESettingsViewController*)controller host:(NSString *)host
{
    self.host = host;
}

- (void)settingsViewControllerUsernameDidChange:(FMESettingsViewController*)controller username:(NSString *)username
{
    self.username = username;
}

- (void)settingsViewControllerPasswordDidChange:(FMESettingsViewController*)controller password:(NSString *)password
{
    self.password = password;
}

- (void)settingsViewControllerSubscribedTopicNamesDidChange:(FMESettingsViewController*)controller topicNames:(NSMutableSet *)topicNames
{
    self.subscribedTopicNames = [topicNames allObjects];
}

- (void)settingsViewControllerTrackedTopicNamesDidChange:(FMESettingsViewController*)controller topicNames:(NSMutableSet *)topicNames
{
    self.trackedTopicNames = [topicNames allObjects];
}

- (void)settingsViewControllerAutoReportLocationValueDidChange:(FMESettingsViewController *)controller autoReportLocation:(BOOL)on
{
    self.reportLocationToTopicsOn = on;
}

- (void)settingsViewControllerHighPrecisionUsedDidChange:(FMESettingsViewController*)controller highPrecisionUsed:(BOOL)used
{
    self.highPrecisionUsed = used;
}

- (void)settingsViewControllerTimeIntervalDidChange:(FMESettingsViewController*)controller timeInterval:(NSTimeInterval)timeInterval
{
    self.timeIntervalInSecond = timeInterval;
}

- (void)settingsViewControllerDistanceFilterDidChange:(FMESettingsViewController*)controller distanceFilter:(CLLocationDistance)distanceFilter
{
    self.distanceFilterInMeter = distanceFilter;
}

- (void)settingsViewController:(FMESettingsViewController *)controller valueDidChange:(NSString *)value forKey:(NSString *)key
{
    [self setUserAttribute:value forName:key];
}

@end
