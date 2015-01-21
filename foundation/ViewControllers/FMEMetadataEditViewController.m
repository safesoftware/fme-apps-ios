/*============================================================================= 
 
   Name     : FMEMetadataEditViewController.m
 
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

#import "FMEMetadataEditViewController.h"

static NSString * kEmptyString = @"";

// Section Indexes
static const NSUInteger kMetadataSectionIndex = 0;

#pragma mark - Private Declaration

@interface FMEMetadataEditViewController ()

// Private Properties
@property (nonatomic, weak) IBOutlet UITextField     * keyTextField;
@property (nonatomic, weak) IBOutlet UITextField     * valueTextField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * centerBottomButton;
@property (nonatomic, weak) IBOutlet UILabel         * keyLabel;
@property (nonatomic, weak) IBOutlet UILabel         * valueLabel;

// IBAction
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


#pragma mark - FMEMetadataEditViewController Implementation

@implementation FMEMetadataEditViewController

@synthesize key                    = key_;
@synthesize value                  = value_;
@synthesize centerBottomCustomView = centerBottomCustomView_;
@synthesize delegate               = delegate_;
@synthesize cancelButton           = cancelButton_;
@synthesize saveButton             = saveButton_;
@synthesize keyTextField           = keyTextField_;
@synthesize valueTextField         = valueTextField_;
@synthesize centerBottomButton     = centerBottomButton_;
@synthesize keyLabel               = keyLabel_;
@synthesize valueLabel             = valueLabel_;

#pragma mark - View life cycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        key_ = nil;
        value_ = nil;
        delegate_ = nil;
        centerBottomCustomView_ = nil;
    }
    return self;   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.keyLabel.text   = NSLocalizedString(@"Key"  , @"FME Metadata Edit View Controller - Key Prompt");
    self.valueLabel.text = NSLocalizedString(@"Value", @"FME Metadata Edit View Controller - Value Prompt");
    
    self.cancelButton.title = NSLocalizedString(@"Cancel"  , @"FME Metadata Edit View Controller - Cancel Button Title");
    self.saveButton.title   = NSLocalizedString(@"Save"    , @"FME Metadata Edit View Controller - Save Button Title");

    // Display account information
    self.keyTextField.text   = (self.key)   ? self.key   : kEmptyString;
    self.valueTextField.text = (self.value) ? self.value : kEmptyString;
    
    if (self.centerBottomCustomView)
    {
        self.centerBottomButton.customView = self.centerBottomCustomView;
    }
}

- (void)viewDidUnload
{
    [self setKeyTextField:nil];
    [self setValueTextField:nil];
    [self setDelegate:nil];
    [self setCancelButton:nil];
    [self setSaveButton:nil];
    [self setCenterBottomButton:nil];
    [self setKeyLabel:nil];
    [self setValueLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Properties

- (NSString *)key
{
    return self.keyTextField.text;
}

- (void)setKey:(NSString *)key
{
    self.keyTextField.text = key;
    key_ = key;
}

- (NSString *)value
{
    return self.valueTextField.text;
}

- (void)setValue:(NSString *)value
{
    self.valueTextField.text = value;
    value_ = value;
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(metadataEditViewControllerDidCancel:)])
    {
        [self.delegate metadataEditViewControllerDidCancel:self];
    }
}

- (IBAction)save:(id)sender
{   
    // Copy the text from the UI to the public variables
    self.key   = self.keyTextField.text;
    self.value = self.valueTextField.text;

    // Dismiss the keyboard. We don't know which one text field has the focus
    // and don't spend time to find the one. Just simply resign the first
    // responder from all the text fields since we only have 2 text fields.
    [self.keyTextField   resignFirstResponder];
    [self.valueTextField resignFirstResponder];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(metadataEditViewControllerDidFinish:)])
    {
        [self.delegate metadataEditViewControllerDidFinish:self];
    }
}

#pragma mark - UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDataSource implementation


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (tableView != self.tableView)
//    {
//        return @"";
//    }
//    
//    switch (section)
//    {
//    case kAccountInformationSectionIndex:
//        return NSLocalizedString(@"FME Server Account Information", 
//                                 @"FME Server Account View Controller - FME Server Account Information Section Name");
//    default:
//        return @"";
//    }
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    if (tableView != self.tableView)
//    {
//        return @"";
//    }
//    
//    switch (section)
//    {
//    case kAccountInformationSectionIndex:
//        return NSLocalizedString(@"Previous subscriptions will be removed.", 
//                                 @"FME Server Account View Controller - Section Footer");
//    default:
//        return @"";        
//    }
//}

@end
