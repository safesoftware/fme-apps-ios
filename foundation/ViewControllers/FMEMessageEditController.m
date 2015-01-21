/*============================================================================= 
 
   Name     : FMEMessageEditController.m
 
   System   : FME Reporter
 
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

#import "FMEMessageEditController.h"

static NSString * kDetailsType  = @"text/plain";

@interface FMEMessageEditController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic) BOOL hasDetails;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *webAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (retain, nonatomic) NSTimer * headerMessageTimer;
- (void)hideTableHeaderView;

@end

@implementation FMEMessageEditController

@synthesize firstNameLabel  = firstNameLabel_;
@synthesize lastNameLabel   = lastNameLabel_;
@synthesize emailLabel      = emailLabel_;
@synthesize subjectLabel    = subjectLabel_;
@synthesize webAddressLabel = webAddressLabel_;
@synthesize detailsLabel    = detailsLabel_;
@synthesize firstNameKey    = firstNameKey_;
@synthesize lastNameKey     = lastNameKey_;
@synthesize emailKey        = emailKey_;
@synthesize subjectKey      = subjectKey_;
@synthesize webAddressKey   = webAddressKey_;
@synthesize detailsKey      = detailsKey_;
@synthesize detailsTypeKey  = detailsTypeKey_;
@synthesize delegate        = delegate_;
@synthesize headerMessage   = headerMessage_;
@synthesize headerMessageTimer = headerMessageTimer_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.firstName.delegate  = self;
    self.lastName.delegate   = self;
    self.email.delegate      = self;
    self.subject.delegate    = self;
    self.details.delegate    = self;
    self.webAddress.delegate = self;
        
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(messageEditControllerViewDidLoad:)])
    {
        [self.delegate messageEditControllerViewDidLoad:self];
    }
}

- (void)setHeaderMessage:(NSString *)headerMessage
{
    headerMessage_ = headerMessage;
    
    UILabel * headerView = nil;
    if (headerMessage)
    {
        // Use 0 height and animate the height below
        headerView                  = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 0.0f)];
        headerView.textAlignment    = NSTextAlignmentCenter;
        headerView.numberOfLines    = 2;
        headerView.text             = headerMessage_;
        headerView.font             = [UIFont fontWithName:@"Baskerville-Bold" size:17];
        headerView.textColor        = [UIColor darkGrayColor];
        headerView.backgroundColor  = [UIColor colorWithWhite:0.8f alpha:0.7f];
    }
    
    // Invalidate the previous timer if present so that we won't hide the
    // new header with the previous timer.
    if (self.headerMessageTimer)
    {
        [self.headerMessageTimer invalidate];
    }
    
    // Assigning a new header
    self.tableView.tableHeaderView = headerView;
    
    if (headerView)
    {
        CGRect visibleFrame = headerView.frame;
        visibleFrame.size.height = 60.0f;

        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            headerView.frame = visibleFrame;
        } completion:^(BOOL finished) {
            self.headerMessageTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                       target:self
                                                                     selector:@selector(hideTableHeaderView)
                                                                     userInfo:nil
                                                                      repeats:NO];
        }];
    }
}

- (void)hideTableHeaderView
{
    if (!self.tableView.tableHeaderView)
    {
        return;
    }
    
    // NOTE: Unable to decrease the height to reverse the animation. Only
    // alpha animation seems to work here.
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.tableHeaderView.alpha = 0.0f;
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString * key;
    if (textField == self.firstName)       key = self.firstNameKey;
    else if (textField == self.lastName)   key = self.lastNameKey;
    else if (textField == self.email)      key = self.emailKey;
    else if (textField == self.subject)    key = self.subjectKey;
    else if (textField == self.webAddress) key = self.webAddressKey;
    else if (textField == self.details)    key = self.detailsKey;
    else                                   key = nil;

    // Notify the delegate
    if (textField.text.length == 0)
    {
        // Since the fields are optional, when they are empty, we should set them
        // to nil to indicate that they are not set.
        [self valueDidChange:nil forKey:key];
 
        // Remove the details type if the details is empty
        if (textField == self.details)
        {
            [self valueDidChange:nil  forKey:self.detailsTypeKey];
        }
    }
    else
    {
        [self valueDidChange:textField.text forKey:key];
        
        // Add the details type if the details is not empty
        if (textField == self.details)
        {
            [self valueDidChange:kDetailsType  forKey:self.detailsTypeKey];
        }
    }
}

- (void)valueDidChange:(NSString *)value forKey:(NSString *)key
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(messageEditController:valueDidChange:forKey:)] &&
        key)
    {
        [self.delegate messageEditController:self valueDidChange:value forKey:key];
    }
}

@end
