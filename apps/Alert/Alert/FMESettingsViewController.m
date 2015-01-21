/*============================================================================= 
 
   Name     : FMESettingsViewController.m
 
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

#import "FMESettingsViewController.h"
#import "FMEServerNotificationManager.h"
#import "FMEActivityIndicatorTitleView.h"
#import "Reachability.h"

static NSString * const kName               = @"name";
static NSString * const kDescription        = @"description";

static NSString * const kSegueShowAccountInformation = @"ShowAccountInformation";
static NSString * const kSegueShowTopicsSubscribed   = @"ShowTopicsSubscribed";
static NSString * const kSegueShowTopicsTracked      = @"ShowTopicsTracked";
static NSString * const kSegueShowTimeInterval       = @"ShowTimeInterval";
static NSString * const kSegueShowDistanceFilter     = @"ShowDistanceFilter";
static NSString * const kSegueShowMessage            = @"ShowMessage";

// Section Indexes
static const NSUInteger kAccountInformationSectionIndex = 0;
static const NSUInteger kLocationTrackingSectionIndex   = 1;
static const NSUInteger kReportOptionsSectionIndex      = 2;

// Row Indexes
static const NSUInteger kAutoReportLocationRowIndex     = 0;
static const NSUInteger kHighPrecisionRowIndex          = 1;
static const NSUInteger kTimeIntervalRowIndex           = 2;
static const NSUInteger kDistanceFilterRowIndex         = 3;

// Number of Rows
static const NSUInteger kNumRowsWhenAutoReportOff       = 1;
static const NSUInteger kNumRowsWhenHighPrecisionOn     = 4;
static const NSUInteger kNumRowsWhenHighPrecisionOff    = 2;


static NSString * kEmptyString = @"";

@interface FMESettingsViewController ()

@property (weak,   nonatomic) IBOutlet UILabel                        * hostStaticLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * usernameStaticLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * subscribedTopicsStaticLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * trackedTopicsStaticLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * sendLocationToTopicsLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * highPrecisionStaticLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * timeIntervalStaticLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * distanceFilterStaticLabel;

@property (weak,   nonatomic) IBOutlet UILabel                        * hostLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * usernameLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * subscribedTopicsLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * trackedTopicsLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * timeIntervalLabel;
@property (weak,   nonatomic) IBOutlet UILabel                        * distanceFilterLabel;
@property (weak,   nonatomic) IBOutlet UIBarButtonItem                * centerBottomButton;
@property (weak,   nonatomic) IBOutlet UIBarButtonItem                * aboutButton;
@property (weak,   nonatomic) IBOutlet UISwitch                       * autoReportLocationSwitch;
@property (weak,   nonatomic) IBOutlet UISwitch                       * highPrecisionSwitch;
@property (retain, nonatomic)          NSArray                        * topics;
@property (retain, nonatomic)          UIActionSheet                  * confirmAccountSaveActionSheet;
@property (weak,   nonatomic)          FMEServerAccountViewController * accountViewController;
@property (weak,   nonatomic)          FMETopicsViewController        * subscribedTopicsViewController;
@property (weak,   nonatomic)          FMETopicsViewController        * trackedTopicsViewController;
@property (retain, nonatomic)          FMEServerNotificationManager   * serverNotificationManager;

// It contains the topic names that will be subscribed to or unsubscribed from.
@property (retain, nonatomic)          NSMutableSet                   * unprocessedTopicNames;

- (void)setHostLabelText:(NSString *)host;
- (void)setUsernameLabelText:(NSString *)username;
- (void)setSubscribedTopicsLabelText:(NSUInteger)numTopics;
- (void)setTrackedTopicsLabelText:(NSUInteger)numTopics;
- (void)setTimeIntervalLabelText:(NSTimeInterval)timeInterval;
- (void)setDistanceFilterLabelText:(CLLocationDistance)distanceFilter;

- (BOOL)hasHostOrUsernameChanged:(NSString *)newHost 
                        username:(NSString *)newUsername;
- (BOOL)hasPasswordChanged:(NSString *)newPassword;
- (BOOL)hasSubscriptions;
- (void)validateAccountInfo:(FMEServerAccountViewController *)accountViewController;
- (UIView *)createPoweredByFMEServerView;
- (void)updateSubscribedTopicsViewController;
- (NSMutableArray *)getSubscribedTopics;
- (IBAction)autoReportLocationSwitchValueDidChange;
- (IBAction)highPrecisionSwitchValueDidChange;
- (void)unsubscribeAllTopics;
- (BOOL)hasNoDistanceFilter;
- (void)cleanupSubscribedNonExistingTopics:(BOOL)showAlert;
- (void)cleanupTrackedNonExistingTopics:(BOOL)showAlert;
- (NSMutableSet *)cleanupNonExistingTopics:(NSSet *)topics withAlert:(BOOL)showAlert;
- (void)adjustTableView:(UITableView *)tableView toNumRows:(NSUInteger)numRows inSection:(NSUInteger)section;
@end

@implementation FMESettingsViewController
@synthesize hostStaticLabel                = hostStaticLabel_;
@synthesize usernameStaticLabel            = usernameStaticLabel_;
@synthesize subscribedTopicsStaticLabel    = subscribedTopicsStaticLabel_;
@synthesize trackedTopicsStaticLabel       = trackedTopicsStaticLabel_;
@synthesize sendLocationToTopicsLabel      = sendLocationToTopicsLabel_;
@synthesize highPrecisionStaticLabel       = highPrecisionStaticLabel_;
@synthesize timeIntervalStaticLabel        = timeIntervalStaticLabel_;
@synthesize distanceFilterStaticLabel      = distanceFilterStaticLabel_;
@synthesize hostLabel                      = hostLabel_;
@synthesize usernameLabel                  = usernameLabel_;
@synthesize subscribedTopicsLabel          = subscribedTopicsLabel_;
@synthesize trackedTopicsLabel             = trackedTopicsLabel_;
@synthesize timeIntervalLabel              = timeIntervalLabel_;
@synthesize distanceFilterLabel            = distanceFilterLabel_;
@synthesize centerBottomButton             = centerBottomButton_;
@synthesize aboutButton                    = aboutButton_;
@synthesize autoReportLocationSwitch       = autoReportLocationSwitch_;
@synthesize highPrecisionSwitch            = highPrecisionSwitch_;
@synthesize topics                         = topics_;
@synthesize confirmAccountSaveActionSheet  = confirmAccountSaveActionSheet_;
@synthesize accountViewController          = accountViewController_;
@synthesize subscribedTopicsViewController = subscribedTopicsViewController_;
@synthesize trackedTopicsViewController    = trackedTopicsViewController_;
@synthesize serverNotificationManager      = serverNotificationManager_;
@synthesize host                           = host_;
@synthesize username                       = username_;
@synthesize password                       = password_;
@synthesize deviceToken                    = deviceToken_;
@synthesize subscribedTopicNames           = subscribedTopicNames_;
@synthesize trackedTopicNames              = trackedTopicNames_;
@synthesize autoReportLocationOn           = autoReportLocationOn_;
@synthesize highPrecisionUsed              = highPrecisionUsed_;
@synthesize timeInterval                   = timeInterval_;
@synthesize distanceFilter                 = distanceFilter_;
@synthesize unprocessedTopicNames          = unprocessedTopicNames_;
@synthesize delegate                       = delegate_;
@synthesize defaultTimeInterval            = defaultTimeInterval_;
@synthesize defaultDistanceFilter          = defaultDistanceFilter_;
@synthesize location                       = location_;
@synthesize listAllTopics                  = listAllTopics_;
@synthesize userAttributes                 = userAttributes_;
@synthesize firstNameKey                   = firstNameKey_;
@synthesize lastNameKey                    = lastNameKey_;
@synthesize emailKey                       = emailKey_;
@synthesize subjectKey                     = subjectKey_;
@synthesize webAddressKey                  = webAddressKey_;
@synthesize detailsKey                     = detailsKey_;
@synthesize detailsTypeKey                 = detailsTypeKey_;


#pragma mark - View life cycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        host_ = nil;
        username_ = nil;
        password_ = nil;
        deviceToken_ = nil;
        topics_ = nil;
        subscribedTopicNames_ = nil;
        highPrecisionUsed_ = NO;
        timeInterval_ = 0.0;
        distanceFilter_ = 0.0;
        defaultTimeInterval_  = 60;   // 60 secs
        defaultDistanceFilter_ = 500;  // 500 meters
        
        accountViewController_ = nil;
        subscribedTopicsViewController_ = nil;
        trackedTopicsViewController_ = nil;
        
        serverNotificationManager_ = [[FMEServerNotificationManager alloc] init];
        serverNotificationManager_.delegate = self;
        
        listAllTopics_ = NO;
        
        userAttributes_ = nil;
        
        delegate_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.navigationItem) {
        self.navigationItem.title = NSLocalizedString(@"Settings", nil);
    }

    // Display settings 
    self.hostStaticLabel.text             = NSLocalizedString(@"Host"                , @"Settings - Host Label");
    self.usernameStaticLabel.text         = NSLocalizedString(@"Username"            , @"Settings - Username Label");
    self.subscribedTopicsStaticLabel.text = NSLocalizedString(@"Subscribed Topics"   , @"Settings - Subscribed Topics Label");
    self.trackedTopicsStaticLabel.text    = NSLocalizedString(@"Tracked Topics"      , @"Settings - Tracked Topics Label");
    self.sendLocationToTopicsLabel.text   = NSLocalizedString(@"Auto Report Location", @"Settings - Auto Report Location");
    self.highPrecisionStaticLabel.text    = NSLocalizedString(@"High Precision"      , @"Settings - High Precision Label");
    self.timeIntervalStaticLabel.text     = NSLocalizedString(@"Time Interval"       , @"Settings - Time Interval Label");
    self.distanceFilterStaticLabel.text   = NSLocalizedString(@"Distance Filter"     , @"Settings - Distance Filter Label");

    [self setHostLabelText:self.host];
    [self setUsernameLabelText:self.username];
    [self setSubscribedTopicsLabelText:self.subscribedTopicNames.count];
    [self setTrackedTopicsLabelText:self.trackedTopicNames.count];
    [self setTimeIntervalLabelText:self.timeInterval];
    [self setDistanceFilterLabelText:self.distanceFilter];

    self.aboutButton.title = NSLocalizedString(@"About", @"Settings - About Label");
    
    self.centerBottomButton.customView = [self createPoweredByFMEServerView];
    
//    [self.highPrecisionSwitch addTarget:self
//                                  action:@selector(highPrecisionSwitchValueDidChange) 
//                        forControlEvents:UIControlEventValueChanged];
    
    self.autoReportLocationSwitch.on = self.autoReportLocationOn;
    self.highPrecisionSwitch.on      = self.highPrecisionUsed;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setHostLabel:nil];
    [self setUsernameLabel:nil];
    [self setSubscribedTopicsLabel:nil];
    [self setTrackedTopicsLabel:nil];
    [self setTimeIntervalLabel:nil];
    [self setDistanceFilterLabel:nil];
    [self setCenterBottomButton:nil];
    [self setAccountViewController:nil];
    [self setSubscribedTopicsViewController:nil];
    [self setHighPrecisionSwitch:nil];
    [self setAboutButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private functions

- (BOOL)hasHostOrUsernameChanged:(NSString *)newHost username:(NSString *)newUsername
{
    return ([self.hostLabel.text caseInsensitiveCompare:newHost]         != NSOrderedSame ||
            [self.usernameLabel.text caseInsensitiveCompare:newUsername] != NSOrderedSame);
}

- (BOOL)hasPasswordChanged:(NSString *)newPassword
{
    return (newPassword && ([newPassword caseInsensitiveCompare:self.password] != NSOrderedSame));
}

- (BOOL)hasSubscriptions
{
    return (self.subscribedTopicNames.count > 0);
}

- (void)validateAccountInfo:(FMEServerAccountViewController *)accountViewController
{    
    // Disable the Cancel and Save button in the controller so that the user cannot
    // tap the button when the previous operation is still in progress
    accountViewController.navigationItem.leftBarButtonItem = nil;
    accountViewController.navigationItem.rightBarButtonItem = nil;

    FMEActivityIndicatorTitleView * titleView
    = [[FMEActivityIndicatorTitleView alloc] initWithFrame:
       CGRectMake(0.0f, 
                  0.0f,
                  accountViewController.navigationController.navigationBar.frame.size.width, 
                  accountViewController.navigationController.navigationBar.frame.size.height)];
    [titleView setTitle:NSLocalizedString(@"Verifying", @"Navigation Bar Title - Verifying Account Info")];
    accountViewController.navigationItem.titleView = titleView;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (/*No host    */ (!accountViewController.host     || accountViewController.host.length     == 0) &&
        /*No username*/ (!accountViewController.username || accountViewController.username.length == 0) &&
        /*No password*/ (!accountViewController.password || accountViewController.password.length == 0))
    {
        [self getTopicsDidFinish:nil];
    }
    else
    {
        // Make a url request to the host and see if we have a valid response from
        // getting the topics
        [self.serverNotificationManager getTopicsFromHost:accountViewController.host
                                                 username:accountViewController.username
                                                 password:accountViewController.password];
    }
}

