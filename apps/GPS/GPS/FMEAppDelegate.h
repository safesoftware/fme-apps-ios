/*============================================================================= 
 
   Name     : FMEAppDelegate.h 
 
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

#import <UIKit/UIKit.h>

@class FMEViewController;

#import <UIKit/UIKit.h>
#import "FMELocationManager.h"
#import "FMEServerNotificationManager.h"
#import "FMESettingsViewController.h"

@class FMEAppDelegate;

extern FMEAppDelegate * appDelegate;

@interface FMEAppDelegate : UIResponder <UIApplicationDelegate,
                                         FMESettingsViewControllerDelegate,
                                         FMELocationManagerDelegate>

@property (strong,   nonatomic)       UIWindow                     * window;
@property (readonly, nonatomic)       NSTimeInterval                 defaultTimeInterval;
@property (readonly, nonatomic)       CLLocationDistance             defaultDistanceFilter;
@property (readonly, nonatomic)       BOOL                           defaultHighPrecisionEnabled;
@property (retain,   nonatomic)       FMELocationManager           * locationManager;
@property (retain,   nonatomic)       FMEServerNotificationManager * notificationManager;

@property (copy,     nonatomic)       NSString                     * host;
@property (copy,     nonatomic)       NSString                     * username;
@property (copy,     nonatomic)       NSString                     * password;
@property (retain,   nonatomic)       NSArray                      * trackedTopicNames;
@property (          nonatomic)       BOOL                           autoReportLocationOn;
@property (          nonatomic)       BOOL                           highPrecisionUsed;
@property (          nonatomic)       NSTimeInterval                 timeIntervalInSecond;
@property (          nonatomic)       CLLocationDistance             distanceFilterInMeter;

@property (copy,     nonatomic)       NSString                     * firstNameKey;
@property (copy,     nonatomic)       NSString                     * lastNameKey;
@property (copy,     nonatomic)       NSString                     * emailKey;
@property (copy,     nonatomic)       NSString                     * subjectKey;
@property (copy,     nonatomic)       NSString                     * webAddressKey;
@property (copy,     nonatomic)       NSString                     * detailsKey;
@property (copy,     nonatomic)       NSString                     * detailsTypeKey;

@property (retain,   nonatomic, readonly)  NSDictionary            * userAttributes;

- (void)setUserAttribute:(NSObject *)value forName:(NSString *)name;

@end
