//
//  xCATViewController.m
//  xCAT
//
//  Created by Vallard Benincosa on 6/6/11.
//  Copyright 2011 Benincosa Inc. All rights reserved.
//

#import "xCATViewController.h"
#import "xCATAppDelegate.h"
#import "LoginViewController.h"
#import "CommandViewController.h"
#import "xCATNode.h"
#import "Connection.h"
#import "xCATClient.h"
#import "xCATParser.h"



#define DEBUG 1

@implementation xCATViewController


@synthesize toolbar;
@synthesize message;
@synthesize spinner;
@synthesize nodeListTable;
@synthesize xCAT;
@synthesize logOutButton;


- (void)dealloc
{
    [toolbar release];
    [logOutButton release];
  
    [xCAT release];
    [spinner release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)refreshPowerStat {
    [self showActivity];
    currentCommand = @"rpower";
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    [theApp xcmd:@"rpower" noderange:@"/.*" subcommand:@"stat"];
}


- (void)nodeStat {
    [self showActivity];
    currentCommand = @"nodestat";
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];
    [theApp xcmd:@"nodestat" noderange:@"/.*" subcommand:@""];

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
    [self.toolbar setItems:items];
    [items release];
    [spacer release];
    [loadingLabel release];
    [activityView release];
}


- (IBAction)forwardActions:(id)sender {
    
    UIActionSheet *forwardActionSheet;

    forwardActionSheet = [[UIActionSheet alloc ] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Get Power Status", @"Get Node Status", nil];
	[forwardActionSheet showFromToolbar:self.toolbar];
    [forwardActionSheet release];
}


- (void)putToolBarBack {
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(forwardActions:)];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:spacer, item, nil]];
    [spacer release];
    [item release];
    
}

#pragma mark Action Sheet Deligation Methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == 0) {
        //NSLog(@"Emailing link!");
        [self refreshPowerStat];
    }else if(buttonIndex == 1){
        // clear log
        [self nodeStat];
    }
}



#pragma mark - View lifecycle



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
 
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];

    //theApp.nodelist;
    if ([theApp.nodelist count] == 0) {
        nodeListTable.hidden = YES;
        UILabel *myNotice = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 50 )];
        myNotice.backgroundColor = [UIColor clearColor];
        myNotice.text = @"No Nodes Defined";
        myNotice.textAlignment = UITextAlignmentCenter;
        self.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:myNotice];
        [myNotice release];
    }else{
        [self signUpForNotifications];
    }
    
    
    UIImage *xLogo = [UIImage imageNamed:@"xCAT-logo-white-navbar.png"];
    
    self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:xLogo] autorelease];
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self signUpForNotifications];
    [self.nodeListTable reloadData];
}

- (void)signUpForNotifications {
    
    // Sign up for notifications for xCAT events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetxCATData) name:@"powerUpdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetxCATData) name:@"nodeStatUpdated" object:nil];
}


- (void)removeNotifications {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"powerUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"nodeStatUpdated" object:nil];


}

- (void)didGetxCATData {
    if (DEBUG > 0) {
        NSLog(@"In xCATViewController:didGetxCATData");
    }
    // remove loading sign
    dispatch_async(dispatch_get_main_queue(), ^{
        [self putToolBarBack];
        [self.nodeListTable reloadData];
    });
    
}


- (void)viewDidUnload
{
    self.toolbar = nil;
    self.logOutButton = nil;
    self.spinner = nil;
    self.xCAT = nil;

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (theApp.nodelist == nil) {
        return 0;  
    }else{
        return [theApp.nodelist count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];

    xCATNode *xNode = (xCATNode *)[theApp.nodelist objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = xNode.name;
    switch (xNode.powerState) {
        case kUnknown:
            cell.imageView.image = [UIImage imageNamed:@"amber-light.png"];
            if (xNode.statusMessage) {
                cell.detailTextLabel.text = xNode.statusMessage;
            }
            break;
        case kOn:
            cell.imageView.image = [UIImage imageNamed:@"green-light.png"];
            cell.detailTextLabel.text = [xNode statToString];
            break; 
        case kOff:
            cell.imageView.image = [UIImage imageNamed:@"gray-light.png"];
            cell.detailTextLabel.text = [xNode statToString];
            break;
        case kError:
            cell.imageView.image = [UIImage imageNamed:@"red-light.png"];
            if (xNode.statusMessage) {
                cell.detailTextLabel.text = xNode.statusMessage;
            }
            break;
        default:
            cell.imageView.image = [UIImage imageNamed:@"amber-light.png"];
            break;
    }
    
    if ([currentCommand isEqualToString:@"nodestat"]) {
        if (xNode.nodeStat) {
            NSLog(@"Data: %@", xNode.nodeStat);
            cell.detailTextLabel.text = xNode.nodeStat;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\bping|ssh|pbs" options:0 error:NULL];
            if ([regex numberOfMatchesInString:xNode.nodeStat options:0 range:NSMakeRange(0, [xNode.nodeStat length])] > 0 ) {
                cell.imageView.image = [UIImage imageNamed:@"double-arrow.png"];
               
            }else {
                cell.imageView.image = [UIImage imageNamed:@"wall.png"];

            }
        }
    }
    //cell.textLabel.text = [nodelist objectAtIndex:[indexPath row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CommandViewController *commandViewController = [[ CommandViewController alloc] initWithNibName:@"CommandViewController" bundle:nil];
    xCATAppDelegate *theApp = (xCATAppDelegate *)[[UIApplication sharedApplication] delegate];

    xCATNode *xNode = [theApp.nodelist objectAtIndex:[indexPath row]];
    commandViewController.hostName = xNode.name;
    
    if(self.navigationController){
        [self removeNotifications];
        [self.navigationController pushViewController:commandViewController animated:YES];
        // resign up for notifications if we are now back!
        //[self signUpForNotifications];
    }else{
        NSLog(@"Navigation controller is nil");
    }
    [commandViewController release];
   
}

@end
