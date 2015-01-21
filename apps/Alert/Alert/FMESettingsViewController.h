/*============================================================================= 
 
   Name     : FMESettingsViewController.h
 
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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FMEServerAccountViewController.h"
#import "FMETopicsViewController.h"
#import "FMETimeIntervalViewController.h"
#import "FMEDistanceFilterViewController.h"
#import "FMEMessageEditController.h"

@class FMESettingsViewController;

@protocol FMESettingsViewControllerDelegate <NSObject>
@optional
- (void)settingsViewControllerHostDidChange:(FMESettingsViewController*)controller host:(NSString *)host;
- (void)settingsViewControllerUsernameDidChange:(FMESettingsViewController*)controller username:(NSString *)username;
- (void)settingsViewControllerPasswordDidChange:(FMESettingsViewController*)controller password:(NSString *)password;
- (void)settingsViewControllerSubscribedTopicNamesDidChange:(FMESettingsViewController*)controller topicNames:(NSMutableSet *)topicNames;
- (void)settingsViewControllerTrackedTopicNamesDidChange:(FMESettingsViewController*)controller topicNames:(NSMutableSet *)topicNames;
- (void)settingsViewControllerAutoReportLocationValueDidChange:(FMESettingsViewController*)controller autoReportLocation:(BOOL)on;
- (void)settingsViewControllerHighPrecisionUsedDidChange:(FMESettingsViewController*)controller highPrecisionUsed:(BOOL)used;
- (void)settingsViewControllerTimeIntervalDidChange:(FMESettingsViewController*)controller timeInterval:(NSTimeInterval)timeInterval;
- (void)settingsViewControllerDistanceFilterDidChange:(FMESettingsViewController*)controller distanceFilter:(CLLocationDistance)distanceFilter;
- (void)settingsViewController:(FMESettingsViewController*)controller valueDidChange:(NSString *)value forKey:(NSString *)key;
@end

@interface FMESettingsViewController : UITableViewController <UIActionSheetDelegate,
                                                              FMEServerAccountViewControllerDelegate,
                                                              FMETopicsViewControllerDelegate,
                                                              FMETimeIntervalViewControllerDelegate,
                                                              FMEDistanceFilterViewControllerDelegate,
                                                              FMEServerNotificationManagerDelegate,
                                                              FMEMessageEditControllerDelegate>

@property (nonatomic, copy)   NSString *          host;
@property (nonatomic, copy)   NSString *          username;
@property (nonatomic, copy)   NSString *          password;
@property (nonatomic, copy)   NSString *          deviceToken;
@property (nonatomic, retain) NSMutableSet *      subscribedTopicNames;
@property (nonatomic, retain) NSMutableSet *      trackedTopicNames;
@property (nonatomic)         BOOL                autoReportLocationOn;
@property (nonatomic)         BOOL                highPrecisionUsed;
@property (nonatomic)         NSTimeInterval      timeInterval;
@property (nonatomic)         CLLocationDistance  distanceFilter;
@property (nonatomic, retain) CLLocation *        location; 

@property (nonatomic)         NSTimeInterval      defaultTimeInterval;
@property (nonatomic)         CLLocationDistance  defaultDistanceFilter;

@property (nonatomic, weak)   id<FMESettingsViewControllerDelegate> delegate;

// Set it to YES to list all topics in the location tracking section.
@property (nonatomic)         BOOL                listAllTopics;

@property (nonatomic, retain) NSDictionary *      userAttributes;

@property (copy,     nonatomic)       NSString                     * firstNameKey;
@property (copy,     nonatomic)       NSString                     * lastNameKey;
@property (copy,     nonatomic)       NSString                     * emailKey;
@property (copy,     nonatomic)       NSString                     * subjectKey;
@property (copy,     nonatomic)       NSString                     * webAddressKey;
@property (copy,     nonatomic)       NSString                     * detailsKey;
@property (copy,     nonatomic)       NSString                     * detailsTypeKey;


+ (void)showHostUnreachableAlertView;

@end
