/*============================================================================= 
 
   Name     : FMETopicDetailsViewController.m
 
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

#import "FMETopicDetailsViewController.h"
#import "FMEMetadataTableViewController.h"

static NSString * kShowUserData = @"ShowUserData";
static NSString * kTopicPrefix      = @"Topic ";

@interface FMETopicDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@end

@implementation FMETopicDetailsViewController

@synthesize topicName      = topicName_;
@synthesize topicNameLabel = topicNameLabel_;

- (void)setTopicName:(NSString *)topicName
{
    topicName_ = topicName;
    self.topicNameLabel.text = topicName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topicNameLabel.text = self.topicName;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kShowUserData])
    {
        FMEMetadataTableViewController * controller
            = (FMEMetadataTableViewController*)[segue destinationViewController];
        controller.delegate = self;
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary * userData = [userDefaults dictionaryForKey:[NSString stringWithFormat:@"%@%@", kTopicPrefix, self.topicName]];
        if (userData)
        {
            controller.metadata = [NSMutableDictionary dictionaryWithDictionary:userData];
        }
    }
    //    if ([[segue identifier] isEqualToString:kShowTopicDetails])
    //    {
    //        NSMutableDictionary * topic = (NSMutableDictionary *)sender;
    //
    //        FMETopicDescriptionViewController * controller = (FMETopicDescriptionViewController*)[segue destinationViewController];
    //        controller.title = [topic objectForKey:kName];
    //        controller.html  = [topic objectForKey:kDescription];
    //    }
}


- (void)viewDidUnload {
    [self setTopicNameLabel:nil];
    [super viewDidUnload];
}

#pragma mark - FMEMetadataTableViewControllerDelegate implementation

- (void)metadataDidAdd:(NSString *)key value:(NSString *)value
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * topicKey = [NSString stringWithFormat:@"%@%@", kTopicPrefix, self.topicName];
    NSDictionary * userData = [userDefaults dictionaryForKey:topicKey];
    NSMutableDictionary * updatedData = [NSMutableDictionary dictionaryWithDictionary:userData];
    [updatedData setObject:value forKey:key];
    [userDefaults setObject:updatedData forKey:topicKey];
}

- (void)metadataDidEdit:(NSString *)key value:(NSString *)value
{
    
}

@end
