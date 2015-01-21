/*============================================================================= 
 
   Name     : FMEServerAccountViewController.m
 
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

#import "FMEServerAccountViewController.h"

static NSString * kEmptyString = @"";

// Section Indexes
static const NSUInteger kAccountInformationSectionIndex = 0;

#pragma mark - Private Declaration

@interface FMEServerAccountViewController ()

// Private Properties
@property (nonatomic, weak) IBOutlet UITextField     * hostTextField;
@property (nonatomic, weak) IBOutlet UITextField     * usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField     * passwordTextField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * centerBottomButton;
@property (nonatomic, weak) IBOutlet UILabel         * hostLabel;
@property (nonatomic, weak) IBOutlet UILabel         * usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel         * passwordLabel;

// IBAction
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


#pragma mark - FMEServerAccountViewController Implementation

@implementation FMEServerAccountViewController

@synthesize host                   = host_;
@synthesize username               = username_;
@synthesize password               = password_;
@synthesize centerBottomCustomView = centerBottomCustomView_;
@synthesize delegate               = delegate_;
@synthesize cancelButton           = cancelButton_;
@synthesize saveButton             = saveButton_;
@synthesize hostTextField          = hostTextField_;
@synthesize usernameTextField      = usernameTextField_;
@synthesize passwordTextField      = passwordTextField_;
@synthesize centerBottomButton     = centerBottomButton_;
@synthesize hostLabel              = hostLabel_;
@synthesize usernameLabel          = usernameLabel_;
@synthesize passwordLabel          = passwordLabel_;

#pragma mark - View life cycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        host_ = nil;
        username_ = nil;
        password_ = nil;
        delegate_ = nil;
        centerBottomCustomView_ = nil;
    }
    return self;   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationItem) {
        self.navigationItem.title = NSLocalizedString(@"Account", nil);
    }
    
    self.hostLabel.text     = NSLocalizedString(@"Host"    , @"FME Server Account View Controller - Host Prompt");
    self.usernameLabel.text = NSLocalizedString(@"Username", @"FME Server Account View Controller - Username Prompt");
    self.passwordLabel.text = NSLocalizedString(@"Password", @"FME Server Account View Controller - Password Prompt");
    self.cancelButton.title = NSLocalizedString(@"Cancel"  , @"FME Server Account View Controller - Cancel Button Title");
    self.saveButton.title   = NSLocalizedString(@"Save"    , @"FME Server Account View Controller - Save Button Title");

    // Display account information
    self.hostTextField.text     = (self.host)     ? self.host     : kEmptyString;
    self.usernameTextField.text = (self.username) ? self.username : kEmptyString;
    self.passwordTextField.text = (self.password) ? self.password : kEmptyString;
    
    if (self.centerBottomCustomView)
    {
        self.centerBottomButton.customView = self.centerBottomCustomView;
    }
}

- (void)viewDidUnload
{
    [self setHostTextField:nil];
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setDelegate:nil];
    [self setCancelButton:nil];
    [self setSaveButton:nil];
    [self setCenterBottomButton:nil];
    [self setHostLabel:nil];
    [self setUsernameLabel:nil];
    [self setPasswordLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(serverAccountViewControllerDidCancel:)])
    {
        [self.delegate serverAccountViewControllerDidCancel:self];
    }
}

- (IBAction)save:(id)sender
{   
    // Copy the text from the UI to the public variables
    self.host     = self.hostTextField.text;
    self.username = self.usernameTextField.text;
    self.password = self.passwordTextField.text;

    // Dismiss the keyboard. We don't know which one text field has the focus
    // and don't spend time to find the one. Just simply resign the first
    // responder from all the text fields since we only have 3 text fields.
    [self.hostTextField     resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(serverAccountViewControllerDidFinish:)])
    {
        [self.delegate serverAccountViewControllerDidFinish:self];
    }
}

#pragma mark - UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDataSource implementation


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView != self.tableView)
    {
        return @"";
    }
    
    switch (section)
    {
    case kAccountInformationSectionIndex:
        return NSLocalizedString(@"FME Server Account Information", 
                                 @"FME Server Account View Controller - FME Server Account Information Section Name");
    default:
        return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (tableView != self.tableView)
    {
        return @"";
    }
    
    switch (section)
    {
    case kAccountInformationSectionIndex:
        return NSLocalizedString(@"Previous subscriptions will be removed.", 
                                 @"FME Server Account View Controller - Section Footer");
    default:
        return @"";        
    }
}

@end
