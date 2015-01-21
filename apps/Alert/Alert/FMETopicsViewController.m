/*============================================================================= 
 
   Name     : FMETopicsViewController.m
 
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

#import "FMETopicsViewController.h"
#import "FMETopicDescriptionViewController.h"
#import "NSData+Additions.h"
#import "NSMutableURLRequest+BasicAccessAuthentication.h"

static NSString * kTopicsCellIdentifier = @"TopicsCellIdentifier";
static NSString * kName                 = @"name";
static NSString * kDescription          = @"description";

// Storyboard segue identifiers
static NSString * kShowTopicDescription = @"ShowTopicDescription";

#pragma mark - Private Declaration

@interface FMETopicsViewController ()

// Private Functions
//- (void)displayActivityAlert;
//- (void)reloadTopics;
//- (void)reloadingTopicsDidFail;
- (void)updateCancelButtonVisibility;
- (void)updateFinishButtonVisibility;

- (IBAction)cancel:(id)sender;
- (IBAction)finish:(id)sender;
@end


#pragma mark - FMETopicsViewController Implementation

@implementation FMETopicsViewController

@synthesize topics = topics_;
@synthesize selectedTopicNames = selectedTopicNames_;
@synthesize delegate = delegate_;
@synthesize cancelButton = cancelButton_;
@synthesize finishButton = finishButton_;
@synthesize cancelButtonTitle   = cancelButtonTitle_;
@synthesize finishButtonTitle   = finishButtonTitle_;
@synthesize cancelButtonHidden = cancelButtonHidden_;
@synthesize finishButtonHidden = finishButtonHidden_;

#pragma mark - View Life Cycle

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])) {
        
        // Init topic containers to track changes in topic selection
        topics_ = nil;
        selectedTopicNames_ = nil;        
        cancelButtonTitle_ = NSLocalizedString(@"Cancel", nil);
        finishButtonTitle_ = NSLocalizedString(@"Finish", nil);
        cancelButtonHidden_ = YES;
        finishButtonHidden_ = YES;
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationItem) {
        self.navigationItem.title = NSLocalizedString(@"Topics", nil);
    }

    [self updateCancelButtonVisibility];
    [self updateFinishButtonVisibility];
    
//    // Init the FME Server Notification Manager
//    self.fmeServerNotificationManager = [[FMEServerNotificationManager alloc] init];
//    //self.fmeServerNotificationManager.delegate = self;
        
    // Allow multiple selections
    if (self.tableView)
    {
        UITableView * tableView = (UITableView *)tableView;
        //tableView.allowsMultipleSelection = YES;
                
        [self setEditing:YES];        
        //[self.tableView setEditing:YES];
    }
    
    // Reload topics from the server
    //[self reloadTopics];
}

- (void)viewDidUnload
{
    self.topics = nil;
    self.selectedTopicNames = nil;
    self.delegate = nil;
    self.cancelButton = nil;
    self.finishButton = nil;
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
        [self.delegate respondsToSelector:@selector(topicsViewControllerDidCancel:)])
    {
        [self.delegate topicsViewControllerDidCancel:self];
    }
}

- (IBAction)finish:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topicsViewControllerDidFinish:)])
    {
        [self.delegate topicsViewControllerDidFinish:self];
    }
}

#pragma mark - UIAlertViewDelegate protocol implementation

//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if (self.errorAlert == alertView)
//    {
//        [self.delegate didFailToLoadSubscriptions:self];
//        self.errorAlert = nil;
//    }
//    else if (self.activityAlert == alertView && buttonIndex != kActivityAlertInvalidButtonIndex)
//    {
//        [self.delegate didCancelLoadingSubscriptions:self];
//        self.activityAlert = nil;
//    }
//}

//- (void)willPresentAlertView:(UIAlertView *)alertView
//{
//    if (self.activityAlert == alertView)
//    {
//        // Add the activity indicator to the activity alert
//        
//        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        
//        // Adjust the indicator so it is up a few pixels from the bottom of the 
//        // alert
//        // The alert view must be ready to be shown before calculating the center 
//        // using the alert's bounds since the alert's bounds are not initialized 
//        // until the alert is ready
//        indicator.center = CGPointMake(self.activityAlert.bounds.size.width / 2, self.activityAlert.bounds.size.height / 2);
//        [indicator startAnimating];
//        [self.activityAlert addSubview:indicator];   
//    }
//}

#pragma mark - Properties

- (void)setTopics:(NSArray *)topics
{
    topics_ = topics;
    
    // Reload the table view
    if (self.tableView)
    {
        [self.tableView reloadData];
    }
}

- (NSMutableSet *)selectedTopicNames
{
    if (selectedTopicNames_ == nil)
    {
        selectedTopicNames_ = [[NSMutableSet alloc] initWithCapacity:1];
    }
    
    return selectedTopicNames_;
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle
{
    cancelButtonTitle_ = cancelButtonTitle;
    self.cancelButton.title = cancelButtonTitle;
}

- (void)setFinishButtonTitle:(NSString *)finishButtonTitle
{
    finishButtonTitle_ = finishButtonTitle;
    self.finishButton.title = finishButtonTitle;
}

- (void)setFinishButtonHidden:(BOOL)finishButtonHidden
{
    finishButtonHidden_ = finishButtonHidden;
    [self updateFinishButtonVisibility];
}

- (void)setCancelButtonHidden:(BOOL)cancelButtonHidden
{
    cancelButtonHidden_ = cancelButtonHidden;
    [self updateCancelButtonVisibility];
}

#pragma mark - Private functions

- (void)updateCancelButtonVisibility
{
    if (!self.navigationItem)
    {
        return;
    }
    
    if (self.cancelButtonHidden)
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else if (self.cancelButton)
    {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    }    
}

- (void)updateFinishButtonVisibility
{
    if (!self.navigationItem)
    {
        return;
    }
    
    if (self.finishButtonHidden)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else if (self.finishButton)
    {
        self.navigationItem.rightBarButtonItem = self.finishButton;
    }   
}

//- (void)displayActivityAlert
//{
//    self.activityAlert 
//       = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Loading Topics\nPlease Wait ...", @"")
//                                    message:@"\n\n"  // Give room to the activity indicator
//                                   delegate:self 
//                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
//                          otherButtonTitles:nil];
//    [self.activityAlert show];    
//}

//- (void)reloadTopics
//{   
//    //[self displayActivityAlert];
//    // Start the timer
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 
//                                                  target:self 
//                                                selector:@selector(reloadingTopicsDidFail)
//                                                userInfo:nil
//                                                 repeats:NO];
//    
//    [self.fmeServerNotificationManager getTopicsFromHost:self.host 
//                                                username:self.username 
//                                                password:self.password];
//    
//}

//- (void)reloadingTopicsDidFail
//{
//    // Invalidate the timer
//    if (self.timer)
//    {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//    
//    // Clear the list of topics
//    self.topics = nil;
//    if ([self.view isKindOfClass:[UITableView class]])
//    {
//        UITableView * tableView = (UITableView *)self.view;
//        [tableView reloadData];
//    }
//
//    // Display an error
//    self.errorAlertView 
//    = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable To Load Topics", @"")
//                                 message:NSLocalizedString(@"Please make sure the network settings, host and login information are correct", @"") 
//       
//                                delegate:self
//                       cancelButtonTitle:NSLocalizedString(@"Close", @"")
//                       otherButtonTitles:NSLocalizedString(@"Retry", @""), nil];
//    [self.errorAlertView show];
//}
//
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (self.topics) ? self.topics.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTopicsCellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                      reuseIdentifier:kTopicsCellIdentifier];
    }
    
    // Configure the cell...    
    NSDictionary * topic = [self.topics objectAtIndex:indexPath.row];
    NSString * topicName = [topic objectForKey:kName]; 
    cell.textLabel.text = topicName;
    cell.detailTextLabel.text = [topic objectForKey:kDescription];

    if ([self.selectedTopicNames containsObject:topicName])
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
}

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSDictionary * topic = [self.topics objectAtIndex:indexPath.row];
//    NSString * topicName = [topic objectForKey:kName]; 
//    if ([self.selectedTopicNames containsObject:topicName])
//    {
////        cell.selected = YES;
//    }
//    else 
//    {
////        cell.selected = NO;
//    }
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * topic = [self.topics objectAtIndex:indexPath.row];
    NSString * topicName = [topic objectForKey:kName];
    [self.selectedTopicNames addObject:topicName];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(topicsViewController:didSelectTopic:)])
    {
        [self.delegate topicsViewController:self didSelectTopic:topicName];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * topic = [self.topics objectAtIndex:indexPath.row];
    NSString * topicName = [topic objectForKey:kName];
    [self.selectedTopicNames removeObject:topicName];

    if (self.delegate && [self.delegate respondsToSelector:@selector(topicsViewController:didDeselectTopic:)])
    {
        [self.delegate topicsViewController:self didDeselectTopic:topicName];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView != tableView)
    {
        return;
    }
    
    [self performSegueWithIdentifier:kShowTopicDescription sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}


#pragma mark - Storyboard segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kShowTopicDescription])
    {
        UITableViewCell * tableViewCell = (UITableViewCell *)sender;

        FMETopicDescriptionViewController * controller = (FMETopicDescriptionViewController*)[segue destinationViewController];
        controller.title = tableViewCell.textLabel.text;
        controller.html  = tableViewCell.detailTextLabel.text;
    }

}

@end
