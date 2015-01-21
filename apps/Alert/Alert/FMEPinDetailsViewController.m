/*============================================================================= 
 
   Name     : FMEPinDetailsViewController.m
 
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

#import <MapKit/MapKit.h>
#import "FMEPinDetailsViewController.h"
#import "FMEMapViewController.h"

static NSString * kTitleKey     = @"title";
static NSString * kDetailsKey   = @"details";
static NSString * kDateKey      = @"date";
static NSString * kLatitudeKey  = @"latitude";
static NSString * kLongitudeKey = @"longitude";

// Segues
static NSString * kSegueShowDetailsMap = @"ShowDetailsMap";

@interface FMEPinDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel    * titleLabel;
@property (weak, nonatomic) IBOutlet UITextView * detailsTextView;
@property (weak, nonatomic) IBOutlet UILabel    * dateLabel;
@property (weak, nonatomic) IBOutlet UILabel    * locationLabel;
@property (weak, nonatomic) IBOutlet MKMapView  * mapView;
@end

@implementation FMEPinDetailsViewController
@synthesize titleLabel = titleLabel_;
@synthesize detailsTextView = detailsTextView_;
@synthesize dateLabel = dateLabel_;
@synthesize locationLabel = locationLabel_;
@synthesize title = title_;
@synthesize details = details_;
@synthesize date = date_;
@synthesize location = location_;
@synthesize messages = messages_;
@synthesize messageIndex = messageIndex_;
@synthesize mapView = mapView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationItem) {
        self.navigationItem.title = NSLocalizedString(@"Details", nil);
    }

    self.titleLabel.text = self.title;
    if (!self.titleLabel.text || self.titleLabel.text.length == 0) {
        self.titleLabel.text = NSLocalizedString(@"<New Alert>", nil);
    }
    
    self.detailsTextView.text = self.details;
    self.dateLabel.text = self.date;
    self.locationLabel.text = self.location;

    // If there is no location, we should hide the map button
    if (!self.location || self.location.length == 0) {
        self.mapView.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setLocationLabel:nil];
    [self setDetailsTextView:nil];
    [self setDateLabel:nil];
    [self setTitle:nil];
    [self setLocation:nil];
    [self setDetails:nil];
    [self setDate:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kSegueShowDetailsMap]) 
    {
        FMEMapViewController * mapViewController = (FMEMapViewController*)[segue destinationViewController];
        
        NSInteger selectedAnnotationIndex = -1;
        for (NSUInteger index = 0; index < self.messages.count; ++index)
        {
            if (index == self.messageIndex)
            {
                selectedAnnotationIndex = [mapViewController numAnnotations];
            }
            
            NSDictionary * message = [self.messages objectAtIndex:index];
            
            NSNumber * latitude = [message objectForKey:kLatitudeKey];
            NSNumber * longitude = [message objectForKey:kLongitudeKey];
            
            // We only add a message in the map when the message contains a location
            if (latitude && longitude)
            {
                NSString * title   = [message objectForKey:kTitleKey];
                NSString * details = [message objectForKey:kDetailsKey]; 
                NSDate * date      = [message objectForKey:kDateKey];
                
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = latitude.doubleValue;
                coordinate.longitude = longitude.doubleValue;
                
                [mapViewController addAnnotationAtLocation:coordinate 
                                                     title:title 
                                                   details:details
                                                      date:date];                
            }
        }
        
        
        // Find the index path and center the annotation
        if (selectedAnnotationIndex >= 0)
        {
            [mapViewController centerAnnotationAtIndex:selectedAnnotationIndex];
        }
    }
}


@end