- (NSMutableSet *)subscribedTopicNames
{
    if (!subscribedTopicNames_)
    {
        subscribedTopicNames_ = [NSMutableSet setWithCapacity:1];
    }
    
    return subscribedTopicNames_;
}

- (NSMutableSet *)trackedTopicNames
{
    if (!trackedTopicNames_)
    {
        trackedTopicNames_ = [NSMutableSet setWithCapacity:1];
    }
    
    return trackedTopicNames_;
}

- (void)setHostLabelText:(NSString *)host
{
    self.hostLabel.text = (host) ? host : kEmptyString;
}

- (void)setUsernameLabelText:(NSString *)username
{
    self.usernameLabel.text = (username) ? username : kEmptyString;
}

- (void)setSubscribedTopicsLabelText:(NSUInteger)numTopics
{
    self.subscribedTopicsLabel.text 
        = [NSString stringWithFormat:NSLocalizedString(@"%u Subscribed", nil), numTopics];
}

- (void)setTrackedTopicsLabelText:(NSUInteger)numTopics
{
    self.trackedTopicsLabel.text 
        = [NSString stringWithFormat:NSLocalizedString(@"%u Tracked", nil), numTopics];
}

- (void)setTimeIntervalLabelText:(NSTimeInterval)timeInterval
{
    NSUInteger minute = timeInterval / 60;
    NSUInteger second = (NSUInteger)timeInterval % 60;

    NSString * minuteString = (minute == 1)
        ? [NSString stringWithFormat:NSLocalizedString(@"%i Min", nil), minute]
        : [NSString stringWithFormat:NSLocalizedString(@"%i Mins", nil), minute];
    NSString * secondString = (second == 1)
        ? [NSString stringWithFormat:NSLocalizedString(@"%i Sec", nil), second]
        : [NSString stringWithFormat:NSLocalizedString(@"%i Secs", nil), second];
 
    if (second == 0)
    {
        self.timeIntervalLabel.text = minuteString;
    }
    else if (minute == 0)
    {
        self.timeIntervalLabel.text = secondString;
    }
    else 
    {
        self.timeIntervalLabel.text = [NSString stringWithFormat:@"%@ %@", minuteString, secondString];
    }
}

