/*============================================================================= 
 
   Name     : FMEAppDelegate.m 
 
   System   : FME Reporter iOS App
 
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
#import "FMEServerAccountViewController.h"
#import "FMEServerNotificationManager.h"

static NSString * const kUserDefaultsKeyHost                   = @"Host";
static NSString * const kUserDefaultsKeyUsername               = @"Username";
static NSString * const kUserDefaultsKeyPassword               = @"Password";
static NSString * const kUserDefaultsKeyTrackedTopicNames      = @"Tracked Topic Names";
static NSString * const kUserDefaultsKeyAutoReportLocation     = @"Auto Report Location On";
static NSString * const kUserDefaultsKeyHighPrecisionEnabled   = @"High Precision Enabled";
static NSString * const kUserDefaultsKeyTimeIntervalInSecond   = @"Time Interval In Second";
static NSString * const kUserDefaultsKeyDistanceFilterInMeter  = @"Distance Filter In Meter";
static NSString * const kUserDefaultsKeyDeviceToken            = @"Device Token";

static NSString * const kUserDefaultsKeySubscription           = @"Subscription";
static NSString * const kUserDefaultsKeyTopics                 = @"Topics";

static NSString * const kUserDefaultsKeyUserAttributes         = @"UserAttributes";

static NSString * const kJSONFristNameKey                      = @"msg_first_name";
static NSString * const kJSONLastNameKey                       = @"msg_last_name";
static NSString * const kJSONEmailKey                          = @"msg_from";
static NSString * const kJSONSubjectKey                        = @"msg_subject";
static NSString * const kJSONWebAddressKey                     = @"msg_url";
static NSString * const kJSONDetailsKey                        = @"msg_content";
static NSString * const kJSONDetailsTypeKey                    = @"msg_content_type";


static const NSTimeInterval     kDefaultTimeInterval          = 60;   // secs
static const CLLocationDistance kDefaultDistanceFilter        = 500;  // meters
static const BOOL               kDefaultAutoReportLocationOn  = YES;
static const BOOL               kDefaultHighPrecisionEnabled  = NO;


// APN
static NSString * const kApnKeyAlert = @"alert";
static NSString * const kApnKeyAps   = @"aps";

FMEAppDelegate * appDelegate = nil;

@interface FMEAppDelegate ()
@property (copy  , nonatomic) NSString            * deviceToken;
@property (retain, nonatomic) NSMutableDictionary * userAttributesMutable;
- (void)initUserDefaults;
- (void)initLocationManager;
- (void)saveObject:(NSObject *)string forKey:(NSString *)key;
- (NSString *)restoreStringForKey:(NSString *)key;
- (NSDictionary *)restoreDictionaryForKey:(NSString *)key;
- (void)saveHost:(NSString *)host;
- (NSString *)restoreHost;
- (void)saveUsername:(NSString *)username;
- (NSString *)restoreUsername;
- (void)savePassword:(NSString *)password;
- (NSString *)restorePassword;
- (void)saveTrackedTopicNames:(NSArray *)trackedTopicNames;
- (NSArray *)restoreTrackedTopicNames;
- (void)saveAutoReportLocationOn:(BOOL)on;
- (BOOL)restoreAutoReportLocationOn;
- (void)saveHighPrecisionUsed:(BOOL)used;
- (BOOL)restoreHighPrecisionUsed;
- (void)saveTimerIntervalInSecond:(NSInteger)seconds;
- (NSInteger)restoreTimerIntervalInSecond;
- (void)saveDistanceFilterInMeter:(double)meters;
- (double)restoreDistanceFilterInMeter;
- (void)saveDeviceToken:(NSString *)deviceToken;
- (NSString *)restoreDeviceToken;
@end


@implementation FMEAppDelegate

@synthesize window                = window_;
@synthesize deviceToken           = deviceToken_;
@synthesize locationManager       = locationManager_;
@synthesize notificationManager   = notificationManager_;
@synthesize host                  = host_;
@synthesize username              = username_;
@synthesize password              = password_;
@synthesize trackedTopicNames     = trackedTopicNames_;
@synthesize autoReportLocationOn  = autoReportLocationOn_;
@synthesize highPrecisionUsed     = highPrecisionUsed_;
@synthesize timeIntervalInSecond  = timeIntervalInSecond_;
@synthesize distanceFilterInMeter = distanceFilterInMeter_;
@synthesize firstNameKey          = firstNameKey_;
@synthesize lastNameKey           = lastNameKey_;
@synthesize emailKey              = emailKey_;
@synthesize subjectKey            = subjectKey_;
@synthesize webAddressKey         = webAddressKey_;
@synthesize detailsKey            = detailsKey_;
@synthesize detailsTypeKey        = detailsTypeKey_;
@synthesize userAttributesMutable = userAttributesMutable_;

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

- (NSString *)restoreStringForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

- (void)saveHost:(NSString *)host {
    [self saveObject:host forKey:kUserDefaultsKeyHost];
}

- (NSDictionary *)restoreDictionaryForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
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

- (void)saveTrackedTopicNames:(NSArray *)trackedTopicNames {
    [self saveObject:trackedTopicNames forKey:kUserDefaultsKeyTrackedTopicNames];
}

- (NSArray *)restoreTrackedTopicNames {
    return [[NSUserDefaults standardUserDefaults] stringArrayForKey:kUserDefaultsKeyTrackedTopicNames];
}

- (void)saveAutoReportLocationOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kUserDefaultsKeyAutoReportLocation];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

- (BOOL)restoreAutoReportLocationOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyAutoReportLocation];
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
                                                             [NSNumber numberWithBool:kDefaultAutoReportLocationOn], kUserDefaultsKeyAutoReportLocation,
                                                             [NSNumber numberWithBool:kDefaultHighPrecisionEnabled], kUserDefaultsKeyHighPrecisionEnabled,
                                                             kDefaultTimeInterval,         kUserDefaultsKeyTimeIntervalInSecond,
                                                             kDefaultDistanceFilter,       kUserDefaultsKeyDistanceFilterInMeter,
                                                             nil]];
    
    self.host                  = [self restoreHost];
    self.username              = [self restoreUsername];
    self.password              = [self restorePassword];
    self.autoReportLocationOn  = [self restoreAutoReportLocationOn];
    self.highPrecisionUsed     = [self restoreHighPrecisionUsed];
    self.timeIntervalInSecond  = [self restoreTimerIntervalInSecond];
    self.distanceFilterInMeter = [self restoreDistanceFilterInMeter];
    self.deviceToken           = [self restoreDeviceToken];
    self.userAttributesMutable = [[NSMutableDictionary alloc] initWithDictionary:
                                  [self restoreDictionaryForKey:kUserDefaultsKeyUserAttributes]];
    
    // If both the time interval and the distance filter are zero, we will set
    // the distance filter to the default.
    if (self.timeIntervalInSecond <= 0 &&
        (self.distanceFilterInMeter == 0 || self.distanceFilterInMeter == kCLDistanceFilterNone))
    {
        self.distanceFilterInMeter = self.defaultDistanceFilter;
    }
    
    self.trackedTopicNames     = [self restoreTrackedTopicNames];
}

- (void)initLocationManager
{
    self.locationManager.delegate              = self;
    self.locationManager.highPrecisionEnabled = self.highPrecisionUsed; 
    self.locationManager.timeIntervalInSec     = self.timeIntervalInSecond;
    self.locationManager.distanceFilterInMeter = self.distanceFilterInMeter;
    
    // If we have tracked topics, start the location tracking now
    NSArray * trackedTopics = [self restoreTrackedTopicNames];
    if (trackedTopics && trackedTopics.count > 0 && self.autoReportLocationOn)
    {
        [self.locationManager startLocationTracking];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize variables
    appDelegate      = self;
    locationManager_ = nil;
    [self initUserDefaults];
    [self initLocationManager];
    
    if (self.host && self.host.length > 0 && ![FMEServerNotificationManager isHostReachable:self.host])
    {
        [FMESettingsViewController showHostUnreachableAlertView];
    }
    
    return YES;
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

#pragma mark - Public properties

- (NSDictionary *)userAttributes
{
    return self.userAttributesMutable;
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

- (void)setTrackedTopicNames:(NSArray *)trackedTopicNames
{
    trackedTopicNames_ = trackedTopicNames;
    [self saveTrackedTopicNames:trackedTopicNames];
    
    // We need to start location tracking if there are topics now, or
    // we need to stop location tracking if there are no topics now.
    if (trackedTopicNames && trackedTopicNames.count > 0) {
        if (locationManager_ && !self.locationManager.trackingLocation && self.autoReportLocationOn) {
            [self.locationManager startLocationTracking];
        }
    }
    else {
        if (locationManager_ && self.locationManager.trackingLocation) {
            [self.locationManager stopLocationTracking];
        }
    }
}

- (void)setAutoReportLocationOn:(BOOL)autoReportLocationOn
{
    autoReportLocationOn_ = autoReportLocationOn;
    [self saveAutoReportLocationOn:autoReportLocationOn];
    
    if (locationManager_) {
        if (autoReportLocationOn && !self.locationManager.trackingLocation &&
            self.trackedTopicNames && self.trackedTopicNames.count > 0) {
            [self.locationManager startLocationTracking];
        }
        else if (!autoReportLocationOn && self.locationManager.trackingLocation) {
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
            
            [self.notificationManager report:topicName 
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
    // Ignore subscribed topics since this app doesn't require topic subscription
}

- (void)settingsViewControllerTrackedTopicNamesDidChange:(FMESettingsViewController*)controller topicNames:(NSMutableSet *)topicNames
{
    self.trackedTopicNames = [topicNames allObjects];
}

- (void)settingsViewControllerAutoReportLocationValueDidChange:(FMESettingsViewController*)controller autoReportLocation:(BOOL)on
{
    self.autoReportLocationOn = on;
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


@end
