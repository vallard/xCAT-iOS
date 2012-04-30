//
//  EventLogViewController.m
//  xCAT
//
//  Created by Vallard Benincosa on 12/23/11.
//  Copyright (c) 2011 Benincosa Inc. All rights reserved.
//

#import "EventLogViewController.h"
#import "xCATAppDelegate.h"
#import "xCATClient.h"
#import "xCATNode.h"
#import "ItemViewController.h"

#define DEBUG 1

@implementation EventLogViewController
@synthesize noderange;
@synthesize events;
@synthesize theTable;
@synthesize bottomToolBar;
@synthesize function;

- (IBAction)forwardActions:(id)sender {
    
    UIActionSheet *forwardActionSheet;
    if ([function isEqualToString:@"reventlog"]) {
        forwardActionSheet = [[UIActionSheet alloc ] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Event Log", @"Clear Event Log", nil];
    }else if ([function isEqualToString:@"rinv"]) {
        forwardActionSheet = [[UIActionSheet alloc ] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Inventory", nil];
    }else {
        forwardActionSheet = [[UIActionSheet alloc ] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Vitals", nil];
    }
    
	[forwardActionSheet showFromToolbar:bottomToolBar];
    [forwardActionSheet release];
}

// prompt user that we are doing an xCAT call behind the scenes.
- (void)showActivity {
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 11.0f, 120.0f, 21.0f)];
    
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.text = @"Updating...";
    loadingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    loadingLabel.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:loadingLabel];

    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

                             
    NSArray *items = [[NSArray alloc] initWithObjects:spacer, item, item2,spacer, nil];
    [bottomToolBar setItems:items];
    [items release];
    //[item release];
    [spacer release];
    [loadingLabel release];
    [activityView release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    //[noderange release];
    //[events release];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([function isEqualToString:@"reventlog"]) {
        self.title = @"Event Log";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetEventLog) name:@"eventLogUpdated" object:nil];
    }else if([function isEqualToString:@"rvitals"]){
        self.title = @"Vitals";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetVitals) name:@"vitalsUpdated" object:nil];
    }else if([function isEqualToString:@"rinv"]){
        self.title = @"Inventory";
        // we can use the same callback function for inv as vitals since it parses it the same.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetVitals) name:@"invUpdated" object:nil];
    }
    
  
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    xCATNode *nr = [theApp getNode:noderange];
    if ([function isEqualToString:@"reventlog"] && nr && nr.events) {
        events = nr.events;
        [theTable reloadData];
    }else if([function isEqualToString:@"rvitals"] && nr && nr.vitals) {
        events = nr.vitals;
        [theTable reloadData];
    }else if([function isEqualToString:@"rinv"] && nr && nr.inv){
        events = nr.inv;
        [theTable reloadData];
    }
    
    [self showActivity];
    [theApp xcmd:function noderange:self.noderange subcommand:@"all"];

}

- (void)clearEventLog {
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self showActivity];
    [theApp xcmd:@"reventlog" noderange:self.noderange subcommand:@"clear"];

}

- (void)didGetEventLog {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (DEBUG ) {
            NSLog(@"EventLogViewController:didGetEventLog");
            NSLog(@"#####################################");
        }
        
        xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
        xCATNode *thisNode = [theApp getNode:self.noderange];
        self.events = thisNode.events;
        // check here if the first item is an error message:
        NSString *isError = [self.events objectForKey:@"Error"];
        if (isError ){
            // put nothing in the toolbar.
            [bottomToolBar setItems:nil];
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error" message:isError delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [al show];
            [al release];
        }else {
            // put nothing in the toolbar.
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(forwardActions:)];
            
            [bottomToolBar setItems:[NSArray arrayWithObjects:spacer, item, nil]];
            [spacer release];
            [item release];
            
            [theTable reloadData];
        }
    });
}