- (void)setDistanceFilterLabelText:(CLLocationDistance)distanceFilterInMeter
{
    if (distanceFilterInMeter == kCLDistanceFilterNone || distanceFilterInMeter == 0) 
    {
        self.distanceFilterLabel.text = NSLocalizedString(@"Disabled", nil);
    }
    else 
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        self.distanceFilterLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Meters", nil),
                                         [numberFormatter stringFromNumber:[NSNumber numberWithInteger:(NSInteger)distanceFilterInMeter]]];
    }
    
}

- (UIView *)createPoweredByFMEServerView
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 20.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Powered by FME Server", nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.0f];
    label.textColor = [UIColor lightGrayColor];
    return label;
}

- (NSMutableArray *)getSubscribedTopics
{
    if (self.topics &&
        self.topics.count > 0 &&
        self.subscribedTopicNames && 
        self.subscribedTopicNames.count > 0)
    {
        // Get the topic records of the subscribed topic names
        NSMutableArray * subscribedTopics 
        = [NSMutableArray arrayWithCapacity:self.subscribedTopicNames.count];
        
        NSEnumerator * enumerator = [self.topics objectEnumerator];
        NSDictionary * topic;
        while (topic = [enumerator nextObject])
        {
            NSString * topicName = [topic objectForKey:kName];
            if ([self.subscribedTopicNames containsObject:topicName])
            {
                // This topic is a subscribed topic. Add it to the array
                [subscribedTopics addObject:topic];
            }
        }
        
        return subscribedTopics;
    }
    else 
    {
        return nil;
    }
}

