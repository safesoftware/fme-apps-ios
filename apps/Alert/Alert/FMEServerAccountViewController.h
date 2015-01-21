/*============================================================================= 
 
   Name     : FMEServerAccountViewController.h
 
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
#import "FMEServerNotificationManager.h"

@class FMEServerAccountViewController;

@protocol FMEServerAccountViewControllerDelegate <NSObject>
@optional
- (void)serverAccountViewControllerDidCancel:(FMEServerAccountViewController *)serverAccountViewController;
- (void)serverAccountViewControllerDidFinish:(FMEServerAccountViewController *)serverAccountViewController;
@end

@interface FMEServerAccountViewController : UITableViewController <UITextFieldDelegate>

// The host, username, and password properties initialize the textfields. When
// the user taps Save, these properties will have the values from the textfields.
@property (nonatomic, copy)            NSString        * host;
@property (nonatomic, copy)            NSString        * username;
@property (nonatomic, copy)            NSString        * password;
@property (nonatomic, retain)          UIView          * centerBottomCustomView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * saveButton;

@property (nonatomic, weak)   id<FMEServerAccountViewControllerDelegate> delegate;

@end
