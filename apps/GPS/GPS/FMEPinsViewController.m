/*============================================================================= 
 
   Name     : FMEPinsViewController.m
 
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

#import "FMEPinsViewController.h"

@interface FMEPinsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *description;

@end

@implementation FMEPinsViewController
@synthesize description = description_;
@synthesize numPinsPicker = numPinsPicker_;
@synthesize delegate = delegate_;
@synthesize numPins = numPins_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.numPinsPicker selectRow:(self.numPins / 10) inComponent:0 animated:NO];
    
    self.description.hidden =
       (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidUnload
{
    [self setNumPinsPicker:nil];
    [self setDelegate:nil];
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

#pragma mark - UIPickerViewDataSource protocol implementation

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{   
    return 11; // Don't show any pins, Show the last 10 pins, Show the last 20 pins, ... Show the last 100 pins
}

#pragma mark - UIPickerViewDelegate protocol implementation

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row)
    {
        case 0: return NSLocalizedString(@"Don't show any pins", @"Don't show any pins");
        default: return [NSString stringWithFormat:NSLocalizedString(@"Show the last %i pins", @"Show the last %i pins"), row * 10];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{   
    if (self.numPinsPicker != pickerView)
    {
        return;
    }
    
    if (self.delegate)
    {
        [self.delegate numberOfPinsDidChange:row * 10];
    }
}

@end