- (IBAction)autoReportLocationSwitchValueDidChange
{
    self.autoReportLocationOn = self.autoReportLocationSwitch.on;
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerAutoReportLocationValueDidChange:autoReportLocation:)])
    {
        [self.delegate settingsViewControllerAutoReportLocationValueDidChange:self autoReportLocation:self.autoReportLocationOn];
    }

    if (self.autoReportLocationSwitch.on)
    {
        // When Auto Report Location is on, there are two cases:
        // 1. When high precision is off, there are only two rows:
        //    - Auto Report Location
        //    - High Precision
        // 2. When high precision is on, there are four rows:
        //    - Auto Report Location
        //    - High Precision
        //    - Time Interval
        //    - Distance Filter
        if (self.highPrecisionSwitch.on)
        {
            [self adjustTableView:self.tableView toNumRows:kNumRowsWhenHighPrecisionOn inSection:kLocationTrackingSectionIndex];
        }
        else
        {
            [self adjustTableView:self.tableView toNumRows:kNumRowsWhenHighPrecisionOff inSection:kLocationTrackingSectionIndex];
        }
    }
    else
    {
        // When Auto Report Location is off, there is only one row
        // - Auto Report Location
        [self adjustTableView:self.tableView toNumRows:kNumRowsWhenAutoReportOff inSection:kLocationTrackingSectionIndex];
    }
}

- (IBAction)highPrecisionSwitchValueDidChange
{
    self.highPrecisionUsed = self.highPrecisionSwitch.on;
    
    if (self.delegate && 
        [self.delegate respondsToSelector:@selector(settingsViewControllerHighPrecisionUsedDidChange:highPrecisionUsed:)])
    {
        [self.delegate settingsViewControllerHighPrecisionUsedDidChange:self 
                                                      highPrecisionUsed:self.highPrecisionUsed];
    }
    
    if (self.highPrecisionSwitch.on)
    {
        [self adjustTableView:self.tableView toNumRows:kNumRowsWhenHighPrecisionOn inSection:kLocationTrackingSectionIndex];
    }
    else 
    {
        [self adjustTableView:self.tableView toNumRows:kNumRowsWhenHighPrecisionOff inSection:kLocationTrackingSectionIndex];
    }    
}

- (void)unsubscribeAllTopics
{
    for (NSString * topic in self.subscribedTopicNames)
    {
        [self.serverNotificationManager unsubscribe:topic
                                               host:self.host
                                           username:self.username
                                           password:self.password
                                        deviceToken:self.deviceToken
                                     userAttributes:nil];
    }
    
    [self.subscribedTopicNames removeAllObjects];
    [self setSubscribedTopicsLabelText:0];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerSubscribedTopicNamesDidChange:topicNames:)])
    {
        [self.delegate settingsViewControllerSubscribedTopicNamesDidChange:self 
                                                                topicNames:nil];
    }
    
    [self.trackedTopicNames removeAllObjects];
    [self setTrackedTopicsLabelText:0];    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerTrackedTopicNamesDidChange:topicNames:)])
    {
        [self.delegate settingsViewControllerTrackedTopicNamesDidChange:self 
                                                             topicNames:nil];
    }
}

- (BOOL)hasNoDistanceFilter
{
    return (self.distanceFilter == 0 || self.distanceFilter == kCLDistanceFilterNone);
}

- (NSMutableSet *)cleanupNonExistingTopics:(NSSet *)topics withAlert:(BOOL)showAlert
{
    // Keep track of what is left
    NSMutableSet * remainingTopics = [NSMutableSet setWithCapacity:topics.count];
    NSMutableSet * nonExistingTopics = [NSMutableSet setWithCapacity:0];
    
    // Check each subscribed topic to see if it's in the latest topic list
    for (NSString * topicBeingChecked in topics)
    {
        NSEnumerator * enumerator = [self.topics objectEnumerator];
        NSDictionary * topic;
        BOOL foundOnServer = NO;
        while (topic = [enumerator nextObject])
        {
            NSString * topicName = [topic objectForKey:kName];
            if ([topicBeingChecked compare:topicName] == NSOrderedSame)
            {
                // This subscribed topic exists in the server topic list
                [remainingTopics addObject:topicBeingChecked];
                foundOnServer = YES;
                break;
            }
        }

        if (!foundOnServer)
        {
            [nonExistingTopics addObject:topicBeingChecked];
        }
    }

    if (nonExistingTopics.count > 0 && showAlert)
    {
        // When we are here, the subscribed topic does not exist in the server
        // topic list any more. We should warn the user and remove the
        // subscription.
        NSString * alertViewMessage = nil;
        
        if (nonExistingTopics.count == 1)
        {
            alertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"The topic %@ does not exist on the server any more. It will be removed from the device.", @"Topic Not Found on Server - Description"), [nonExistingTopics anyObject]];
        }
        else
        {
            NSString * topicList = @"";
            for (NSString * topic in nonExistingTopics)
            {
                if (topicList.length == 0)
                {
                    topicList = [topicList stringByAppendingString:topic];
                }
                else
                {
                    topicList = [topicList stringByAppendingFormat:@", %@", topic];
                }
            }
            
            alertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"The topics %@ do not exist on the server any more. They will be removed from the device.", @"Topic Not Found on Server - Description"), topicList];
        }
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Topic Not Found", @"Topic Not Found on Server")
                                                             message:alertViewMessage
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Close", @"Close Button")
                                                   otherButtonTitles:nil];
        [alertView show];
    }

    return remainingTopics;
}

- (void)cleanupSubscribedNonExistingTopics:(BOOL)showAlert
{
    if (!self.subscribedTopicNames || self.subscribedTopicNames.count <= 0 ||
        !self.topics               || self.topics.count <= 0)
    {
        return;   // Nothing to do
    }
    
    // Keep track of what is left
    self.subscribedTopicNames = [self cleanupNonExistingTopics:self.subscribedTopicNames withAlert:showAlert];
    
    // Notify the delegate about the change of the subscription
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerSubscribedTopicNamesDidChange:topicNames:)])
    {
        [self.delegate settingsViewControllerSubscribedTopicNamesDidChange:self
                                                                topicNames:self.subscribedTopicNames];
    }
    
    [self setSubscribedTopicsLabelText:self.subscribedTopicNames.count];
}

