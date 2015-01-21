/*============================================================================= 
 
   Name     : FMEAboutViewController.m
 
   System   : FME Alert
 
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

#import "FMEAboutViewController.h"

static const NSInteger kVersionSectionIndex                 = 0;
static const NSInteger kAboutSectionIndex                   = 1;
static const NSInteger kAboutSafeHomepageRowIndex           = 0;
static const NSInteger kAboutFMEServerHomepageRowIndex      = 1;
static const NSInteger kAboutNotificationServiceURLRowIndex = 2;
static const NSInteger kAboutTermsRowIndex                  = 3;

@interface FMEAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *safeSoftwareHomepageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fmeServerLinkHomepageLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationServiceLinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionNumberLabel;

@end

@implementation FMEAboutViewController
@synthesize versionLabel = versionLabel_;
@synthesize safeSoftwareHomepageLabel = safeSoftwareHomepageLabel_;
@synthesize fmeServerLinkHomepageLabel = fmeServerLinkHomepageLabel_;
@synthesize notificationServiceLinkLabel = notificationServiceLinkLabel_;
@synthesize versionNumberLabel = versionNumberLabel_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.versionLabel.text = NSLocalizedString(@"Version", @"About - Version Label");
    NSString * shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionNumberLabel.text = [NSString stringWithFormat:@"%@.%@", shortVersion, version];
    
    self.safeSoftwareHomepageLabel.text = NSLocalizedString(
        @"Safe Software Homepage", 
        @"About - Safe Software Homepage Label");
    self.fmeServerLinkHomepageLabel.text = NSLocalizedString(
        @"FME Server Homepage", 
        @"About - FME Server Homepage Label");
    self.notificationServiceLinkLabel.text = NSLocalizedString(
        @"FME Server Notification Service",
        @"About - FME Server Notification Service Homepage Label");
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setVersionLabel:nil];
    [self setSafeSoftwareHomepageLabel:nil];
    [self setFmeServerLinkHomepageLabel:nil];
    [self setNotificationServiceLinkLabel:nil];
    [self setVersionNumberLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    switch (section) 
//    {
//        case kVersionSectionIndex:
//            return NSLocalizedString(@"Powered by FME Server", @"About - Powered by FME Server Footer Title");
//        case kAboutSectionIndex:
//            return NSLocalizedString(@"Copyright", @"About - Copyright Information Footer Title");
//        default:
//            return @"";
//    }
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kAboutSectionIndex)
    {
        if (indexPath.row == kAboutSafeHomepageRowIndex)
        {
            NSURL * url = [NSURL URLWithString:@"http://www.safe.com"];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (indexPath.row == kAboutFMEServerHomepageRowIndex)
        {
            NSURL * url = [NSURL URLWithString:@"http://fme.ly/2du"];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (indexPath.row == kAboutNotificationServiceURLRowIndex)
        {
            NSURL * url = [NSURL URLWithString:@"http://fme.ly/dpd"];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (indexPath.row == kAboutTermsRowIndex)
        {
            NSURL * url = [NSURL URLWithString:@"http://www.safe.com/terms-and-conditions/mobile-applications/"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)close:(id)sender {
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
