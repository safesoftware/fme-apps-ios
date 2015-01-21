/*============================================================================= 
 
   Name     : FMEMapViewController.hm
 
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

#import "FMEMapViewController.h"
#import "FMESettingsViewController.h"
#import "FMEPinDetailsViewController.h"
#import "NSData+Additions.h"
#import "FMEMessageEditController.h"


#import <CoreLocation/CoreLocation.h>

#import "FMEAppDelegate.h"

static NSString * const kUserDefaultsKeyAnnotations          = @"Annotations";

// Segues
static NSString * kSegueShowSettings          = @"ShowSettings";
static NSString * kSegueShowPinDetails        = @"ShowPinDetails";
static NSString * kSegueMessageEdit           = @"MessageEditSegue";

static const NSInteger kMapSegmentIndex       = 0;
static const NSInteger kMessageSegmentIndex   = 1;

#pragma mark - FMEMapAnnotation

@interface FMEMapAnnotation : NSObject <MKAnnotation, NSCoding>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString * title;
@property (nonatomic, readonly, copy) NSString * subtitle;
@property (nonatomic) MKPinAnnotationColor pinColor;
@property (nonatomic, retain) NSData * accessoryData;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString*)title
                subtitle:(NSString*)subtitle
                pinColor:(MKPinAnnotationColor)pinColor
           accessoryData:(NSData*)accessoryData;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
@end

@implementation FMEMapAnnotation

@synthesize coordinate = coordinate_;
@synthesize title = title_;
@synthesize subtitle = subtitle_;
@synthesize pinColor = pinColor_;
@synthesize accessoryData = accessoryData_;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate 
                   title:(NSString *)title 
                subtitle:(NSString *)subtitle 
                pinColor:(MKPinAnnotationColor)pinColor
           accessoryData:(NSData *)accessoryData

{
    coordinate_ = coordinate;
    title_ = title;
    subtitle_ = subtitle;
    pinColor_ = pinColor;
    accessoryData_ = accessoryData;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:self.coordinate.latitude  forKey:@"latitude"];
    [coder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    [coder encodeObject:self.title                forKey:@"title"];
    [coder encodeObject:self.subtitle             forKey:@"subtitle"];
    [coder encodeInt:self.pinColor                forKey:@"pinColor"];
    [coder encodeDataObject:self.accessoryData];
}

- (id)initWithCoder:(NSCoder *)coder
{
    coordinate_.latitude = [coder decodeDoubleForKey:@"latitude"];
    coordinate_.longitude = [coder decodeDoubleForKey:@"longitude"];
    title_ = [coder decodeObjectForKey:@"title"];
    subtitle_ = [coder decodeObjectForKey:@"subtitle"];
    pinColor_ = [coder decodeIntForKey:@"pinColor"];
    accessoryData_ = [coder decodeDataObject];
    
    return self;
}

@end


#pragma mark - FMEMapViewController

@interface FMEMapViewController ()
// UI
@property (weak, nonatomic) IBOutlet MKMapView          *mapView;
@property (weak, nonatomic) IBOutlet UIView             *messageView;
@property (retain, nonatomic)        FMEMessageEditController * messageEditController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *sendButton;
@property (weak, nonatomic) IBOutlet MKUserTrackingBarButtonItem *userTrackingButton;
@property (nonatomic, retain) UIView * maximizedSliderTitleView;
@property (nonatomic, retain) UIView * minimizedSliderTitleView;

// Topic
@property (nonatomic, copy) NSString * type;
@property (nonatomic, copy) NSString * description;

// Distance Filter
@property (nonatomic) CLLocationDistance distanceFilter;

// Pin
@property (nonatomic) NSInteger numPins;

// Annotations
@property (nonatomic, retain) NSMutableArray * annotations;

- (IBAction)onSendButtonTapped:(id)sender;
- (void)loadAnnotationsFromUserDefaults:(NSUserDefaults *)userDefaults;
- (void)saveAnnotationsToUserDefaults:(NSUserDefaults *)userDefaults;
- (void)addAnnotation:(CLLocation*)location
              subject:(NSString *)subject
             pinColor:(MKPinAnnotationColor)pinColor
        accessoryData:(NSData *)accessoryData;
- (void)removeExtraAnnotations;
- (IBAction)displayConfirmClearActionSheet:(id)sender;
- (IBAction)onSegmentedControlValueChanged:(id)sender;
- (void)updateUiBasedOnSegmentedControl;

@end

@implementation FMEMapViewController

@synthesize mapView = mapView_;
@synthesize messageEditController = messageEditController_;
@synthesize settingsButton = settingsButton_;
@synthesize sendButton = sendButton_;
@synthesize userTrackingButton = userTrackingButton_;
@synthesize distanceFilter = distanceFilter_;
@synthesize type = type_;
@synthesize description = description_;
@synthesize numPins = numPins_;
@synthesize annotations = annotations_;


#pragma mark - Private functions

- (void)loadUserDefaults
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];

    // Annotations from last launch
    // We only load the annotations once from the user defaults when the cache
    // in this view controller is nil. The settings won't change the annotations
    // in the user defaults directly.
    if (!self.annotations)
    {
        [self loadAnnotationsFromUserDefaults:standardUserDefaults];
    }
    
    // Pin
    self.numPins                  = 100; // Simplify the UI by giving it an unimportant default = [standardUserDefaults integerForKey:kUserDefaultsKeyNumPins];
    [self removeExtraAnnotations];
}

- (void)loadAnnotationsFromUserDefaults:(NSUserDefaults *)userDefaults
{
// NOTE: Since iOS 6, restoring a FMEMapAnnotation doesn't work any more. We
// decided not to persistently store the pin history.
//    NSObject * object = [userDefaults objectForKey:kUserDefaultsKeyAnnotations];
//    if (object)
//    {
//        if ([object isKindOfClass:[NSArray class]])
//        {
//            // Convert the array of NSData to an array of FMEMapAnnotation
//            
//            NSArray * array = (NSArray*)object;
//            self.annotations = [NSMutableArray arrayWithCapacity:array.count];
//            
//            for (NSObject * arrayItem in array)
//            {
//                if ([arrayItem isKindOfClass:[NSData class]])
//                {
//                    NSObject * unarchivedObject = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)arrayItem];
//                    if ([unarchivedObject isKindOfClass:[FMEMapAnnotation class]])
//                    {
//                        FMEMapAnnotation * annotation = (FMEMapAnnotation *)unarchivedObject;
//                        
//                        // Add the annotation to the local cache and to the map view
//                        [self.annotations addObject:annotation];
//                        [self.mapView addAnnotation:annotation];
//                    }
//                }
//            }
//            
//            // Select the last annotation so that the callout will pop up
//            FMEMapAnnotation * lastAnnotation = (FMEMapAnnotation *)[self.annotations lastObject];
//            [self.mapView selectAnnotation:lastAnnotation animated:YES];
//        }
//    }
    
    // If the annotations list is still nil, we should initialize it
    if (!self.annotations)
    {
        self.annotations = [[NSMutableArray alloc] initWithCapacity:10];
    }
}

- (void)saveAnnotationsToUserDefaults:(NSUserDefaults *)userDefaults
{
// NOTE: Since iOS 6, restoring a FMEMapAnnotation doesn't work any more. We
// decided not to persistently store the pin history.
//    if (self.annotations && self.annotations.count > 0)
//    {
//        // Convert the annotation to an array of NSData since the user
//        // defaults only allows values in property list format
//        NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.annotations.count];
//        for (NSObject * object in self.annotations)
//        {
//            [array addObject:[NSKeyedArchiver archivedDataWithRootObject:object]];
//        }
//        
//        [userDefaults setObject:array forKey:kUserDefaultsKeyAnnotations];
//    }
//    else
//    {
//        // No any annotations. Remove the object from the user defaults.
//        [userDefaults removeObjectForKey:kUserDefaultsKeyAnnotations];
//    }
//    
//    [userDefaults synchronize];
}

- (void)addAnnotation:(CLLocation *)location
              subject:(NSString *)subject
             pinColor:(MKPinAnnotationColor)pinColor accessoryData:(NSData *)accessoryData
{
    if (self.numPins == 0)
    {
        return;   // No pins allowed. Nothing to do.
    }
    
    // PR: 37378
    // Change the pin bubble title to the Topic type
    NSString * title;
    if (pinColor == MKPinAnnotationColorGreen)
    {
        title = (subject && subject.length > 0)
            ? subject
            : NSLocalizedString(@"Location Reported Successfully", "Pin Title - Location Reported Successfully");
    }
    else
    {
        title = NSLocalizedString(@"Unable To Report Location", "Pin Title - Unable To Report Location");
    }
    
    // PR: 37378
    // Change the pin bubble subtitle to the description
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];    
    NSString * subtitle = [dateFormatter stringFromDate:[NSDate date]];
    
    FMEMapAnnotation * annotation = [[FMEMapAnnotation alloc] initWithCoordinate:location.coordinate 
                                                                           title:title 
                                                                        subtitle:subtitle
                                                                        pinColor:pinColor
                                                                   accessoryData:accessoryData];
    
    // Add the new annotation to the local cache. It is important to keep a 
    // local cache for two reasons. 
    //
    // First, the map view does not keep an ordered
    // list. Once we add the annotations to the map view, we will lose the order.
    // Keeping a local cache will help us track the annotation order so that we
    // can remove old annotations from the map view.
    //
    // Second, we can save and load the local cache to and from the user defaults
    // This will help us restore the previous state.
    [self.annotations addObject:annotation];
    [self.mapView addAnnotation:annotation];
    [self removeExtraAnnotations];
    [self saveAnnotationsToUserDefaults:[NSUserDefaults standardUserDefaults]];
    
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (void)removeExtraAnnotations
{       
    NSInteger numPinsOnMap = (self.annotations) ? self.annotations.count : 0;
    
    // If the number of pins on the map exceeeds the maximum number of pins the
    // user wants, remove the oldest pins so that the number of pins is the same
    // as the maximum. If the number of pins on map is less than or equal to
    // the maximum number of pins, we don't need to do anything.
    if (numPinsOnMap > self.numPins)
    {
        NSInteger numPinsToBeRemoved = numPinsOnMap - self.numPins;
        for (NSInteger count = 1; count <= numPinsToBeRemoved; count++)
        {
            FMEMapAnnotation * annotation = (FMEMapAnnotation *)[self.annotations objectAtIndex:0];
            
            // Remove this annotation from both the map and the local cache
            [self.mapView removeAnnotation:annotation];
            [self.annotations removeObject:annotation];
        }
    }
}

- (void)displayConfirmClearActionSheet:(id)sender
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Do you want to remove all pins?", @"")
                                                              delegate:self 
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                destructiveButtonTitle:NSLocalizedString(@"Remove All Pins", @"") 
                                                     otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - View life cycle

- (IBAction)onSendButtonTapped:(id)sender {
    
    if (/*No host    */ !appDelegate.host              ||
        /*No username*/ !appDelegate.username          ||
        /*No password*/ !appDelegate.password          ||
        /*No topics  */ !appDelegate.trackedTopicNames || appDelegate.trackedTopicNames.count <= 0)
    {
        // Warn user to input server account info
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insufficient Server Info", @"Alert View - Insufficient Server Info")
                                                             message:NSLocalizedString(@"Alert View Message - Insufficient Server Info", @"Alert View Message - Insufficient Server Info")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Close", "Alert View - Insufficient Server Info Close Button")
                                                   otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [appDelegate.locationManager requestLocation];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.extendedLayoutIncludesOpaqueBars = NO;

    [self loadUserDefaults];
   
    if (self.navigationItem) {
        self.navigationItem.title = NSLocalizedString(@"FME Reporter", @"Map View Controller - Title");
    }
    
    self.sendButton.title = NSLocalizedString(@"Send", @"Send Button - Title");
    
    appDelegate.notificationManager.delegate = self;
    
    self.settingsButton.title = NSLocalizedString(@"Settings", @"Map View Controller - Settings Button");
    
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    (void)[self.userTrackingButton initWithMapView:self.mapView];   // reinit the button with the mapview

    // Initialize the segmented control
    [self.segmentedControl addTarget:self
                              action:@selector(onSegmentedControlValueChanged:)
                    forControlEvents:UIControlEventValueChanged];
    if (self.segmentedControl.selectedSegmentIndex < 0)
    {
        self.segmentedControl.selectedSegmentIndex = kMapSegmentIndex;
    }
    
    // Pass the app delegate to the message edit controller to capture the
    // text changes

    // Based on the selected segment index, determine whether the map view
    // or the message view should be displayed.
    [self updateUiBasedOnSegmentedControl];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setSettingsButton:nil];
    [self setSendButton:nil];
    [self setUserTrackingButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

- (IBAction)onSegmentedControlValueChanged:(id)sender
{
    [self updateUiBasedOnSegmentedControl];
}

- (void)updateUiBasedOnSegmentedControl
{
    if (self.segmentedControl.selectedSegmentIndex == kMessageSegmentIndex)
    {
        [self.messageView.superview bringSubviewToFront:self.messageView];
        
        // Hide the trash button and the user tracker button
        self.userTrackingButton.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    else
    {
        [self.mapView.superview bringSubviewToFront:self.mapView];
        
        // Restore the trash button and the user tracker button
        self.userTrackingButton.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

#pragma mark - MKMapViewDelegate protocol implementation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{    
    static NSString * reuseIdentifier = @"Pin";
    
    if ([annotation isKindOfClass:[FMEMapAnnotation class]])
    {
        MKPinAnnotationView * annotationView 
           = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (annotationView)
        {
            annotationView.annotation = annotation;
        }
        else 
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        
        FMEMapAnnotation * fmeMapAnnotation = (FMEMapAnnotation *)annotation;
        
        annotationView.pinColor = fmeMapAnnotation.pinColor;
        annotationView.enabled = YES;
        annotationView.canShowCallout =YES;
        annotationView.animatesDrop = YES;
        
        // We only show the detail disclosure button when we have data to show
        if (fmeMapAnnotation.accessoryData)
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"ShowPinDetails" sender:view];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([[segue identifier] isEqualToString:kSegueShowSettings]) {
        FMESettingsViewController * settingsViewController = (FMESettingsViewController*)[segue destinationViewController];
        settingsViewController.delegate              = appDelegate;
        settingsViewController.host                  = appDelegate.host;
        settingsViewController.username              = appDelegate.username;
        settingsViewController.password              = appDelegate.password;
        settingsViewController.trackedTopicNames     = [NSMutableSet setWithArray:appDelegate.trackedTopicNames];
        settingsViewController.autoReportLocationOn  = appDelegate.autoReportLocationOn;
        settingsViewController.highPrecisionUsed     = appDelegate.highPrecisionUsed;
        settingsViewController.timeInterval          = appDelegate.timeIntervalInSecond;
        settingsViewController.distanceFilter        = appDelegate.distanceFilterInMeter;
        settingsViewController.defaultTimeInterval   = appDelegate.defaultTimeInterval;
        settingsViewController.defaultDistanceFilter = appDelegate.defaultDistanceFilter;
        settingsViewController.location              = appDelegate.locationManager.location;
        settingsViewController.listAllTopics         = YES;
    }
    else if ([[segue identifier] isEqualToString:kSegueShowPinDetails])
    {
        if ([sender isKindOfClass:[MKAnnotationView class]])
        {
            MKAnnotationView * annotationView = (MKAnnotationView *)sender;
            if ([annotationView.annotation isKindOfClass:[FMEMapAnnotation class]])
            {
                FMEMapAnnotation * annotation = (FMEMapAnnotation *)(annotationView.annotation);
                
                FMEPinDetailsViewController * pinDetailsViewController = (FMEPinDetailsViewController*)[segue destinationViewController];
                pinDetailsViewController.description = [[NSString alloc] initWithData:annotation.accessoryData encoding:NSUTF8StringEncoding];
            }
        }
    }
    else if ([[segue identifier] isEqualToString:kSegueMessageEdit])
    {
        self.messageEditController = [segue destinationViewController];
        self.messageEditController.delegate = self;
        self.messageEditController.firstNameKey   = appDelegate.firstNameKey;
        self.messageEditController.lastNameKey    = appDelegate.lastNameKey;
        self.messageEditController.emailKey       = appDelegate.emailKey;
        self.messageEditController.subjectKey     = appDelegate.subjectKey;
        self.messageEditController.webAddressKey  = appDelegate.webAddressKey;
        self.messageEditController.detailsKey     = appDelegate.detailsKey;
        self.messageEditController.detailsTypeKey = appDelegate.detailsTypeKey;
    }
}


#pragma mark - FMEServerNotificationManager implementation

- (void)reportDidFinish:(NSString *)topic
                   host:(NSString *)host
               username:(NSString *)username
               password:(NSString *)password
            deviceToken:(NSString *)deviceToken
               location:(CLLocation *)location
         userAttributes:(NSDictionary *)userAttributes
{
    if (!location)
    {
        return;
    }

    NSString * subject = [userAttributes objectForKey:appDelegate.subjectKey];
    [self addAnnotation:location subject:subject pinColor:MKPinAnnotationColorGreen accessoryData:nil];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString * dateString = [dateFormatter stringFromDate:[NSDate date]];

    self.messageEditController.headerMessage = [NSString stringWithFormat:
                                                NSLocalizedString(@"Last message sent at\n %@", @"Message sent"),dateString];
}

- (void)reportDidFail:(NSString *)topic
                 host:(NSString *)host
             username:(NSString *)username
             password:(NSString *)password
          deviceToken:(NSString *)deviceToken
             location:(CLLocation *)location
       userAttributes:(NSDictionary *)userAttributes
                error:(NSError *)error
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString * dateString = [dateFormatter stringFromDate:[NSDate date]];

    self.messageEditController.headerMessage = [NSString stringWithFormat:
                                                NSLocalizedString(@"Failed to send message at\n %@", @"Failed to send message"), dateString];
    if (!location)
    {
        return;
    }
    
    NSString * errorMessage = nil;
    if (error)
    {
        errorMessage = [NSString stringWithFormat:NSLocalizedString(@"%@\nTopic = %@\nHost = %@\nUsername = %@\nLocation = %.3f, %.3f\n", @""),
                                   error.localizedDescription,
                                   topic,
                                   host,
                                   username,
                                   location.coordinate.latitude,
                                   location.coordinate.longitude];
    }
    else 
    {
        errorMessage = NSLocalizedString(
           @"Unable to send data to the host. Please make sure host, username, password, and topic are not empty",
           @"Unable to send data to the host. Please make sure host, username, password, and topic are not empty");

    }

    NSData * errorData = [errorMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSString * subject = [userAttributes objectForKey:appDelegate.subjectKey];
    [self addAnnotation:location subject:subject pinColor:MKPinAnnotationColorRed accessoryData:errorData];
}

#pragma mark - UIActionSheetDelegate protocol implementation

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [self.mapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
    }
}

#pragma mark - FMEMessageEditController

- (void)messageEditControllerViewDidLoad:(FMEMessageEditController *)controller
{
    controller.firstName.text  = [appDelegate.userAttributes objectForKey:appDelegate.firstNameKey];
    controller.lastName.text   = [appDelegate.userAttributes objectForKey:appDelegate.lastNameKey];
    controller.email.text      = [appDelegate.userAttributes objectForKey:appDelegate.emailKey];
    controller.subject.text    = [appDelegate.userAttributes objectForKey:appDelegate.subjectKey];
    controller.webAddress.text = [appDelegate.userAttributes objectForKey:appDelegate.webAddressKey];
    controller.details.text    = [appDelegate.userAttributes objectForKey:appDelegate.detailsKey];
}

- (void)messageEditController:(FMEMessageEditController *)controller
               valueDidChange:(NSString *)value
                       forKey:(NSString *)key
{
    [appDelegate setUserAttribute:value forName:key];
}


@end