- (void)cleanupTrackedNonExistingTopics:(BOOL)showAlert
{
    if (!self.trackedTopicNames || self.trackedTopicNames.count <= 0 ||
        !self.topics            || self.topics.count <= 0)
    {
        return;   // Nothing to do
    }

    // Keep track of what is left
    self.trackedTopicNames = [self cleanupNonExistingTopics:self.trackedTopicNames withAlert:showAlert];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerTrackedTopicNamesDidChange:topicNames:)])
    {
        [self.delegate settingsViewControllerTrackedTopicNamesDidChange:self
                                                             topicNames:self.trackedTopicNames];
    }

    [self setTrackedTopicsLabelText:self.trackedTopicNames.count];
}

- (void)adjustTableView:(UITableView *)tableView toNumRows:(NSUInteger)numRows inSection:(NSUInteger)section
{
    NSInteger currentNumRows = [tableView numberOfRowsInSection:section];
    if (currentNumRows > numRows)
    {
        NSUInteger numRowsToDelete = currentNumRows - numRows;
        NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:numRowsToDelete];
        for (NSInteger index = numRows; index < currentNumRows; ++index)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:section];
            [indexPaths addObject:indexPath];
        }

        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (currentNumRows < numRows)
    {
        NSUInteger numRowsToInsert = numRows - currentNumRows;
        NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:numRowsToInsert];
        for (NSInteger index = currentNumRows; index < numRows; ++index)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:section];
            [indexPaths addObject:indexPath];
        }
        
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
             withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView != tableView)
    {
        return 0;
    }
    else if (section == kLocationTrackingSectionIndex)
    {
        if (self.autoReportLocationSwitch.on)
        {
            if (self.highPrecisionSwitch.on)
            {
                return kNumRowsWhenHighPrecisionOn;
            }
            else
            {
                return kNumRowsWhenHighPrecisionOff;
            }
        }
        else
        {
            return kNumRowsWhenAutoReportOff;
        }
    }
    else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
    case kAccountInformationSectionIndex:
        return NSLocalizedString(@"FME Server Account Information", @"Settings - FME Server Account Information Section Name");
    case kLocationTrackingSectionIndex:
        return NSLocalizedString(@"Location Tracking", @"Settings - Location Tracking Section Name");
    case kReportOptionsSectionIndex:
        return NSLocalizedString(@"Update Options", @"Settings - Update Options");
    default:
        return @"";
    }
}

#pragma mark - Storyboard segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kSegueShowAccountInformation]) {
        FMEServerAccountViewController * accountViewController = (FMEServerAccountViewController*)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        accountViewController.delegate               = self;
        accountViewController.host                   = self.host;
        accountViewController.username               = self.username;
        accountViewController.password               = self.password;    
        accountViewController.centerBottomCustomView = [self createPoweredByFMEServerView];
    }
    else if ([[segue identifier] isEqualToString:kSegueShowTopicsSubscribed]) {
        FMETopicsViewController * topicsViewController = (FMETopicsViewController*)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        topicsViewController.delegate           = self;
        topicsViewController.cancelButtonHidden = NO;
        topicsViewController.cancelButtonTitle  = NSLocalizedString(@"Cancel", nil);
        topicsViewController.finishButtonHidden = NO;
        topicsViewController.finishButtonTitle  = NSLocalizedString(@"Save", nil);
        
        // Remember the topics view controller
        self.subscribedTopicsViewController = topicsViewController;
        
        // We need to copy the topic names to the view controller instead of
        // assigning the pointer of the subscribed topic names to the selected
        // topic names since the view controller may change the selected topic
        // names.
        topicsViewController.selectedTopicNames = [NSMutableSet setWithSet:self.subscribedTopicNames];
        
// TODO: We should check if the subscribed topic name is in the list of topics.
// If not, we should remove the subscribed topic name.
        
        // Request the topics from the server every time to make sure the topics
        // are up-to-date.
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        // Make a url request to the host and see if we have a valid response from
        // getting the topics
        [self.serverNotificationManager getTopicsFromHost:self.host
                                                 username:self.username
                                                 password:self.password];
    }
    else if ([[segue identifier] isEqualToString:kSegueShowTopicsTracked]) {
        FMETopicsViewController * topicsViewController = (FMETopicsViewController*)[segue destinationViewController];
        topicsViewController.delegate = self;
        topicsViewController.cancelButtonHidden = YES;
        topicsViewController.finishButtonHidden = YES;

        // Remember the topics view controller
        self.trackedTopicsViewController = topicsViewController;
        
        // We need to copy the topic names to the view controller instead of
        // assigning the pointer of the tracked topic names to the selected
        // topic names since the view controller may change the selected topic
        // names.
        topicsViewController.selectedTopicNames = [NSMutableSet setWithSet:self.trackedTopicNames];
        
        // Request the topics from the server every time to make sure the topics
        // are up-to-date.
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        // Make a url request to the host and see if we have a valid response from
        // getting the topics
        [self.serverNotificationManager getTopicsFromHost:self.host
                                                 username:self.username
                                                 password:self.password];
    }
    else if ([[segue identifier] isEqualToString:kSegueShowTimeInterval]) {
        FMETimeIntervalViewController * timeIntervalViewController = (FMETimeIntervalViewController *)[segue destinationViewController];
        timeIntervalViewController.delegate = self;
        timeIntervalViewController.minute   = self.timeInterval / 60;
        timeIntervalViewController.second   = (NSUInteger)self.timeInterval % 60;
    }
    else if ([[segue identifier] isEqualToString:kSegueShowDistanceFilter]) {
        FMEDistanceFilterViewController * distanceFilterViewController = (FMEDistanceFilterViewController *)[segue destinationViewController];
        distanceFilterViewController.delegate              = self;
        distanceFilterViewController.distanceFilterInMeter = self.distanceFilter;
    }
    else if ([[segue identifier] isEqualToString:kSegueShowMessage]) {
        FMEMessageEditController * messageEditController = (FMEMessageEditController *)[segue destinationViewController];
        messageEditController.delegate        = self;
        messageEditController.firstNameKey    = self.firstNameKey;
        messageEditController.lastNameKey     = self.lastNameKey;
        messageEditController.emailKey        = self.emailKey;
        messageEditController.subjectKey      = self.subjectKey;
        messageEditController.webAddressKey   = self.webAddressKey;
        messageEditController.detailsKey      = self.detailsKey;
        messageEditController.detailsTypeKey  = self.detailsTypeKey;
    }
}

