/*============================================================================= 
 
   Name     : FMEMapViewController.m
 
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

#import "FMEMapViewController.h"
#import "FMEPinDetailsViewController.h"
#import <MapKit/MapKit.h>

// Coder Keys
static NSString * kTitleKey     = @"title";
static NSString * kDetailsKey   = @"details";
static NSString * kDateKey      = @"date";
static NSString * kLatitudeKey  = @"latitude";
static NSString * kLongitudeKey = @"longitude";

// Segues
static NSString * kSegueShowPinDetails = @"ShowPinDetails";

// Pin Annotation Views
static NSString * kPinAnnotationViewIdentifier = @"PinAnnotationViewIdentifier";

// String formats
static NSString * kLatLongFormat = @"%f, %f";

#pragma mark - FMEMapAnnotation

@interface FMEMapAnnotation : NSObject <MKAnnotation, NSCoding>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString * title;
@property (nonatomic, readonly, copy) NSString * subtitle;
@property (nonatomic, copy) NSString * details;
@property (nonatomic, readonly) NSDate * date;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString *)title
                 details:(NSString *)details
                    date:(NSDate *)date;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
@end

@implementation FMEMapAnnotation

@synthesize coordinate = coordinate_;
@synthesize title = title_;
@synthesize date = date_;
@synthesize details = details_;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate 
                   title:(NSString *)title 
                 details:(NSString *)details 
                    date:(NSDate *)date
{
    coordinate_ = coordinate;
    title_ = title;
    details_ = details;
    date_ = date;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:self.coordinate.latitude  forKey:kLatitudeKey];
    [coder encodeDouble:self.coordinate.longitude forKey:kLongitudeKey];
    [coder encodeObject:self.title                forKey:kTitleKey];
    [coder encodeObject:self.details              forKey:kDetailsKey];
    [coder encodeObject:self.date                 forKey:kDateKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    coordinate_.latitude  = [coder decodeDoubleForKey:kLatitudeKey];
    coordinate_.longitude = [coder decodeDoubleForKey:kLongitudeKey];
    title_                = [coder decodeObjectForKey:kTitleKey];
    details_              = [coder decodeObjectForKey:kDetailsKey];
    date_                 = [coder decodeObjectForKey:kDateKey];
    return self;
}

- (NSString *)subtitle
{
    if (self.details && self.details.length > 0)
    {
        return self.details;
    }
    else 
    {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];    
        return [dateFormatter stringFromDate:[NSDate date]];
    }
}

@end


#pragma mark - FMEMapViewController

@interface FMEMapViewController ()
@property (nonatomic, retain) NSMutableArray * annotations;   // In order
@property (nonatomic, weak) id<MKAnnotation> annotationToBeCentered;
@end

@implementation FMEMapViewController
@synthesize mapView = mapView_;
@synthesize annotations = annotations_;
@synthesize annotationToBeCentered = annotationToBeCentered_;

#pragma mark - Private functions


#pragma mark - Public functions

- (NSUInteger)numAnnotations
{
    return (self.annotations) ? self.annotations.count : 0;
}

- (void)addAnnotationAtLocation:(CLLocationCoordinate2D)location
                          title:(NSString *)title
                        details:(NSString *)details
                           date:(NSDate *)date
{
    FMEMapAnnotation * annotation = [[FMEMapAnnotation alloc] initWithCoordinate:location
                                                                           title:title
                                                                         details:details
                                                                            date:date];
    
    if (!self.annotations)
    {
        self.annotations = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.annotations addObject:annotation];
    
    if (self.mapView)
    {
        [self.mapView addAnnotation:annotation];
    }
}

- (void)centerAnnotationAtIndex:(NSUInteger)index
{    
    if (index >= self.annotations.count)
    {
        return;   // Invalid index
    }
    
    FMEMapAnnotation * annotation = [self.annotations objectAtIndex:index];
    if (annotation)
    {
        MKAnnotationView * annotationView = [self.mapView viewForAnnotation:annotation];
        if (annotationView)
        {
            // If we can find the annotation view for the corresponding index, we
            // can center the annotation view now.
            [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
            [self.mapView selectAnnotation:annotation animated:YES];
        }
        else 
        {
            // If we cannot find the corresponding annotation view, we have to
            // remember the annotation to be centered. When the annotation view
            // is created, we can center the view.
            self.annotationToBeCentered = annotation;
        }
    }
}

- (void)removeAnnotationAtIndex:(NSUInteger)index
{
    if (index >= self.annotations.count)
    {
        return;   // Invalid index
    }
    
    FMEMapAnnotation * annotation = [self.annotations objectAtIndex:index];
    [self.annotations removeObject:annotation];
    [self.mapView removeAnnotation:annotation];
}

- (void)removeAllAnnotations
{
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
}

#pragma mark - MKMapViewDelegate protocol implementation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{    
    if ([annotation isKindOfClass:[FMEMapAnnotation class]])
    {
        MKPinAnnotationView * annotationView 
        = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationViewIdentifier];
        if (annotationView)
        {
            annotationView.annotation = annotation;
        }
        else 
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationViewIdentifier];
        }
        
        annotationView.pinColor = MKPinAnnotationColorRed;
        annotationView.enabled = YES;
        annotationView.canShowCallout =YES;
        annotationView.animatesDrop = (self.annotationToBeCentered == annotation);

        // We only show the detail disclosure button when we have details to show
        FMEMapAnnotation * fmeMapAnnotation = (FMEMapAnnotation *)annotation;
        if (fmeMapAnnotation.details && fmeMapAnnotation.details.length > 0)
        {
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        
        return annotationView;
    }
    else 
    {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if (self.annotationToBeCentered)
    {
        for (MKAnnotationView * annotationView in views)
        {
            if (annotationView.annotation == self.annotationToBeCentered)
            {
                // We found the annotation view that we want to center at.
                MKCoordinateSpan span;
                span.latitudeDelta = .1;
                span.longitudeDelta = .1;
                MKCoordinateRegion region;
                region.center = self.annotationToBeCentered.coordinate;
                region.span = span;
                [self.mapView setRegion:region animated:YES];
                [self.mapView selectAnnotation:self.annotationToBeCentered animated:YES];
                
                // Clear the member since we have already centered it
                self.annotationToBeCentered = nil;
                
                break;
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:kSegueShowPinDetails sender:view];
}

#pragma mark - View controller life cycle

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
        self.navigationItem.title = NSLocalizedString(@"Map View", nil);
    }

    // If the caller add annotations before the map view is created, we should
    // add the annotations to the map view here.
    if (self.annotations && self.annotations.count > 0)
    {
        [self.mapView addAnnotations:self.annotations];
    }
    
    if (self.annotationToBeCentered)
    {
        MKCoordinateSpan span;
        span.latitudeDelta = .1;
        span.longitudeDelta = .1;
        MKCoordinateRegion region;
        region.center = self.annotationToBeCentered.coordinate;
        region.span = span;
        [self.mapView setRegion:region animated:NO];
//
//        [self.mapView selectAnnotation:self.annotationToBeCentered animated:YES];        
    }
}

- (void)viewDidUnload
{
    [self setAnnotations:nil];
    [self setMapView:nil];
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
    if ([[segue identifier] isEqualToString:kSegueShowPinDetails])
    {
        if ([sender isKindOfClass:[MKAnnotationView class]])
        {
            MKAnnotationView * annotationView = (MKAnnotationView *)sender;
            if ([annotationView.annotation isKindOfClass:[FMEMapAnnotation class]])
            {
                FMEMapAnnotation * annotation = (FMEMapAnnotation *)(annotationView.annotation);
                if (annotation)
                {
                    FMEPinDetailsViewController * pinDetailsViewController = (FMEPinDetailsViewController*)[segue destinationViewController];
                    pinDetailsViewController.title = annotation.title;
                    pinDetailsViewController.details = annotation.details;
                    
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
                    pinDetailsViewController.date = [dateFormatter stringFromDate:annotation.date];
                    pinDetailsViewController.location 
                        = [NSString stringWithFormat:kLatLongFormat, annotation.coordinate.latitude, annotation.coordinate.longitude];
                }
            }
        }
    }
}

@end
