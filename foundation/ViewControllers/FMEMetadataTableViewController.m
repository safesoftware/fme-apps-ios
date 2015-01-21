/*============================================================================= 
 
   Name     : FMEMetadataTableViewController.m
 
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

#import "FMEMetadataTableViewController.h"

static NSString * kSegueAddMetadata = @"AddMetadata";

enum MetadataMode
{
    ADD = 0,
    EDIT
};

@interface FMEMetadataTableViewController ()

@property (nonatomic, retain) NSArray * sortedMetadataNames;
@property (nonatomic) enum MetadataMode mode;

- (NSArray *)createSortedMetadataNames:(NSDictionary *)dictionary;
@end

@implementation FMEMetadataTableViewController

@synthesize metadata = metadata_;
@synthesize sortedMetadataNames = sortedMetadataNames_;
@synthesize mode = mode_;
@synthesize delegate = delegate_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        metadata_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.navigationItem) {
        self.navigationItem.title = NSLocalizedString(@"Metadata", nil);
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setMetadata:(NSDictionary *)metadata
{
    metadata_ = [NSMutableDictionary dictionaryWithDictionary:metadata];
    self.sortedMetadataNames = [self createSortedMetadataNames:self.metadata];
    [self.tableView reloadData];
}

- (NSArray *)createSortedMetadataNames:(NSDictionary *)dictionary
{
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                 initWithKey:@""
                                 ascending:YES
                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
    NSMutableArray * array = [NSMutableArray arrayWithArray:dictionary.allKeys];
    [array sortUsingDescriptors:sortDescriptors];
    return array;
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.metadata.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MetadataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (0 <= indexPath.row && indexPath.row < self.sortedMetadataNames.count)
    {
        cell.textLabel.text = [self.sortedMetadataNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.metadata objectForKey:cell.textLabel.text];
    }
    
    return cell;
}

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

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

#pragma mark - Storyboard segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kSegueAddMetadata]) {
        FMEMetadataEditViewController * controller = (FMEMetadataEditViewController*)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        controller.delegate                        = self;
        controller.key                             = @"Dump Key";
        controller.value                           = @"Dump Value";
        controller.navigationItem.title            = NSLocalizedString(@"New Metadata", @"New Metadata - Title");
        
        self.mode                                  = ADD;
    }
}

#pragma mark - FMEMetadataEditViewControllerDelegate implementation

- (void)metadataEditViewControllerDidCancel:(FMEMetadataEditViewController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)metadataEditViewControllerDidFinish:(FMEMetadataEditViewController *)controller
{
    [self.metadata setObject:controller.value forKey:controller.key];

    if (self.mode == ADD)
    {
        [self.delegate metadataDidAdd:controller.key value:controller.value];
        self.sortedMetadataNames = [self createSortedMetadataNames:self.metadata];
    }
    else if (self.mode == EDIT)
    {
        // If the key is different, we should also sort the keys
        // We should also pass the old and new key to the delegate
        [self.delegate metadataDidEdit:controller.key value:controller.value];
    }
    
    [self.tableView reloadData];
    [controller dismissModalViewControllerAnimated:YES];
}

@end