#pragma mark - FMEServerAccountViewControllerDelegate

- (void)serverAccountViewControllerDidCancel:(FMEServerAccountViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)serverAccountViewControllerDidFinish:(FMEServerAccountViewController *)controller 
{
    if (![FMEServerNotificationManager isHostReachable:controller.host])
    {
        [FMESettingsViewController showHostUnreachableAlertView];
        return;
    }
    
    if ([self hasHostOrUsernameChanged:controller.host username:controller.username] &&
        [self hasSubscriptions])
    {
        // Remember the account view controller so
        // that we can access them when the action sheet dismisses.
        self.accountViewController = controller;
        
        // Confirm Save
        self.confirmAccountSaveActionSheet
            = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Do you want to save the change and remove all previous subscriptions?", nil) 
                                          delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"Don't Save", nil) 
                            destructiveButtonTitle:NSLocalizedString(@"Save", nil)
                                 otherButtonTitles:nil];
        [self.confirmAccountSaveActionSheet showInView:controller.view];
    }
    else if ([self hasHostOrUsernameChanged:controller.host username:controller.username] ||
             [self hasPasswordChanged:controller.password])
    {
        // The account info has changed, we should verify the new account info
        self.accountViewController = controller;
        [self validateAccountInfo:controller];
    }
    else 
    {
        // No change. Simply dimiss the controller
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - FMETopicsViewControllerDelegate

- (void)topicsViewController:(FMETopicsViewController *)topicsViewController didSelectTopic:(NSString *)topicName
{
    if (self.trackedTopicsViewController == topicsViewController)
    {
        [self.trackedTopicNames addObject:topicName];
        [self setTrackedTopicsLabelText:self.trackedTopicNames.count];
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(settingsViewControllerTrackedTopicNamesDidChange:topicNames:)])
        {
            [self.delegate settingsViewControllerTrackedTopicNamesDidChange:self
                                                                 topicNames:self.trackedTopicNames];
        }
    }
}

- (void)topicsViewController:(FMETopicsViewController *)topicsViewController didDeselectTopic:(NSString *)topicName
{
    if (self.trackedTopicsViewController == topicsViewController)
    {
        [self.trackedTopicNames removeObject:topicName];
        [self setTrackedTopicsLabelText:self.trackedTopicNames.count];
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(settingsViewControllerTrackedTopicNamesDidChange:topicNames:)])
        {
            [self.delegate settingsViewControllerTrackedTopicNamesDidChange:self
                                                                 topicNames:self.trackedTopicNames];
        }
    }    
}

