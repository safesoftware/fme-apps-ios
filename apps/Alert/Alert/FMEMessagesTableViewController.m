/*============================================================================= 
 
   Name     : FMEMessagesTableViewController.m
 
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

#import "FMEMessagesTableViewController.h"
#import "FMEMapViewController.h"
#import "FMEMessagesTableViewCell.h"
#import "FMEPinDetailsViewController.h"
#import "FMESettingsViewController.h"
#import "FMEAppDelegate.h"

static NSString * kTitleKey     = @"title";
static NSString * kDetailsKey   = @"details";
static NSString * kDateKey      = @"date";
static NSString * kLatitudeKey  = @"latitude";
static NSString * kLongitudeKey = @"longitude";

// User Defaults Look-Up Keys
static NSString * kUserDefaultsMessages         = @"messages";

static const CGFloat kTableViewCellHeightHasLocation = 150.0f;
static const CGFloat kTableViewCellHeightNoLocation  =  60.0f;

// Segues
static NSString * kSegueShowSettings          = @"ShowSettings";
static NSString * kSegueShowAlertDetails      = @"ShowAlertDetails";
static NSString * kSegueShowAlertMap          = @"ShowAlertMap";

static NSString * kEmptyString                = @"";
static NSString * kLatLongFormat              = @"%.3f, %.3f";

// Table View Cell Identifier
static NSString * kTableViewCellIdentifier    = @"AlertCellIdentifier";

// Date And Time Format
static NSString * kDateOnlyFormat             = @"yyyy-MM-dd";
static NSString * kTimeOnlyFormat             = @"hh:mm a";

@interface FMEMessagesTableViewController ()
@property (weak, nonatomic)   IBOutlet UIBarButtonItem * centerBottomButton;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem * settingsButton;
@property (nonatomic, retain)          NSMutableArray  * messages;
@property (nonatomic)                  float             systemVersion;
- (void)addMessageInDictionary:(NSDictionary *)messageDictionary;
- (IBAction)displayConfirmClearActionSheet:(id)sender;

@end

@implementation FMEMessagesTableViewController
@synthesize centerBottomButton = centerBottomButton_;
@synthesize settingsButton = settingsButton_;
@synthesize messages = messages_;
@synthesize systemVersion = systemVersion_;

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])) {
        
        // initialize what you need here
        NSArray * messages = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaultsMessages];
        if (messages)
        {
            messages_ = [NSMutableArray arrayWithArray:messages];
        }
        else 
        {
            messages_ = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.navigationItem) {
        self.navigationItem.title = NSLocalizedString(@"Alerts", nil);
    }
    
    self.settingsButton.title = NSLocalizedString(@"Settings", @"Messages Table View Controller - Settings Button");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setCenterBottomButton:nil];
    [self setSettingsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * message = (NSDictionary *)[self.messages objectAtIndex:indexPath.row];
    if (message) {
        NSNumber * latitude = [message objectForKey:kLatitudeKey];
        NSNumber * longitude = [message objectForKey:kLongitudeKey];
        if (latitude && longitude)
        {
            return kTableViewCellHeightHasLocation;
        }
        else 
        {
            return kTableViewCellHeightNoLocation;
        }
    }
    else {
        return kTableViewCellHeightNoLocation;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMEMessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    if (!cell)
    {
        return nil;
    }

    // Se the delegate to response to the tap event on the map view
    cell.delegate = self;
    
    // The storyboard setting for disabling user interaction does not work
    // somehow. Let's ensure it is disabled.
    cell.mapView.userInteractionEnabled = NO;
    
    NSDictionary * message = (NSDictionary *)[self.messages objectAtIndex:indexPath.row];
    if (message)
    {    
        // Configure the cell...
        //cell.accessoryType = UITableViewCellAccessoryNone;
        
        // Title
        cell.titleLabel.text = [message objectForKey:kTitleKey];
        if (!cell.titleLabel.text || cell.titleLabel.text.length == 0)
        {
            cell.titleLabel.text = NSLocalizedString(@"<New Alert>", nil);
        }
        
        // Details
        cell.detailsLabel.text = [message objectForKey:kDetailsKey];
        if (!cell.detailsLabel.text || cell.detailsLabel.text.length == 0)
        {
            cell.detailsLabel.text = kEmptyString;
        }
        
        // Date
        NSDate * date = [message objectForKey:kDateKey];
        if (date)
        {
            // TODO: Display the time only if the date is within today. Display
            // the date only if the date is not today.
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            if (false) {
                [dateFormatter setDateFormat:kDateOnlyFormat];
            }
            else {
                [dateFormatter setDateFormat:kTimeOnlyFormat];
            }
            cell.dateLabel.text = [dateFormatter stringFromDate:[message objectForKey:kDateKey]];
        }
        else {
            cell.dateLabel.text = kEmptyString;
        }

        // Location
        NSNumber * latitude = [message objectForKey:kLatitudeKey];
        NSNumber * longitude = [message objectForKey:kLongitudeKey];
        if (latitude && longitude)
        {
            // Add the pin at the center of the map
            // Connect the map view from the interface builder to the controller
            cell.mapViewController.mapView = cell.mapView;
            // Clear all the pins from the map view first since the cell is reusable
            [cell.mapViewController removeAllAnnotations];
            // Add the annotation
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude.doubleValue,
                                                                         longitude.doubleValue);
            [cell.mapViewController addAnnotationAtLocation:location
                                                      title:nil
                                                    details:nil
                                                       date:nil];
            
            
            cell.locationLabel.text = [NSString stringWithFormat:kLatLongFormat, latitude.doubleValue, longitude.doubleValue];
            
            CLLocationCoordinate2D centerCoordinate 
                = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
            
            if (cell.mapView)
            {
                MKCoordinateRegion region;
                region.span = MKCoordinateSpanMake(0.1, 0.1);
                region.center = centerCoordinate;
                [cell.mapView setRegion:region];
//                [cell.mapView setCenterCoordinate:centerCoordinate animated:YES];
                cell.mapView.hidden = NO;
            }
        }
        else 
        {
            cell.locationLabel.text = kEmptyString;
            cell.mapView.hidden = YES;
        }
    }

    if (self.systemVersion >= 6)
    {
        // NOTE: The highlight will make the map view disappear in iOS 6. Let's
        // remove the selection style for now until Apple fixes the problem.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.messages removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:self.messages forKey:kUserDefaultsMessages];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    if (self.tableView != tableView) {
        return;
    }
    
    // If the user selects an area within the map view in the row, this table
    // view will show the map view with the location centered in the map. If
    // the user selects an area outside the map view in the row, this table
    // view will show the alert details.
    FMEMessagesTableViewCell * cell = (FMEMessagesTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        return;
    }

    [self performSegueWithIdentifier:kSegueShowAlertDetails sender:indexPath];
}

#pragma mark - Public functions

- (void)addMessageWithTitle:(NSString *)title
                    details:(NSString *)details
                       date:(NSDate *)date
{
    NSMutableDictionary * messageDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (title)
    {
        [messageDictionary setObject:title forKey:kTitleKey];
    }
    
    if (details)
    {
        [messageDictionary setObject:details forKey:kDetailsKey];
    }
    
    if (date)
    {
        [messageDictionary setObject:date forKey:kDateKey];
    }
    
    [self addMessageInDictionary:messageDictionary];
}

- (void)addMessageWithTitle:(NSString *)title 
                    details:(NSString *)details
                       date:(NSDate *)date
                   location:(CLLocationCoordinate2D)coordinate
{
    NSMutableDictionary * messageDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (title)
    {
        [messageDictionary setObject:title forKey:kTitleKey];
    }
    
    if (details)
    {
        [messageDictionary setObject:details forKey:kDetailsKey];
    }
    
    if (date)
    {
        [messageDictionary setObject:date forKey:kDateKey];
    }

    [messageDictionary setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:kLatitudeKey];
    [messageDictionary setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:kLongitudeKey];
    
    [self addMessageInDictionary:messageDictionary];
}

- (void)clearAllMessages
{
    [self.messages removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.messages forKey:kUserDefaultsMessages];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.tableView)
    {
        [self.tableView reloadData];
    }    
}

#pragma mark - Private functions

- (void)addMessageInDictionary:(NSDictionary *)messageDictionary
{
    // New messages are prepended to the list so that the new messages are
    // shown at the top of the table view.
    [self.messages insertObject:messageDictionary atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:self.messages forKey:kUserDefaultsMessages];
    
    if (self.tableView)
    {
        // Insert a row at the first row.
        NSArray * indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:YES];
    }
}

- (void)displayConfirmClearActionSheet:(id)sender
{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
//    {
//        // No Cancel button on iPad since tapping an area outside the action
//        // sheet will dismiss the action sheet without any actions.
//        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Do you want to remove all alerts?", @"")
//                                                                  delegate:self 
//                                                         cancelButtonTitle:nil
//                                                    destructiveButtonTitle:NSLocalizedString(@"Remove All Alerts", @"") 
//                                                         otherButtonTitles:nil];
//        [actionSheet showInView:self.view];
//    }
//    else 
//    {        
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Do you want to remove all alerts?", @"")
                                                              delegate:self 
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                destructiveButtonTitle:NSLocalizedString(@"Remove All Alerts", @"") 
                                                     otherButtonTitles:nil];
    [actionSheet showInView:self.tableView];
//    }
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
        settingsViewController.deviceToken           = appDelegate.deviceToken;
        settingsViewController.subscribedTopicNames  = [NSMutableSet setWithArray:appDelegate.subscribedTopicNames];
        settingsViewController.trackedTopicNames     = [NSMutableSet setWithArray:appDelegate.trackedTopicNames];
        settingsViewController.autoReportLocationOn  = appDelegate.reportLocationToTopicsOn;
        settingsViewController.highPrecisionUsed     = appDelegate.highPrecisionUsed;
        settingsViewController.timeInterval          = appDelegate.timeIntervalInSecond;
        settingsViewController.distanceFilter        = appDelegate.distanceFilterInMeter;
        settingsViewController.defaultTimeInterval   = appDelegate.defaultTimeInterval;
        settingsViewController.defaultDistanceFilter = appDelegate.defaultDistanceFilter;
        settingsViewController.location              = appDelegate.locationManager.location;
        settingsViewController.userAttributes        = appDelegate.userAttributes;
        settingsViewController.firstNameKey          = appDelegate.firstNameKey;
        settingsViewController.lastNameKey           = appDelegate.lastNameKey;
        settingsViewController.emailKey              = appDelegate.emailKey;
        settingsViewController.subjectKey            = appDelegate.subjectKey;
        settingsViewController.webAddressKey         = appDelegate.webAddressKey;
        settingsViewController.detailsKey            = appDelegate.detailsKey;
        settingsViewController.detailsTypeKey        = appDelegate.detailsTypeKey;
    }
    else if ([[segue identifier] isEqualToString:kSegueShowAlertMap]) {
        FMEMapViewController * mapViewController = (FMEMapViewController*)[segue destinationViewController];
        [mapViewController removeAllAnnotations];
        
        NSInteger selectedAnnotationIndex = -1;
        
        // Find the index path
        NSIndexPath * indexPath = nil;
        if ([sender isKindOfClass:[NSIndexPath class]])
        {
            indexPath = (NSIndexPath *)sender;
        }

        for (NSUInteger index = 0; index < self.messages.count; ++index)
        {
            if (indexPath && index == indexPath.row)
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
        
        if (selectedAnnotationIndex >= 0)
        {
            [mapViewController centerAnnotationAtIndex:selectedAnnotationIndex];
        }
    }
    else if ([[segue identifier] isEqualToString:kSegueShowAlertDetails])
    {
        if ([sender isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath * indexPath = (NSIndexPath*)sender;
            NSDictionary * message = [self.messages objectAtIndex:indexPath.row];
            
            FMEPinDetailsViewController * pinDetailsViewController = (FMEPinDetailsViewController*)[segue destinationViewController];
            pinDetailsViewController.title = [message objectForKey:kTitleKey];
            pinDetailsViewController.details = [message objectForKey:kDetailsKey];
            
            pinDetailsViewController.messages = self.messages;
            pinDetailsViewController.messageIndex = indexPath.row;
            
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            pinDetailsViewController.date = [dateFormatter stringFromDate:[message objectForKey:kDateKey]];

            NSNumber * latitude  = [message objectForKey:kLatitudeKey];
            NSNumber * longitude = [message objectForKey:kLongitudeKey];
            if (latitude && longitude)
            {
                pinDetailsViewController.location = [NSString stringWithFormat:
                                                     kLatLongFormat, 
                                                     latitude.doubleValue, 
                                                     longitude.doubleValue];
            }
            else 
            {
                pinDetailsViewController.location = kEmptyString;
            }

            
        }
    }
}

#pragma mark - UIActionSheetDelegate protocol implementation

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [self clearAllMessages];
    }
}

#pragma mark - FMEMessagesTableViewCellDelegate implementation

- (void)mapViewTappedInCell:(FMEMessagesTableViewCell *)cell
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath)
    {
        [self performSegueWithIdentifier:kSegueShowAlertMap sender:indexPath];
    }
}

@end