- (void)didGetVitals {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (DEBUG ) {
            NSLog(@"EventLogViewController:didGetVitals");
            NSLog(@"#####################################");
        }
        
        xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
        xCATNode *thisNode = [theApp getNode:self.noderange];
        if ([function isEqualToString:@"rvitals"]) {
            self.events = thisNode.vitals;
        }else if([function isEqualToString:@"rinv"]) {
            self.events = thisNode.inv;
        }
        
        // check here if the first item is an error message:
        NSString *isError = [self.events objectForKey:@"Error"];
        if (isError ){
            // put nothing in the toolbar.
            [bottomToolBar setItems:nil];
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Error" message:isError delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [al show];
            [al release];
        }else {
            // put nothing in the toolbar.
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(forwardActions:)];
            
            [bottomToolBar setItems:[NSArray arrayWithObjects:spacer, item, nil]];
            [spacer release];
            [item release];
            
            [theTable reloadData];
        }
    });
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.noderange = nil;
    self.events = nil;
    self.theTable = nil;
    self.bottomToolBar = nil;
    self.function = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.theTable deselectRowAtIndexPath:[self.theTable indexPathForSelectedRow] animated:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [[events allKeys] count];    
}


- (UIImage *)getImageForCell:(NSString *)key {
    UIImage *img;
    img = nil;

    // Now do regex match
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"Temp|temp|tmp|TMP" options:0 error:NULL];
    if ([regex numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0 ) {
        img = [UIImage imageNamed:@"Thermometer@25.png"];
        return img;
    }
    regex = [NSRegularExpression regularExpressionWithPattern:@"power|Power|Energy|energy|Planar .*V" options:0 error:NULL];
    if ([regex numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0 ) {
        img = [UIImage imageNamed:@"power@25x25.png"];
        return img;
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"CPU|cpu|proc|Proc|Cpu" options:0 error:NULL];
    if ([regex numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0 ) {
        img = [UIImage imageNamed:@"processor.png"];
        return img;
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"DIMM|dimm|Memory|memory" options:0 error:NULL];
    if ([regex numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0 ) {
        img = [UIImage imageNamed:@"dimm.png"];
        return img;
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"FAN|fan|Fan" options:0 error:NULL];
    if ([regex numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0 ) {
        img = [UIImage imageNamed:@"fan@25x25.png"];
        return img;
    }
    regex = [NSRegularExpression regularExpressionWithPattern:@"DASD|Drive|Hard disk" options:0 error:NULL];
    if ([regex numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0 ) {
        img = [UIImage imageNamed:@"hard-drive.png"];
        return img;
    }
    regex = [NSRegularExpression regularExpressionWithPattern:@"Network|PCI" options:0 error:NULL];
    if ([regex numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0 ) {
        img = [UIImage imageNamed:@"network@25x25.png"];
        return img;
    }
    // power, fan, drive, network
    
    return  img;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSArray *allKeys = [[events allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    // if its eventlog, reverse the keys, so that most recent log is shown first.
    if ([function isEqualToString:@"reventlog"]) {
        allKeys = [[allKeys reverseObjectEnumerator] allObjects];
    }
    

    NSObject *theObject = [self.events objectForKey:[allKeys objectAtIndex:indexPath.row]];
    
    if ([function isEqualToString:@"reventlog"]) {
        // See if the key is an NSDate
        if([[allKeys objectAtIndex:indexPath.row ] isKindOfClass:[NSDate class]]){
                NSDate *theDate = [allKeys objectAtIndex:indexPath.row];
                xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
                cell.textLabel.text = [theApp.dateFormatter stringFromDate:theDate];
                cell.detailTextLabel.text = (NSString *)theObject;
        }else {
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = (NSString *)theObject;
        }
    }else {
        // inventory and vitals just show key value in text.
        cell.textLabel.text = [allKeys objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = (NSString *)theObject;
        cell.imageView.image = [self getImageForCell:cell.textLabel.text];
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *allKeys = [[events allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *theObject = [self.events objectForKey:[allKeys objectAtIndex:indexPath.row]];
    // combine the object back together
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];

    ItemViewController *itemViewController = [[ItemViewController alloc] init];
    
    
    if ([[allKeys objectAtIndex:indexPath.row] isKindOfClass:[NSDate class]]) {
        NSDate *date = [allKeys objectAtIndex:indexPath.row];
        NSString *d  = [theApp.dateFormatter stringFromDate:date];

        itemViewController.item = [NSString stringWithFormat:@"%@\n%@", d, theObject];    

    }else {
        if ([function isEqualToString:@"reventlog"]) {
            itemViewController.item = [NSString stringWithFormat:@"%@", theObject]; 

        }else {
            itemViewController.item = [NSString stringWithFormat:@"%@: %@", [allKeys objectAtIndex:indexPath.row], theObject];
        }
    }
    
    [self.navigationController pushViewController:itemViewController animated:YES];
    
    [itemViewController release];
    
}


#pragma mark Action Sheet Deligation Methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == 0) {
        //NSLog(@"Emailing link!");
        [self displayMailComposerSheet];
    }else if(buttonIndex == 1){
        // clear log
        [self clearEventLog];
    }
}

-(void)displayMailComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't send email" message:@"It doesn't appear that this device is configured to send email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    picker.mailComposeDelegate = self;
    NSString *subject;
    if ([function isEqualToString:@"reventlog"]) {
        subject = [[NSString alloc] initWithFormat:@"Hardware Event Log for %@", self.noderange];
    }else if ([function isEqualToString:@"rvitals"]){
        subject = [[NSString alloc] initWithFormat:@"Vitals for %@", self.noderange];
    }else {
        // default is inventory
        subject = [[NSString alloc] initWithFormat:@"Inventory for %@", self.noderange];
    }
    
    [picker setSubject:subject];
    [subject release];
    NSString *emailBody = [[NSString alloc] initWithFormat:@"<b>%@</b>", self.noderange];
    
    NSEnumerator *e = [[[self.events allKeys ] sortedArrayUsingSelector:@selector(compare:)] objectEnumerator];
    id object;
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    while (object = [e nextObject]) {
        NSString *d;
        if([object isKindOfClass:[NSDate class]]){
            NSDate *theDate = (NSDate *)object;
            d  = [theApp.dateFormatter stringFromDate:theDate];
            emailBody = [NSString stringWithFormat:@"%@\n<br/>%@ %@", emailBody, d, [self.events objectForKey:object]];

        }else {
            // if it doesn't format as a date, it should at least format as a string.
            d = object;
            if ([function isEqualToString:@"reventlog"]) {
                emailBody = [NSString stringWithFormat:@"%@\n<br/>%@", emailBody,[self.events objectForKey:object]];
            }else {
                emailBody = [NSString stringWithFormat:@"%@\n<br/><b>%@:</b> %@", emailBody,d , [self.events objectForKey:object]];
            }
        }
    }
    
    emailBody = [NSString stringWithFormat:@"%@\n\n<br/><br/>Sent via <a href='http://xcat.org'>xCAT iOS client</a>", emailBody]; 
    
    
    //NSString *emailBody = [[NSString alloc] initWithFormat:@"<a href=\"%@\">%@</a><br><br>Sent via <a href=\"http://benincosa.org/blog/?page_id=525\">FlexPod TechSpecs</a>", self.urlString, self.urlName];
    [picker setMessageBody:emailBody isHTML:YES];
    [emailBody release];
    
    [self presentModalViewController:picker animated:YES];
    //[picker release];
}

#pragma mark -
#pragma mark MFMailComposeViewController Delegate Actions
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    

    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //feedbackMsg.text = @"Result: Mail sending canceled";
            break;
        case MFMailComposeResultSaved:
            //feedbackMsg.text = @"Result: Mail saved";
            break;
        case MFMailComposeResultSent:
            //feedbackMsg.text = @"Result: Mail sent";
            break;
        case MFMailComposeResultFailed:
            //feedbackMsg.text = @"Result: Mail sending failed";
            break;
        default:
            //feedbackMsg.text = @"Result: Mail not sent";
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