- (void)topicsViewControllerDidCancel:(FMETopicsViewController *)topicsViewController
{
    if (self.subscribedTopicsViewController == topicsViewController)
    {
        self.subscribedTopicsViewController = nil;
        [topicsViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)topicsViewControllerDidFinish:(FMETopicsViewController *)topicsViewController
{
    if (self.subscribedTopicsViewController != topicsViewController)
    {
        return;
    }
    
    if (![FMEServerNotificationManager isHostReachable:self.host])
    {
        [FMESettingsViewController showHostUnreachableAlertView];
        return;
    }
    
    topicsViewController.navigationItem.leftBarButtonItem  = nil;
    topicsViewController.navigationItem.rightBarButtonItem = nil;
    FMEActivityIndicatorTitleView * titleView
        = [[FMEActivityIndicatorTitleView alloc] initWithFrame:
           CGRectMake(0.0f, 
                      0.0f,
                      topicsViewController.navigationController.navigationBar.frame.size.width, 
                      topicsViewController.navigationController.navigationBar.frame.size.height)];
    [titleView setTitle:NSLocalizedString(@"Saving", @"Navigation Bar Title - Subscribing/Unsubscribing")];
    topicsViewController.navigationItem.titleView = titleView;
    
    // Find all the topic names to be subscribed
    NSMutableSet * topicNamesToBeSubscribed = [NSMutableSet setWithCapacity:1];
    if (topicsViewController.selectedTopicNames)
    {
        NSEnumerator * enumerator = [topicsViewController.selectedTopicNames objectEnumerator];
        NSString * topicName;
        while (topicName = [enumerator nextObject])
        {
            if (![self.subscribedTopicNames containsObject:topicName])
            {
                [topicNamesToBeSubscribed addObject:topicName];
            }
        }
    }
    
    // Find all the topic names to be unsubscribed
    NSMutableSet * topicNamesToBeUnsubscribed = [NSMutableSet setWithCapacity:1];
    if (self.subscribedTopicNames)
    {
        NSEnumerator * enumerator = [self.subscribedTopicNames objectEnumerator];
        NSString * topicName;
        while (topicName = [enumerator nextObject])
        {
            if (![topicsViewController.selectedTopicNames containsObject:topicName])
            {
                [topicNamesToBeUnsubscribed addObject:topicName];
            }
        }
    }

    // Remember all the unprocessed topic names first. We will know which topic
    // has been processed. When all the topics have been processed, we can
    // dismiss the topics view controller.
    self.unprocessedTopicNames = [NSMutableSet setWithSet:topicNamesToBeSubscribed];
    [self.unprocessedTopicNames addObjectsFromArray:[topicNamesToBeUnsubscribed allObjects]];
         
    // Subscribe to the newly added topics
    NSEnumerator * subscribingEnumerator = [topicNamesToBeSubscribed objectEnumerator];
    if (subscribingEnumerator)
    {
        NSString * topicName;
        while (topicName = [subscribingEnumerator nextObject])
        {
            [self.serverNotificationManager subscribe:topicName
                                                 host:self.host
                                             username:self.username
                                             password:self.password
                                          deviceToken:self.deviceToken
                                             location:self.location
                                       userAttributes:self.userAttributes];
        }
    }

    // Unsubscribe to the newly removed topics
    NSEnumerator * unsubscribingEnumerator = [topicNamesToBeUnsubscribed objectEnumerator];
    if (unsubscribingEnumerator)
    {
        NSString * topicName;
        while (topicName = [unsubscribingEnumerator nextObject])
        {
            [self.serverNotificationManager unsubscribe:topicName 
                                                   host:self.host
                                               username:self.username
                                               password:self.password
                                            deviceToken:self.deviceToken
                                         userAttributes:self.userAttributes];
        }
    }
    
    [self updateSubscribedTopicsViewController];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.confirmAccountSaveActionSheet == actionSheet)
    {
        if (self.confirmAccountSaveActionSheet.destructiveButtonIndex == buttonIndex)
        {
            // Validate the new account info
            if (self.accountViewController)
            {
                [self validateAccountInfo:self.accountViewController];
            }
        }
        else 
        {
            NSLog(@"The Confirm Account Save Action Sheet contains an unknown button.");
        }
    }
}

#pragma mark - FMEServerNotificationManager

- (void)getTopicsDidFinish:(NSArray *)topics
{
    // Sort the topics case-insensitively
    self.topics = [topics sortedArrayUsingComparator: ^(id obj1, id obj2)
    {
        NSString * string1 = [obj1 objectForKey:kName];
        NSString * string2 = [obj2 objectForKey:kName];
        return [string1 localizedCaseInsensitiveCompare:string2];
    }];
    
    for (int i = 0; i < self.topics.count; ++i)
    {
        NSLog(@"%@", [[self.topics objectAtIndex:i] objectForKey:@"name"]);
    }
    
    // If the account view controller is still being shown, we should dismiss
    // it now and save any new account info in the user defaults. We should
    // also unsubscribe any existing topics.
    if (self.accountViewController)
    {
        // NOTE: If the previous account or topics do not exist on the server
        // anymore, the operation will fail too.
        if ([self hasHostOrUsernameChanged:self.accountViewController.host
                                  username:self.accountViewController.username])
        {
            // We should unsubscribe all previous topics
            [self unsubscribeAllTopics];
            
            // Store the new account info
            self.host = self.accountViewController.host;
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(settingsViewControllerHostDidChange:host:)])
            {
                [self.delegate settingsViewControllerHostDidChange:self
                                                              host:self.host];
            }
            self.username = self.accountViewController.username;
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(settingsViewControllerUsernameDidChange:username:)])
            {
                [self.delegate settingsViewControllerUsernameDidChange:self
                                                              username:self.username];
            }
            
            // Update the UI
            self.hostLabel.text     = self.host;
            self.usernameLabel.text = self.username;
        }

        if ([self hasPasswordChanged:self.accountViewController.password])
        {
            // Store the new password
            self.password = self.accountViewController.password;
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(settingsViewControllerPasswordDidChange:password:)])
            {
                [self.delegate settingsViewControllerPasswordDidChange:self
                                                              password:self.password];
            }
        }

        // Dismiss the account view controller
        [self.accountViewController dismissViewControllerAnimated:YES completion:nil];
        self.accountViewController = nil;
    }
    
    if (self.subscribedTopicsViewController)
    {
        // When we have subscription, we will also have tracked topics. We only
        // want to warn the user once about the non-existing topics. Since the
        // subscribed topics is a superset of tracked topics, we warn the user
        // when checking subscribed topics.
        [self cleanupSubscribedNonExistingTopics:YES];
        [self cleanupTrackedNonExistingTopics:NO];

        self.subscribedTopicsViewController.topics = self.topics;
    }
    
    if (self.trackedTopicsViewController)
    {
        // When we don't have subscription, we only need to check the tracked
        // topics and warn the user.
        [self cleanupTrackedNonExistingTopics:YES];

        if (self.listAllTopics)
        {
            self.trackedTopicsViewController.topics = self.topics;
        }
        else 
        {
            self.trackedTopicsViewController.topics = [self getSubscribedTopics];
        }
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)getTopicsDidFail:(NSError *)error
{
    // If the account view controller is still being shown, we should display
    // an alert view to show an error about the account information.
    if (self.accountViewController)
    {
        // Enable the buttons on the account view controller
        self.accountViewController.navigationItem.leftBarButtonItem
            = self.accountViewController.cancelButton;
        self.accountViewController.navigationItem.rightBarButtonItem
            = self.accountViewController.saveButton;
        self.accountViewController.navigationItem.titleView = nil;
        
        self.accountViewController = nil;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    UIAlertView * invalidAccountAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failure", nil) 
                                                                       message:NSLocalizedString(@"Please check your network connection and your account information.", nil)
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                                             otherButtonTitles:nil];
    [invalidAccountAlertView show];
}

- (void)updateSubscribedTopicsViewController
{
    // Notify the delegate about the change of the subscription
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerSubscribedTopicNamesDidChange:topicNames:)])
    {
        [self.delegate settingsViewControllerSubscribedTopicNamesDidChange:self
                                                                topicNames:self.subscribedTopicNames];
    }
    
    // Aslo notify the delegate about the tracked topics since they are the
    // same as the subscribed topics now.
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerTrackedTopicNamesDidChange:topicNames:)])
    {
        [self.delegate settingsViewControllerTrackedTopicNamesDidChange:self
                                                             topicNames:self.trackedTopicNames];
    }

    if (self.subscribedTopicsViewController)
    {
        if (self.unprocessedTopicNames.count <= 0)
        {
            // Update the subscribed topic field
            [self setSubscribedTopicsLabelText:self.subscribedTopicNames.count];
            
            // 
            
            [self setTrackedTopicsLabelText:self.trackedTopicNames.count];
            
            // Dismiss the subscribed topics view controller
            [self.subscribedTopicsViewController dismissViewControllerAnimated:YES completion:nil];
            
            // We don't need to access the topics view controller anymore since the
            // Finish button was tapped.
            self.subscribedTopicsViewController = nil;
        }
    }
}
         
