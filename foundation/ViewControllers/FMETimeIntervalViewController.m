/*============================================================================= 
 
   Name     : FMETimeIntervalViewController.m
 
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

#import "FMETimeIntervalViewController.h"

static const NSInteger kMinuteComponent = 0;
static const NSInteger kSecondComponent = 1;

@interface FMETimeIntervalViewController ()
@property (weak, nonatomic) IBOutlet UITextView *description;
@end

@implementation FMETimeIntervalViewController
@synthesize description = description_;
@synthesize timeIntervalPicker = timeIntervalPicker_;
@synthesize delegate = delegate_;
@synthesize minute = minute_;
@synthesize second = second_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationItem) {
        self.navigationItem.title = NSLocalizedString(@"Time Interval", nil);
    }

    self.description.text = NSLocalizedString(@"Set a time interval", @"Time Interval View Controller - Description");
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.timeIntervalPicker selectRow:self.minute
                           inComponent:kMinuteComponent
                              animated:NO];
    
    [self.timeIntervalPicker selectRow:self.second
                           inComponent:kSecondComponent
                              animated:NO];

    self.description.hidden =
       (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidUnload
{
    [self setDelegate:nil];
    [self setTimeIntervalPicker:nil];
    [self setDescription:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.description.hidden = YES;
    }
    else 
    {
        self.description.hidden = NO;
    }
}

#pragma mark - Properties

- (void)setMinute:(NSInteger)minute
{
    minute_ = minute;
    [self.timeIntervalPicker selectRow:self.minute inComponent:kMinuteComponent animated:YES];
}

- (void)setSecond:(NSInteger)second
{
    second_ = second;
    [self.timeIntervalPicker selectRow:self.second inComponent:kSecondComponent animated:YES];
}

#pragma mark - UIPickerViewDataSource protocol implementation

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;   // Column 0: Minute; Column 1: Second
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{   
    switch (component)
    {
        case kMinuteComponent: return 61;   // minute
        case kSecondComponent: return 60;   // second
        default: return 0;                  // invalid component
    }
}

#pragma mark - UIPickerViewDelegate protocol implementation

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case kMinuteComponent: return (row == 1) ? NSLocalizedString(@"1 Min", @"1 Min") : [NSString stringWithFormat:NSLocalizedString(@"%i Mins", @"%i Mins"), row];
        case kSecondComponent: return (row == 1) ? NSLocalizedString(@"1 Sec", @"1 Sec") : [NSString stringWithFormat:NSLocalizedString(@"%i Secs", @"%i Secs"), row];
        default: return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{   
    if (self.timeIntervalPicker != pickerView)
    {
        return;
    }
    
    if (component == kMinuteComponent)
    {
        minute_ = row;
    }
    else 
    {
        second_ = row;
    }
//    
//    if (self.minute == 0 && self.second == 0)
//    {
//        // The minimum time interval is 1 second
//        self.second = 1;
//        [pickerView selectRow:self.second inComponent:kSecondComponent animated:YES];
//    }
//    else if (self.minute == 60 && self.second != 0)
//    {
//        // The maximum time interval is 60 minutes
//        self.second = 0;
//        [pickerView selectRow:self.second inComponent:kSecondComponent animated:YES];
//    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeIntervalDidChange:)])
    {
        NSTimeInterval timeInterval = (self.minute * 60) + self.second;
        [self.delegate timeIntervalDidChange:timeInterval];
    }    
}

@end