- (void)subscribeDidFinish:(NSString *)topicName
                      host:(NSString *)host
                  username:(NSString *)username
                  password:(NSString *)password
               deviceToken:(NSString *)deviceToken
                  location:(CLLocation *) location
            userAttributes:(NSDictionary *)userAttributes
{
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
    
    [self.unprocessedTopicNames removeObject:topicName];
    [self.subscribedTopicNames addObject:topicName];
    [self.trackedTopicNames addObject:topicName];
    [self updateSubscribedTopicsViewController];
}

- (void)subscribeDidFail:(NSString *)topicName 
                    host:(NSString *)host
                username:(NSString *)username
                password:(NSString *)password
             deviceToken:(NSString *)deviceToken
                location:(CLLocation *) location
          userAttributes:(NSDictionary *)userAttributes
                   error:(NSError *)error
{
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
 
    [self.unprocessedTopicNames removeObject:topicName];
    [self updateSubscribedTopicsViewController];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to subscribe", @"Failed to subscribe")
                                                         message:[NSString stringWithFormat:NSLocalizedString(@"Unable to subscribe to %@", @"Unable to subscribe to topic"), topicName]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Close", @"Close")
                                               otherButtonTitles:nil];
    [alertView show];
}

- (void)unsubscribeDidFinish:(NSString *)topicName
                        host:(NSString *)host
                    username:(NSString *)username
                    password:(NSString *)password
                 deviceToken:(NSString *)deviceToken
              userAttributes:(NSDictionary *)userAttributes
{
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
    
    [self.unprocessedTopicNames removeObject:topicName];
    [self.subscribedTopicNames removeObject:topicName];
    [self updateSubscribedTopicsViewController];
    
    // We also need to remove any tracked topic names that are no
    // longer in the list of subscribed topics.
    if ([self.trackedTopicNames containsObject:topicName])
    {
        [self.trackedTopicNames removeObject:topicName];
        [self setTrackedTopicsLabelText:self.trackedTopicNames.count];
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(settingsViewControllerTrackedTopicNamesDidChange:topicNames:)])
        {
            [self.delegate settingsViewControllerTrackedTopicNamesDidChange:self
                                                                 topicNames:self.trackedTopicNames];
        }
    }
}

- (void)unsubscribeDidFail:(NSString *)topicName 
                      host:(NSString *)host
                  username:(NSString *)username
                  password:(NSString *)password
               deviceToken:(NSString *)deviceToken
            userAttributes:(NSDictionary *)userAttributes
                     error:(NSError *)error
{
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
    [self.unprocessedTopicNames removeObject:topicName];
    [self updateSubscribedTopicsViewController];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to cancel subscription", @"Failed to cancel subscription")
                                                         message:[NSString stringWithFormat:NSLocalizedString(@"Unable to cancel your subscription from %@", @"Unable to cancel your subscription from topic"), topicName]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Close", @"Close")
                                               otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - FMETimeIntervalViewControllerDelegate

- (void)timeIntervalDidChange:(NSTimeInterval)timeInterval
{
    self.timeInterval = timeInterval;
    [self setTimeIntervalLabelText:timeInterval];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerTimeIntervalDidChange:timeInterval:)])
    {
        [self.delegate settingsViewControllerTimeIntervalDidChange:self
                                                      timeInterval:self.timeInterval];
    }
    
    // Either the time interval or the distance filter must be non-zero.
    // If the user sets the time interval to 0, we will set the distance
    // filter to the application default.
    if (self.timeInterval == 0 && [self hasNoDistanceFilter])
    {
        [self distanceFilterDidChange:self.defaultDistanceFilter];
    }
}

#pragma mark - FMEDistanceFilterViewControllerDelegate

- (void)distanceFilterDidChange:(CLLocationDistance)distanceFilterInMeter
{
    self.distanceFilter = distanceFilterInMeter;
    [self setDistanceFilterLabelText:distanceFilterInMeter];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewControllerDistanceFilterDidChange:distanceFilter:)])
    {
        [self.delegate settingsViewControllerDistanceFilterDidChange:self
                                                      distanceFilter:self.distanceFilter];
    }
    
    // Either the time interval or the distance filter must be non-zero.
    // If the user sets the distance filter to 0, we will set the time
    // interval to the application default.
    if (self.timeInterval == 0 && [self hasNoDistanceFilter])
    {
        [self timeIntervalDidChange:self.defaultTimeInterval];
    }
}

#pragma mark - Class functions

+ (void)showHostUnreachableAlertView
{
    UIAlertView * hostUnreachableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Host Unreachable", "Host Unreachable Alert - Title")
                                                                    message:NSLocalizedString(@"Please check the network connection and the host name", "Host Unreachable Alert - Description")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Close", @"Close")
                                                          otherButtonTitles:nil];
    [hostUnreachableAlert show];
}

#pragma mark - FMEMessageEditController

- (void)messageEditControllerViewDidLoad:(FMEMessageEditController *)controller
{
    controller.firstName.text  = [self.userAttributes objectForKey:self.firstNameKey];
    controller.lastName.text   = [self.userAttributes objectForKey:self.lastNameKey];
    controller.email.text      = [self.userAttributes objectForKey:self.emailKey];
    controller.subject.text    = [self.userAttributes objectForKey:self.subjectKey];
    controller.webAddress.text = [self.userAttributes objectForKey:self.webAddressKey];
    controller.details.text    = [self.userAttributes objectForKey:self.detailsKey];
}

- (void)messageEditController:(FMEMessageEditController *)controller valueDidChange:(NSString *)value forKey:(NSString *)key
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(settingsViewController:valueDidChange:forKey:)])
    {
        [self.delegate settingsViewController:self valueDidChange:value forKey:key];
    }
}

@end
